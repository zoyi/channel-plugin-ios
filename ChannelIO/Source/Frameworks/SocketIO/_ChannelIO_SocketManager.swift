//
// Created by Erik Little on 10/14/17.
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

///
/// A manager for a socket.io connection.
///
/// A `SocketManager` is responsible for multiplexing multiple namespaces through a single `SocketEngineSpec`.
///
/// Example:
///
/// ```swift
/// let manager = SocketManager(socketURL: URL(string:"http://localhost:8080/")!)
/// let defaultNamespaceSocket = manager.defaultSocket
/// let swiftSocket = manager.socket(forNamespace: "/swift")
///
/// // defaultNamespaceSocket and swiftSocket both share a single connection to the server
/// ```
///
/// Sockets created through the manager are retained by the manager. So at the very least, a single strong reference
/// to the manager must be maintained to keep sockets alive.
///
/// To disconnect a socket and remove it from the manager, either call `SocketIOClient.disconnect()` on the socket,
/// or call one of the `disconnectSocket` methods on this class.
///
/// **NOTE**: The manager is not thread/queue safe, all interaction with the manager should be done on the `handleQueue`
///
class SocketIO_SocketManager : NSObject, SocketIO_SocketManagerSpec, SocketIO_SocketParsable, SocketIO_SocketDataBufferable, SocketIO_ConfigSettable {
    private static let logType = "SocketManager"

    // MARK: Properties

    /// The socket associated with the default namespace ("/").
    var defaultSocket: SocketIO_SocketIOClient {
        return socket(forNamespace: "/")
    }

    /// The URL of the socket.io server.
    ///
    /// If changed after calling `init`, `forceNew` must be set to `true`, or it will only connect to the url set in the
    /// init.
    let socketURL: URL

    /// The configuration for this client.
    ///
    /// **Some configs will not take affect until after a reconnect if set after calling a connect method**.
    var config: SocketIO_SocketIOClientConfiguration {
        get {
            return _config
        }

        set {
            if status.active {
                SocketIO_DefaultSocketLogger.Logger.log("Setting configs on active manager. Some configs may not be applied until reconnect",
                                               type: SocketIO_SocketManager.logType)
            }

            setConfigs(newValue)
        }
    }

    /// The engine for this manager.
    var engine: SocketIO_SocketEngineSpec?

    /// If `true` then every time `connect` is called, a new engine will be created.
    var forceNew = false

    /// The queue that all interaction with the client should occur on. This is the queue that event handlers are
    /// called on.
    ///
    /// **This should be a serial queue! Concurrent queues are not supported and might cause crashes and races**.
    var handleQueue = DispatchQueue.main

    /// The sockets in this manager indexed by namespace.
    var nsps = [String: SocketIO_SocketIOClient]()

    /// If `true`, this client will try and reconnect on any disconnects.
    var reconnects = true

    /// The minimum number of seconds to wait before attempting to reconnect.
    var reconnectWait = 10

    /// The maximum number of seconds to wait before attempting to reconnect.
    var reconnectWaitMax = 30

    /// The randomization factor for calculating reconnect jitter.
    var randomizationFactor = 0.5

    /// The status of this manager.
    private(set) var status: SocketIO_SocketIOStatus = .notConnected {
        didSet {
            switch status {
            case .connected:
                reconnecting = false
                currentReconnectAttempt = 0
            default:
                break
            }
        }
    }

    /// A list of packets that are waiting for binary data.
    ///
    /// The way that socket.io works all data should be sent directly after each packet.
    /// So this should ideally be an array of one packet waiting for data.
    ///
    /// **This should not be modified directly.**
    var waitingPackets = [SocketIO_SocketPacket]()

    private(set) var reconnectAttempts = -1

    private var _config: SocketIO_SocketIOClientConfiguration
    private var currentReconnectAttempt = 0
    private var reconnecting = false

    // MARK: Initializers

    /// Type safe way to create a new SocketIOClient. `opts` can be omitted.
    ///
    /// - parameter socketURL: The url of the socket.io server.
    /// - parameter config: The config for this socket.
    init(socketURL: URL, config: SocketIO_SocketIOClientConfiguration = []) {
        self._config = config
        self.socketURL = socketURL

        super.init()

        setConfigs(_config)
    }

    /// Not so type safe way to create a SocketIOClient, meant for Objective-C compatiblity.
    /// If using Swift it's recommended to use `init(socketURL: NSURL, options: Set<SocketIOClientOption>)`
    ///
    /// - parameter socketURL: The url of the socket.io server.
    /// - parameter config: The config for this socket.
    @objc
    convenience init(socketURL: URL, config: [String: Any]?) {
        self.init(socketURL: socketURL, config: config?.SocketIO_toSocketConfiguration() ?? [])
    }

    /// :nodoc:
    deinit {
        SocketIO_DefaultSocketLogger.Logger.log("Manager is being released", type: SocketIO_SocketManager.logType)

        engine?.disconnect(reason: "Manager Deinit")
    }

    // MARK: Methods

    private func addEngine() {
        SocketIO_DefaultSocketLogger.Logger.log("Adding engine", type: SocketIO_SocketManager.logType)

        engine?.engineQueue.sync {
            self.engine?.client = nil

            // Close old engine so it will not leak because of URLSession if in polling mode
            self.engine?.disconnect(reason: "Adding new engine")
        }

        engine = SocketIO_SocketEngine(client: self, url: socketURL, config: config)
    }

    /// Connects the underlying transport and the default namespace socket.
    ///
    /// Override if you wish to attach a custom `SocketEngineSpec`.
    func connect() {
        guard !status.active else {
            SocketIO_DefaultSocketLogger.Logger.log("Tried connecting an already active socket", type: SocketIO_SocketManager.logType)

            return
        }

        if engine == nil || forceNew {
            addEngine()
        }

        status = .connecting

        engine?.connect()
    }

    /// Connects a socket through this manager's engine.
    ///
    /// - parameter socket: The socket who we should connect through this manager.
    func connectSocket(_ socket: SocketIO_SocketIOClient) {
        guard status == .connected else {
            SocketIO_DefaultSocketLogger.Logger.log("Tried connecting socket when engine isn't open. Connecting",
                                           type: SocketIO_SocketManager.logType)

            connect()
            return
        }

        engine?.send("0\(socket.nsp),", withData: [])
    }

    /// Called when the manager has disconnected from socket.io.
    ///
    /// - parameter reason: The reason for the disconnection.
    func didDisconnect(reason: String) {
        forAll {socket in
            socket.didDisconnect(reason: reason)
        }
    }

    /// Disconnects the manager and all associated sockets.
    func disconnect() {
        SocketIO_DefaultSocketLogger.Logger.log("Manager closing", type: SocketIO_SocketManager.logType)

        status = .disconnected

        engine?.disconnect(reason: "Disconnect")
    }

    /// Disconnects the given socket.
    ///
    /// This will remove the socket for the manager's control, and make the socket instance useless and ready for
    /// releasing.
    ///
    /// - parameter socket: The socket to disconnect.
    func disconnectSocket(_ socket: SocketIO_SocketIOClient) {
        engine?.send("1\(socket.nsp),", withData: [])

        socket.didDisconnect(reason: "Namespace leave")
    }

    /// Disconnects the socket associated with `forNamespace`.
    ///
    /// This will remove the socket for the manager's control, and make the socket instance useless and ready for
    /// releasing.
    ///
    /// - parameter nsp: The namespace to disconnect from.
    func disconnectSocket(forNamespace nsp: String) {
        guard let socket = nsps.removeValue(forKey: nsp) else {
            SocketIO_DefaultSocketLogger.Logger.log("Could not find socket for \(nsp) to disconnect",
                                           type: SocketIO_SocketManager.logType)

            return
        }

        disconnectSocket(socket)
    }

    /// Sends a client event to all sockets in `nsps`
    ///
    /// - parameter clientEvent: The event to emit.
    func emitAll(clientEvent event: SocketIO_SocketClientEvent, data: [Any]) {
        forAll {socket in
            socket.handleClientEvent(event, data: data)
        }
    }

    /// Sends an event to the server on all namespaces in this manager.
    ///
    /// - parameter event: The event to send.
    /// - parameter items: The data to send with this event.
    func emitAll(_ event: String, _ items: SocketIO_SocketData...) {
        guard let emitData = try? items.map({ try $0.socketRepresentation() }) else {
            SocketIO_DefaultSocketLogger.Logger.error("Error creating socketRepresentation for emit: \(event), \(items)",
                                             type: SocketIO_SocketManager.logType)

            return
        }

        emitAll(event, withItems: emitData)
    }

    /// Sends an event to the server on all namespaces in this manager.
    ///
    /// Same as `emitAll(_:_:)`, but meant for Objective-C.
    ///
    /// - parameter event: The event to send.
    /// - parameter items: The data to send with this event.
    func emitAll(_ event: String, withItems items: [Any]) {
        forAll {socket in
            socket.emit(event, with: items, completion: nil)
        }
    }

    /// Called when the engine closes.
    ///
    /// - parameter reason: The reason that the engine closed.
    func engineDidClose(reason: String) {
        handleQueue.async {
            self._engineDidClose(reason: reason)
        }
    }

    private func _engineDidClose(reason: String) {
        waitingPackets.removeAll()

        if status != .disconnected {
            status = .notConnected
        }

        if status == .disconnected || !reconnects {
            didDisconnect(reason: reason)
        } else if !reconnecting {
            reconnecting = true
            tryReconnect(reason: reason)
        }
    }

    /// Called when the engine errors.
    ///
    /// - parameter reason: The reason the engine errored.
    func engineDidError(reason: String) {
        handleQueue.async {
            self._engineDidError(reason: reason)
        }
    }

    private func _engineDidError(reason: String) {
        SocketIO_DefaultSocketLogger.Logger.error("\(reason)", type: SocketIO_SocketManager.logType)

        emitAll(clientEvent: .error, data: [reason])
    }

    /// Called when the engine opens.
    ///
    /// - parameter reason: The reason the engine opened.
    func engineDidOpen(reason: String) {
        handleQueue.async {
            self._engineDidOpen(reason: reason)
        }
    }

    private func _engineDidOpen(reason: String) {
        SocketIO_DefaultSocketLogger.Logger.log("Engine opened \(reason)", type: SocketIO_SocketManager.logType)

        status = .connected
        nsps["/"]?.didConnect(toNamespace: "/")

        for (nsp, socket) in nsps where nsp != "/" && socket.status == .connecting {
            connectSocket(socket)
        }
    }

    /// Called when the engine receives a pong message.
    func engineDidReceivePong() {
        handleQueue.async {
            self._engineDidReceivePong()
        }
    }

    private func _engineDidReceivePong() {
        emitAll(clientEvent: .pong, data: [])
    }

    /// Called when the sends a ping to the server.
    func engineDidSendPing() {
        handleQueue.async {
            self._engineDidSendPing()
        }
    }

    private func _engineDidSendPing() {
        emitAll(clientEvent: .ping, data: [])
    }

    private func forAll(do: (SocketIO_SocketIOClient) throws -> ()) rethrows {
        for (_, socket) in nsps {
            try `do`(socket)
        }
    }

    /// Called when when upgrading the http connection to a websocket connection.
    ///
    /// - parameter headers: The http headers.
    func engineDidWebsocketUpgrade(headers: [String: String]) {
        handleQueue.async {
            self._engineDidWebsocketUpgrade(headers: headers)
        }
    }
     private func _engineDidWebsocketUpgrade(headers: [String: String]) {
        emitAll(clientEvent: .websocketUpgrade, data: [headers])
    }

    /// Called when the engine has a message that must be parsed.
    ///
    /// - parameter msg: The message that needs parsing.
    func parseEngineMessage(_ msg: String) {
        handleQueue.async {
            self._parseEngineMessage(msg)
        }
    }

    private func _parseEngineMessage(_ msg: String) {
        guard let packet = parseSocketMessage(msg) else { return }
        guard !packet.type.isBinary else {
            waitingPackets.append(packet)

            return
        }

        nsps[packet.nsp]?.handlePacket(packet)
    }

    /// Called when the engine receives binary data.
    ///
    /// - parameter data: The data the engine received.
    func parseEngineBinaryData(_ data: Data) {
        handleQueue.async {
            self._parseEngineBinaryData(data)
        }
    }

    private func _parseEngineBinaryData(_ data: Data) {
        guard let packet = parseBinaryData(data) else { return }

        nsps[packet.nsp]?.handlePacket(packet)
    }

    /// Tries to reconnect to the server.
    ///
    /// This will cause a `SocketClientEvent.reconnect` event to be emitted, as well as
    /// `SocketClientEvent.reconnectAttempt` events.
    func reconnect() {
        guard !reconnecting else { return }

        engine?.disconnect(reason: "manual reconnect")
    }

    /// Removes the socket from the manager's control. One of the disconnect methods should be called before calling this
    /// method.
    ///
    /// After calling this method the socket should no longer be considered usable.
    ///
    /// - parameter socket: The socket to remove.
    /// - returns: The socket removed, if it was owned by the manager.
    @discardableResult
    func removeSocket(_ socket: SocketIO_SocketIOClient) -> SocketIO_SocketIOClient? {
        return nsps.removeValue(forKey: socket.nsp)
    }

    private func tryReconnect(reason: String) {
        guard reconnecting else { return }

        SocketIO_DefaultSocketLogger.Logger.log("Starting reconnect", type: SocketIO_SocketManager.logType)

        // Set status to connecting and emit reconnect for all sockets
        forAll {socket in
            guard socket.status == .connected else { return }

            socket.setReconnecting(reason: reason)
        }

        _tryReconnect()
    }

    private func _tryReconnect() {
        guard reconnects && reconnecting && status != .disconnected else { return }

        if reconnectAttempts != -1 && currentReconnectAttempt + 1 > reconnectAttempts {
            return didDisconnect(reason: "Reconnect Failed")
        }

        SocketIO_DefaultSocketLogger.Logger.log("Trying to reconnect", type: SocketIO_SocketManager.logType)
        emitAll(clientEvent: .reconnectAttempt, data: [(reconnectAttempts - currentReconnectAttempt)])

        currentReconnectAttempt += 1
        connect()

        let interval = reconnectInterval(attempts: currentReconnectAttempt)
        SocketIO_DefaultSocketLogger.Logger.log("Scheduling reconnect in \(interval)s", type: SocketIO_SocketManager.logType)
        handleQueue.asyncAfter(deadline: DispatchTime.now() + interval, execute: _tryReconnect)
    }

    func reconnectInterval(attempts: Int) -> Double {
        // apply exponential factor
        let backoffFactor = pow(1.5, attempts)
        let interval = Double(reconnectWait) * Double(truncating: backoffFactor as NSNumber)
        // add in a random factor smooth thundering herds
        let rand = Double.random(in: 0 ..< 1)
        let randomFactor = rand * randomizationFactor * Double(truncating: interval as NSNumber)
        // add in random factor, and clamp to min and max values
        let combined = interval + randomFactor
        return Double(fmax(Double(reconnectWait), fmin(combined, Double(reconnectWaitMax))))
    }

    /// Sets manager specific configs.
    ///
    /// parameter config: The configs that should be set.
    func setConfigs(_ config: SocketIO_SocketIOClientConfiguration) {
        for option in config {
            switch option {
            case let .forceNew(new):
                self.forceNew = new
            case let .handleQueue(queue):
                self.handleQueue = queue
            case let .reconnects(reconnects):
                self.reconnects = reconnects
            case let .reconnectAttempts(attempts):
                self.reconnectAttempts = attempts
            case let .reconnectWait(wait):
                reconnectWait = abs(wait)
            case let .reconnectWaitMax(wait):
                reconnectWaitMax = abs(wait)
            case let .randomizationFactor(factor):
                randomizationFactor = factor
            case let .log(log):
                SocketIO_DefaultSocketLogger.Logger.log = log
            case let .logger(logger):
                SocketIO_DefaultSocketLogger.Logger = logger
            case _:
                continue
            }
        }

        _config = config

        if socketURL.absoluteString.hasPrefix("https://") {
            _config.insert(.secure(true))
        }

        _config.insert(.path("/socket.io/"), replacing: false)

        // If `ConfigSettable` & `SocketEngineSpec`, update its configs.
        if var settableEngine = engine as? SocketIO_ConfigSettable & SocketIO_SocketEngineSpec {
            settableEngine.engineQueue.sync {
                settableEngine.setConfigs(self._config)
            }

            engine = settableEngine
        }
    }

    /// Returns a `SocketIOClient` for the given namespace. This socket shares a transport with the manager.
    ///
    /// Calling multiple times returns the same socket.
    ///
    /// Sockets created from this method are retained by the manager.
    /// Call one of the `disconnectSocket` methods on this class to remove the socket from manager control.
    /// Or call `SocketIOClient.disconnect()` on the client.
    ///
    /// - parameter nsp: The namespace for the socket.
    /// - returns: A `SocketIOClient` for the given namespace.
    func socket(forNamespace nsp: String) -> SocketIO_SocketIOClient {
        assert(nsp.hasPrefix("/"), "forNamespace must have a leading /")

        if let socket = nsps[nsp] {
            return socket
        }

        let client = SocketIO_SocketIOClient(manager: self, nsp: nsp)

        nsps[nsp] = client

        return client
    }

    // Test properties

    func setTestStatus(_ status: SocketIO_SocketIOStatus) {
        self.status = status
    }
}
