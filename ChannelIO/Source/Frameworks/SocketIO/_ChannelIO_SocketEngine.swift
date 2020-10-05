//
//  SocketEngine.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 3/3/15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Dispatch
import Foundation

/// The class that handles the engine.io protocol and transports.
/// See `SocketEnginePollable` and `SocketEngineWebsocket` for transport specific methods.
class SocketIO_SocketEngine : NSObject, URLSessionDelegate, SocketIO_SocketEnginePollable, SocketIO_SocketEngineWebsocket, SocketIO_ConfigSettable {
    // MARK: Properties

    private static let logType = "SocketEngine"

    /// The queue that all engine actions take place on.
    let engineQueue = DispatchQueue(label: "com.socketio.engineHandleQueue")

    /// The connect parameters sent during a connect.
    var connectParams: [String: Any]? {
        didSet {
            (urlPolling, urlWebSocket) = createURLs()
        }
    }

    /// A dictionary of extra http headers that will be set during connection.
    var extraHeaders: [String: String]?

    /// A queue of engine.io messages waiting for POSTing
    ///
    /// **You should not touch this directly**
    var postWait = [SocketIO_Post]()

    /// `true` if there is an outstanding poll. Trying to poll before the first is done will cause socket.io to
    /// disconnect us.
    ///
    /// **Do not touch this directly**
    var waitingForPoll = false

    /// `true` if there is an outstanding post. Trying to post before the first is done will cause socket.io to
    /// disconnect us.
    ///
    /// **Do not touch this directly**
    var waitingForPost = false

    /// `true` if this engine is closed.
    private(set) var closed = false

    /// If `true` the engine will attempt to use WebSocket compression.
    private(set) var compress = false

    /// `true` if this engine is connected. Connected means that the initial poll connect has succeeded.
    private(set) var connected = false

    /// An array of HTTPCookies that are sent during the connection.
    private(set) var cookies: [HTTPCookie]?

    /// When `true`, the engine is in the process of switching to WebSockets.
    ///
    /// **Do not touch this directly**
    private(set) var fastUpgrade = false

    /// When `true`, the engine will only use HTTP long-polling as a transport.
    private(set) var forcePolling = false

    /// When `true`, the engine will only use WebSockets as a transport.
    private(set) var forceWebsockets = false

    /// `true` If engine's session has been invalidated.
    private(set) var invalidated = false

    /// If `true`, the engine is currently in HTTP long-polling mode.
    private(set) var polling = true

    /// If `true`, the engine is currently seeing whether it can upgrade to WebSockets.
    private(set) var probing = false

    /// The URLSession that will be used for polling.
    private(set) var session: URLSession?

    /// The session id for this engine.
    private(set) var sid = ""

    /// The path to engine.io.
    private(set) var socketPath = "/engine.io/"

    /// The url for polling.
    private(set) var urlPolling = URL(string: "http://localhost/")!

    /// The url for WebSockets.
    private(set) var urlWebSocket = URL(string: "http://localhost/")!

    /// If `true`, then the engine is currently in WebSockets mode.
    @available(*, deprecated, message: "No longer needed, if we're not polling, then we must be doing websockets")
    private(set) var websocket = false

    /// When `true`, the WebSocket `stream` will be configured with the enableSOCKSProxy `true`.
    private(set) var enableSOCKSProxy = false

    /// The WebSocket for this engine.
    private(set) var ws: Starscream_WebSocket?

    /// The client for this engine.
    weak var client: SocketIO_SocketEngineClient?

    private weak var sessionDelegate: URLSessionDelegate?

    private let url: URL

    private var pingInterval: Int?
    private var pingTimeout = 0 {
        didSet {
            pongsMissedMax = Int(pingTimeout / (pingInterval ?? 25000))
        }
    }

    private var pongsMissed = 0
    private var pongsMissedMax = 0
    private var probeWait = SocketIO_ProbeWaitQueue()
    private var secure = false
    private var security: SocketIO_SSLSecurity?
    private var selfSigned = false

    // MARK: Initializers

    /// Creates a new engine.
    ///
    /// - parameter client: The client for this engine.
    /// - parameter url: The url for this engine.
    /// - parameter config: An array of configuration options for this engine.
    init(client: SocketIO_SocketEngineClient, url: URL, config: SocketIO_SocketIOClientConfiguration) {
        self.client = client
        self.url = url

        super.init()

        setConfigs(config)

        sessionDelegate = sessionDelegate ?? self

        (urlPolling, urlWebSocket) = createURLs()
    }

    /// Creates a new engine.
    ///
    /// - parameter client: The client for this engine.
    /// - parameter url: The url for this engine.
    /// - parameter options: The options for this engine.
    required convenience init(client: SocketIO_SocketEngineClient, url: URL, options: [String: Any]?) {
        self.init(client: client, url: url, config: options?.SocketIO_toSocketConfiguration() ?? [])
    }

    /// :nodoc:
    deinit {
        SocketIO_DefaultSocketLogger.Logger.log("Engine is being released", type: SocketIO_SocketEngine.logType)
        closed = true
        stopPolling()
    }

    // MARK: Methods

    private func checkAndHandleEngineError(_ msg: String) {
        do {
            let dict = try msg.SocketIO_toDictionary()
            guard let error = dict["message"] as? String else { return }

            /*
             0: Unknown transport
             1: Unknown sid
             2: Bad handshake request
             3: Bad request
             */
            didError(reason: error)
        } catch {
            client?.engineDidError(reason: "Got unknown error from server \(msg)")
        }
    }

    private func handleBase64(message: String) {
        // binary in base64 string
        let noPrefix = String(message[message.index(message.startIndex, offsetBy: 2)..<message.endIndex])

        if let data = Data(base64Encoded: noPrefix, options: .ignoreUnknownCharacters) {
            client?.parseEngineBinaryData(data)
        }
    }

    private func closeOutEngine(reason: String) {
        sid = ""
        closed = true
        invalidated = true
        connected = false

        ws?.disconnect()
        stopPolling()
        client?.engineDidClose(reason: reason)
    }

    /// Starts the connection to the server.
    func connect() {
        engineQueue.async {
            self._connect()
        }
    }

    private func _connect() {
        if connected {
            SocketIO_DefaultSocketLogger.Logger.error("Engine tried opening while connected. Assuming this was a reconnect",
                                             type: SocketIO_SocketEngine.logType)
            _disconnect(reason: "reconnect")
        }

        SocketIO_DefaultSocketLogger.Logger.log("Starting engine. Server: \(url)", type: SocketIO_SocketEngine.logType)
        SocketIO_DefaultSocketLogger.Logger.log("Handshaking", type: SocketIO_SocketEngine.logType)

        resetEngine()

        if forceWebsockets {
            polling = false
            createWebSocketAndConnect()
            return
        }

        var reqPolling = URLRequest(url: urlPolling, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)

        addHeaders(to: &reqPolling)
        doLongPoll(for: reqPolling)
    }

    private func createURLs() -> (URL, URL) {
        if client == nil {
            return (URL(string: "http://localhost/")!, URL(string: "http://localhost/")!)
        }

        var urlPolling = URLComponents(string: url.absoluteString)!
        var urlWebSocket = URLComponents(string: url.absoluteString)!
        var queryString = ""

        urlWebSocket.path = socketPath
        urlPolling.path = socketPath

        if secure {
            urlPolling.scheme = "https"
            urlWebSocket.scheme = "wss"
        } else {
            urlPolling.scheme = "http"
            urlWebSocket.scheme = "ws"
        }

        if let connectParams = self.connectParams {
            for (key, value) in connectParams {
                let keyEsc = key.SocketIO_urlEncode()!
                let valueEsc = "\(value)".SocketIO_urlEncode()!

                queryString += "&\(keyEsc)=\(valueEsc)"
            }
        }

        urlWebSocket.percentEncodedQuery = "transport=websocket" + queryString
        urlPolling.percentEncodedQuery = "transport=polling&b64=1" + queryString

        return (urlPolling.url!, urlWebSocket.url!)
    }

    private func createWebSocketAndConnect() {
        var req = URLRequest(url: urlWebSocketWithSid)

        addHeaders(to: &req, includingCookies: session?.configuration.httpCookieStorage?.cookies(for: urlPollingWithSid))

        let stream = Starscream_FoundationStream()
        stream.enableSOCKSProxy = enableSOCKSProxy
        ws = Starscream_WebSocket(request: req, stream: stream)
        ws?.callbackQueue = engineQueue
        ws?.enableCompression = compress
        ws?.disableSSLCertValidation = selfSigned
        ws?.security = security?.security

        ws?.onConnect = {[weak self] in
            guard let this = self else { return }

            this.websocketDidConnect()
        }

        ws?.onDisconnect = {[weak self] error in
            guard let this = self else { return }

            this.websocketDidDisconnect(error: error)
        }

        ws?.onData = {[weak self] data in
            guard let this = self else { return }

            this.parseEngineData(data)
        }

        ws?.onText = {[weak self] message in
            guard let this = self else { return }

            this.parseEngineMessage(message)
        }

        ws?.onHttpResponseHeaders = {[weak self] headers in
            guard let this = self else { return }

            this.client?.engineDidWebsocketUpgrade(headers: headers)
        }

        ws?.connect()
    }

    /// Called when an error happens during execution. Causes a disconnection.
    func didError(reason: String) {
        SocketIO_DefaultSocketLogger.Logger.error("\(reason)", type: SocketIO_SocketEngine.logType)
        client?.engineDidError(reason: reason)
        disconnect(reason: reason)
    }

    /// Disconnects from the server.
    ///
    /// - parameter reason: The reason for the disconnection. This is communicated up to the client.
    func disconnect(reason: String) {
        engineQueue.async {
            self._disconnect(reason: reason)
        }
    }

    private func _disconnect(reason: String) {
        guard connected && !closed else { return closeOutEngine(reason: reason) }

        SocketIO_DefaultSocketLogger.Logger.log("Engine is being closed.", type: SocketIO_SocketEngine.logType)

        if polling {
            disconnectPolling(reason: reason)
        } else {
            sendWebSocketMessage("", withType: .close, withData: [], completion: nil)
            closeOutEngine(reason: reason)
        }
    }

    // We need to take special care when we're polling that we send it ASAP
    // Also make sure we're on the emitQueue since we're touching postWait
    private func disconnectPolling(reason: String) {
        postWait.append((String(SocketIO_SocketEnginePacketType.close.rawValue), {}))

        doRequest(for: createRequestForPostWithPostWait()) {_, _, _ in }
        closeOutEngine(reason: reason)
    }

    /// Called to switch from HTTP long-polling to WebSockets. After calling this method the engine will be in
    /// WebSocket mode.
    ///
    /// **You shouldn't call this directly**
    func doFastUpgrade() {
        if waitingForPoll {
            SocketIO_DefaultSocketLogger.Logger.error("Outstanding poll when switched to WebSockets," +
                "we'll probably disconnect soon. You should report this.", type: SocketIO_SocketEngine.logType)
        }

        SocketIO_DefaultSocketLogger.Logger.log("Switching to WebSockets", type: SocketIO_SocketEngine.logType)

        sendWebSocketMessage("", withType: .upgrade, withData: [], completion: nil)
        polling = false
        fastUpgrade = false
        probing = false
        flushProbeWait()

        // Need to flush postWait to socket since it connected successfully
        // moved from flushProbeWait() since it is also called on connected failure, and we don't want to try and send
        // packets through WebSockets when WebSockets has failed!
        if !postWait.isEmpty {
            flushWaitingForPostToWebSocket()
        }
    }

    private func flushProbeWait() {
        SocketIO_DefaultSocketLogger.Logger.log("Flushing probe wait", type: SocketIO_SocketEngine.logType)

        for waiter in probeWait {
            write(waiter.msg, withType: waiter.type, withData: waiter.data, completion: waiter.completion)
        }

        probeWait.removeAll(keepingCapacity: false)
    }

    /// Causes any packets that were waiting for POSTing to be sent through the WebSocket. This happens because when
    /// the engine is attempting to upgrade to WebSocket it does not do any POSTing.
    ///
    /// **You shouldn't call this directly**
    func flushWaitingForPostToWebSocket() {
        guard let ws = self.ws else { return }

        for msg in postWait {
            ws.write(string: msg.msg, completion: msg.completion)
        }

        postWait.removeAll(keepingCapacity: false)
    }

    private func handleClose(_ reason: String) {
        client?.engineDidClose(reason: reason)
    }

    private func handleMessage(_ message: String) {
        client?.parseEngineMessage(message)
    }

    private func handleNOOP() {
        doPoll()
    }

    private func handleOpen(openData: String) {
        guard let json = try? openData.SocketIO_toDictionary() else {
            didError(reason: "Error parsing packet")

            return
        }

        guard let sid = json["sid"] as? String else {
            didError(reason: "packet contained no sid")

            return
        }

        let upgradeWs: Bool

        self.sid = sid
        connected = true
        pongsMissed = 0

        if let upgrades = json["upgrades"] as? [String] {
            upgradeWs = upgrades.contains("websocket")
        } else {
            upgradeWs = false
        }

        if let pingInterval = json["pingInterval"] as? Int, let pingTimeout = json["pingTimeout"] as? Int {
            self.pingInterval = pingInterval
            self.pingTimeout = pingTimeout
        }

        if !forcePolling && !forceWebsockets && upgradeWs {
            createWebSocketAndConnect()
        }

        sendPing()

        if !forceWebsockets {
            doPoll()
        }

        client?.engineDidOpen(reason: "Connect")
    }

    private func handlePong(with message: String) {
        pongsMissed = 0

        // We should upgrade
        if message == "3probe" {
            SocketIO_DefaultSocketLogger.Logger.log("Received probe response, should upgrade to WebSockets",
                                           type: SocketIO_SocketEngine.logType)

            upgradeTransport()
        }

        client?.engineDidReceivePong()
    }

    /// Parses raw binary received from engine.io.
    ///
    /// - parameter data: The data to parse.
    func parseEngineData(_ data: Data) {
        SocketIO_DefaultSocketLogger.Logger.log("Got binary data: \(data)", type: SocketIO_SocketEngine.logType)

        client?.parseEngineBinaryData(data.subdata(in: 1..<data.endIndex))
    }

    /// Parses a raw engine.io packet.
    ///
    /// - parameter message: The message to parse.
    func parseEngineMessage(_ message: String) {
        SocketIO_DefaultSocketLogger.Logger.log("Got message: \(message)", type: SocketIO_SocketEngine.logType)

        let reader = SocketIO_SocketStringReader(message: message)

        if message.hasPrefix("b4") {
            return handleBase64(message: message)
        }

        guard let type = SocketIO_SocketEnginePacketType(rawValue: Int(reader.currentCharacter) ?? -1) else {
            checkAndHandleEngineError(message)

            return
        }

        switch type {
        case .message:
            handleMessage(String(message.dropFirst()))
        case .noop:
            handleNOOP()
        case .pong:
            handlePong(with: message)
        case .open:
            handleOpen(openData: String(message.dropFirst()))
        case .close:
            handleClose(message)
        default:
            SocketIO_DefaultSocketLogger.Logger.log("Got unknown packet type", type: SocketIO_SocketEngine.logType)
        }
    }

    // Puts the engine back in its default state
    private func resetEngine() {
        let queue = OperationQueue()
        queue.underlyingQueue = engineQueue

        closed = false
        connected = false
        fastUpgrade = false
        polling = true
        probing = false
        invalidated = false
        session = Foundation.URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: queue)
        sid = ""
        waitingForPoll = false
        waitingForPost = false
    }

    private func sendPing() {
        guard connected, let pingInterval = pingInterval else { return }

        // Server is not responding
        if pongsMissed > pongsMissedMax {
            closeOutEngine(reason: "Ping timeout")
            return
        }

        pongsMissed += 1
        write("", withType: .ping, withData: [], completion: nil)

        engineQueue.asyncAfter(deadline: .now() + .milliseconds(pingInterval)) {[weak self, id = self.sid] in
            // Make sure not to ping old connections
            guard let this = self, this.sid == id else { return }

            this.sendPing()
        }

        client?.engineDidSendPing()
    }

    /// Called when the engine should set/update its configs from a given configuration.
    ///
    /// parameter config: The `SocketIOClientConfiguration` that should be used to set/update configs.
    func setConfigs(_ config: SocketIO_SocketIOClientConfiguration) {
        for option in config {
            switch option {
            case let .connectParams(params):
                connectParams = params
            case let .cookies(cookies):
                self.cookies = cookies
            case let .extraHeaders(headers):
                extraHeaders = headers
            case let .sessionDelegate(delegate):
                sessionDelegate = delegate
            case let .forcePolling(force):
                forcePolling = force
            case let .forceWebsockets(force):
                forceWebsockets = force
            case let .path(path):
                socketPath = path

                if !socketPath.hasSuffix("/") {
                    socketPath += "/"
                }
            case let .secure(secure):
                self.secure = secure
            case let .selfSigned(selfSigned):
                self.selfSigned = selfSigned
            case let .security(security):
                self.security = security
            case .compress:
                self.compress = true
            case .enableSOCKSProxy:
                self.enableSOCKSProxy = true
            default:
                continue
            }
        }
    }

    // Moves from long-polling to websockets
    private func upgradeTransport() {
        if ws?.isConnected ?? false {
            SocketIO_DefaultSocketLogger.Logger.log("Upgrading transport to WebSockets", type: SocketIO_SocketEngine.logType)

            fastUpgrade = true
            sendPollMessage("", withType: .noop, withData: [], completion: nil)
            // After this point, we should not send anymore polling messages
        }
    }

    /// Writes a message to engine.io, independent of transport.
    ///
    /// - parameter msg: The message to send.
    /// - parameter type: The type of this message.
    /// - parameter data: Any data that this message has.
    /// - parameter completion: Callback called on transport write completion.
    func write(_ msg: String, withType type: SocketIO_SocketEnginePacketType, withData data: [Data], completion: (() -> ())? = nil) {
        engineQueue.async {
            guard self.connected else {
                completion?()
                return
            }
            guard !self.probing else {
                self.probeWait.append((msg, type, data, completion))

                return
            }

            if self.polling {
                SocketIO_DefaultSocketLogger.Logger.log("Writing poll: \(msg) has data: \(data.count != 0)",
                                               type: SocketIO_SocketEngine.logType)
                self.sendPollMessage(msg, withType: type, withData: data, completion: completion)
            } else {
                SocketIO_DefaultSocketLogger.Logger.log("Writing ws: \(msg) has data: \(data.count != 0)",
                                               type: SocketIO_SocketEngine.logType)
                self.sendWebSocketMessage(msg, withType: type, withData: data, completion: completion)
            }
        }
    }

    // WebSocket Methods

    private func websocketDidConnect() {
        if !forceWebsockets {
            probing = true
            probeWebSocket()
        } else {
            connected = true
            probing = false
            polling = false
        }
    }

    private func websocketDidDisconnect(error: Error?) {
        probing = false

        if closed {
            client?.engineDidClose(reason: "Disconnect")

            return
        }

        guard !polling else {
            flushProbeWait()

            return
        }

        connected = false
        polling = true

        if let error = error as? Starscream_WSError {
            didError(reason: "\(error.message). code=\(error.code), type=\(error.type)")
        } else if let reason = error?.localizedDescription {
            didError(reason: reason)
        } else {
            client?.engineDidClose(reason: "Socket Disconnected")
        }
    }

    // Test Properties

    func setConnected(_ value: Bool) {
        connected = value
    }
}

extension SocketIO_SocketEngine {
    // MARK: URLSessionDelegate methods

    /// Delegate called when the session becomes invalid.
    func URLSession(session: URLSession, didBecomeInvalidWithError error: NSError?) {
        SocketIO_DefaultSocketLogger.Logger.error("Engine URLSession became invalid", type: "SocketEngine")

        didError(reason: "Engine URLSession became invalid")
    }
}
