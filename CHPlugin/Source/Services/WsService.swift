//
//  WsService.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import ReSwift
import SocketIO
import ObjectMapper

enum WSType: String {
  case PRODUCTION = "https://ws-2.channel.io"
  case ALPHA = "http://ws.exp.channel.io"
  case BETA = "http://ws.staging.channel.io"
}

enum CHSocketRequest : String {
  case authentication = "authentication"
  case join = "join"
  case leave = "leave"
  case heartbeat = "heartbeat"
  
  var value: String {
    return self.rawValue
  }
}

enum CHSocketResponse : String {
  case connected = "connect"
  case ready = "ready"
  case create = "create"
  case update = "update"
  case delete = "delete"
  case joined = "joined"
  case leaved = "leaved"
  case authenticated = "authenticated"
  case unauthorized = "unauthorized"
  case reconnect = "reconnectAttempt"
  case disconnect = "disconnect"
  case push = "push"
  case error = "error"
  case typing = "typing"
  
  var value: String {
    return self.rawValue
  }
}

struct WsServiceType: OptionSet {
  // event
  static let Create = WsServiceType(rawValue: 1 << 1)
  static let Update = WsServiceType(rawValue: 1 << 2)
  static let Delete = WsServiceType(rawValue: 1 << 3)
  
  // model
  static let Message = WsServiceType(rawValue: 1 << 4)
  static let Session = WsServiceType(rawValue: 1 << 5)
  static let Manager = WsServiceType(rawValue: 1 << 6)
  static let Channel = WsServiceType(rawValue: 1 << 7)
  static let UserChat = WsServiceType(rawValue: 1 << 8)
  static let Veil = WsServiceType(rawValue: 1 << 9)
  static let User = WsServiceType(rawValue: 1 << 10)
  
  let rawValue: Int
  init(rawValue: Int) { self.rawValue = rawValue }
  
  init?(string: String) {
    switch string {
    // event
    case "Create": self = WsServiceType.Create
    case "Update": self = WsServiceType.Update
    case "Delete": self = WsServiceType.Delete
    // type
    case "Message": self = WsServiceType.Message
    case "Session": self = WsServiceType.Session
    case "Manager": self = WsServiceType.Manager
    case "Channel": self = WsServiceType.Channel
    case "UserChat": self = WsServiceType.UserChat
    case "Veil": self = WsServiceType.Veil
    case "User" : self = WsServiceType.User
      
    default: return nil
    }
  }
}

class WsService {
  //MARK: Share Singleton Instance
  static let shared = WsService()
  let eventSubject = PublishSubject<String>()
  let readySubject = PublishSubject<String>()
  let typingSubject = PublishSubject<CHTypingEntity>()
  let messageOnCreateSubject = PublishSubject<CHMessage>()
 
  //MARK: Private properties
  fileprivate var socket: SocketIOClient!
  //#if DEBUG
  //fileprivate static let baseUrl = WSType.DEV.rawValue
  //#else
  var baseUrl = WSType.PRODUCTION.rawValue
  //#endif
  
  //move these properties into state
  fileprivate var currentChatId: String?
  fileprivate var currentChat: CHUserChat?
  fileprivate var heartbeatTimer: Timer?
  
  private var stopTypingThrottleFnc: ((CHUserChat?) -> Void)?
  private var startTypingThrottleFnc: ((CHUserChat?) -> Void)?
  
  init() {
    if let staging = CHUtils.getCurrentStage() {
      if staging == "PROD" {
        self.baseUrl = WSType.PRODUCTION.rawValue
      } else if staging == "ALPHA" {
        self.baseUrl = WSType.ALPHA.rawValue
      } else if staging == "BETA" {
        self.baseUrl = WSType.BETA.rawValue
      } else {
        // error
      }
    }
    
    self.stopTypingThrottleFnc = throttle(
      delay: 1.0,
      queue: DispatchQueue.global(qos: .background),
      action: self.stopTyping)
    
    self.startTypingThrottleFnc = throttle(
      delay: 1.0,
      queue: DispatchQueue.global(qos: .background),
      action: self.startTyping)
  }
  
  //MARK: Signals 
  
  //TODO: update to <String, Any?> to receive data
  func listen() -> PublishSubject<String> {
    return self.eventSubject
  }
  
  func ready() -> PublishSubject<String> {
    return self.readySubject
  }
  
  func typing() -> PublishSubject<CHTypingEntity> {
    return self.typingSubject
  }
  
  func mOnCreate() -> PublishSubject<CHMessage> {
    return self.messageOnCreateSubject
  }
  
  //MARK: Socket functionalities
  
  func connect() {
    dlog("Try to connect Socket")
    
    self.disconnect()
    self.socket = SocketIOClient(
      socketURL: URL(string: "\(self.baseUrl)")!,
      config: [
        .log(false),
        .forceWebsockets(true),
        .forcePolling(true),
        .reconnectAttempts(5),
        .reconnectWait(10)
      ])
    
    self.socket.removeAllHandlers()
    self.addSocketHandlers()
    self.socket.joinNamespace("/app")
    self.socket.connect()
  }
  
  func disconnect() {
    if self.socket != nil {
      self.socket.removeAllHandlers()
      self.socket.disconnect()
      self.socket = nil
      self.invalidateTimer()
      dlog("socket disconnect manually")
    }
  }
  
  /*
    Join and Leave is not restricted to use 
    but we intend to use it for only one userChat
  */
  func join(chatId: String?) {
    guard let chatId = chatId else { return }
    guard chatId != "" else { return }
    
    self.currentChatId = chatId
    
    if self.socket != nil {
      self.socket.emit(CHSocketRequest.join.value, "/user_chats/\(chatId)")
    }
  }
  
  func leave(chatId: String?) {
    guard let chatId = chatId else { return }
    guard chatId != "" else { return }
    
    self.currentChatId = ""

    if self.socket != nil {
      self.socket.emit(CHSocketRequest.leave.value, "/user_chats/\(chatId)")
    }
  }
  
  func sendTyping(chat: CHUserChat?, isStop: Bool) {
    guard let socket = self.socket, socket.status == .connected else { return }
    guard let chat = chat else { return }
    
    if isStop {
      self.stopTypingThrottleFnc?(chat)
    } else {
      self.startTypingThrottleFnc?(chat)
    }
  }
  
  func startTyping(chat: CHUserChat?) {
    guard let socket = self.socket, socket.status == .connected else { return }
    guard let chat = chat else { return }
    socket.emit("typing", CHTypingEntity(
      action: "start",
      chatId: chat.id,
      chatType: "UserChat")
    )
  }
  
  func stopTyping(chat: CHUserChat?) {
    guard let socket = self.socket, socket.status == .connected else { return }
    guard let chat = chat else { return }
    
    let entity = CHTypingEntity(
      action: "stop",
      chatId: chat.id,
      chatType: "UserChat")
    
    socket.emit("typing", entity)
    self.typingSubject.onNext(entity)
  }
  
  @objc func heartbeat() {
    dlog("heartbeat")
    if self.socket != nil {
      self.socket.emit(CHSocketRequest.heartbeat.value)
    } else {
      self.invalidateTimer()
    }
  }
  
  func invalidateTimer() {
    if self.heartbeatTimer != nil {
      self.heartbeatTimer!.invalidate()
      self.heartbeatTimer = nil
    }
  }
}

//MARK: Socket IO Handlers
fileprivate extension WsService {
  fileprivate func addSocketHandlers() {
    self.onCreate()
    self.onConnect()
    self.onReady()
    self.onUpdate()
    self.onDelete()
    self.onJoined()
    self.onLeaved()
    self.onPush()
    self.onTyping()
    self.onAuthenticated()
    self.onUnauthorized()
    self.onReconnectAttempt()
    self.onDisconnect()
    self.onError()
  }
  
  fileprivate func onConnect() {
    self.socket.on(CHSocketResponse.connected.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.connected.value)
      dlog("socket connected")
      mainStore.dispatch(SocketConnected())
      self?.emitAuth()
    }
  }
  
  fileprivate func onReady() {
    self.socket.on(CHSocketResponse.ready.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.ready.value)
      self?.readySubject.onNext(CHSocketResponse.ready.value)
      mainStore.dispatch(SocketReady())
      dlog("socket ready")
      
      if self?.currentChatId != "" {
        self?.join(chatId: self?.currentChatId)
      }
    }
  }
  
  fileprivate func onCreate() {
    self.socket.on(CHSocketResponse.create.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.create.value)
      dlog("socket on created")
      guard let data = data.get(index: 0) else { return }
      guard let json = JSON(rawValue: data) else { return }
      guard let type = WsServiceType(string: json["type"].stringValue) else { return }
      
      switch type {
      case WsServiceType.Session:
        guard let session = Mapper<CHSession>()
          .map(JSONObject: json["entity"].object) else { return }
        if let manager = Mapper<CHManager>()
          .map(JSONObject: json["refers"]["manager"].object) {
          mainStore.dispatch(UpdateManager(payload: manager))
        }
        
        mainStore.dispatch(CreateSession(payload: session))
        break
      case WsServiceType.UserChat:
        guard let userChat = Mapper<CHUserChat>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(CreateUserChat(payload: userChat))
        break
      case WsServiceType.Message:
        guard let message = Mapper<CHMessage>()
          .map(JSONObject: json["entity"].object) else { return }
        self?.messageOnCreateSubject.onNext(message)
        mainStore.dispatch(CreateMessage(payload: message))
        break
      default:
        break
      }
    }
  }
  
  fileprivate func onUpdate() {
    self.socket.on(CHSocketResponse.update.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.update.value)
      dlog("socket on update")
      guard let data = data.get(index: 0) else { return }
      guard let json = JSON(rawValue: data) else { return }
      guard let type = WsServiceType(string: json["type"].stringValue) else { return }
      
      switch type {
      case WsServiceType.Channel:
        guard let channel = Mapper<CHChannel>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(UpdateChannel(payload: channel))
  
      case WsServiceType.Session:
        guard let session = Mapper<CHSession>()
          .map(JSONObject: json["entity"].object) else { return }
        
        mainStore.dispatch(UpdateSession(payload: session))
        break
      case WsServiceType.UserChat:
        guard let userChat = Mapper<CHUserChat>()
          .map(JSONObject: json["entity"].object) else { return }
        if let lastMessage = Mapper<CHMessage>()
          .map(JSONObject: json["refers"]["message"].object) {
          mainStore.dispatch(UpdateMessage(payload: lastMessage))
        }
        if let manager = Mapper<CHManager>()
          .map(JSONObject: json["refers"]["manager"].object) {
          mainStore.dispatch(UpdateManager(payload: manager))
        }
        
        mainStore.dispatch(UpdateUserChat(payload: userChat))
        break
      case WsServiceType.Message:
        guard let message = Mapper<CHMessage>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(UpdateMessage(payload: message))
        break
      case WsServiceType.User:
        let user = Mapper<CHUser>()
          .map(JSONObject: json["entity"].object)
        mainStore.dispatch(UpdateGuest(payload: user))
        break
      case WsServiceType.Veil:
        let user = Mapper<CHVeil>()
          .map(JSONObject: json["entity"].object) 
        mainStore.dispatch(UpdateGuest(payload: user))
        break
      case WsServiceType.Manager:
        guard let manager = Mapper<CHManager>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(UpdateManager(payload: manager))
        break
      default:
        break
      }
    }
  }
  
  fileprivate func onDelete() {
    self.socket.on(CHSocketResponse.delete.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.delete.value)
      dlog("socket on delete")
      guard let data = data.get(index: 0) else { return }
      guard let json = JSON(rawValue: data) else { return }
      guard let type = WsServiceType(string: json["type"].stringValue) else { return }
      
      switch type {
      case WsServiceType.Session:
        guard let session = Mapper<CHSession>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(DeleteSession(payload: session))
        break
      case WsServiceType.UserChat:
        guard let userChat = Mapper<CHUserChat>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(DeleteUserChat(payload: userChat.id))
        break
      case WsServiceType.Message:
        guard let message = Mapper<CHMessage>()
          .map(JSONObject: json["entity"].object) else { return }
        mainStore.dispatch(DeleteMessage(payload: message))
        break
      default:
        break
      }
    }
  }
  
  fileprivate func onJoined() {
    self.socket.on(CHSocketResponse.joined.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.joined.value)
      dlog("socket joined: \(data)")
      
      guard let userChatId = data.get(index: 0) else { return }
      mainStore.dispatch(JoinedUserChat(payload: userChatId as! String))
    }
  }
  
  fileprivate func onLeaved() {
    self.socket.on(CHSocketResponse.leaved.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.leaved.value)
      dlog("socket leaved: \(data)")
      
      guard let userChatId = data.get(index: 0) else { return }
      mainStore.dispatch(LeavedUserChat(payload: userChatId as! String))
    }
  }
  
  fileprivate func onTyping() {
    self.socket.on(CHSocketResponse.typing.value) {  [weak self] (data, ack) in
      guard let entity = data.get(index: 0) else { return }
      guard let json = JSON(rawValue: entity) else { return }
      guard let typing = Mapper<CHTypingEntity>().map(JSONObject: json.object) else { return }
      self?.typingSubject.onNext(typing)
    }
  }
  
  fileprivate func onPush() {
    self.socket.on(CHSocketResponse.push.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.push.value)
      //dlog("socket pushed: \(data)")
      guard let entity = data.get(index: 0) else { return }
      guard let json = JSON(rawValue: entity) else { return }
      guard let push = Mapper<CHPush>().map(JSONObject: json.object) else { return }
      
      if mainStore.state.uiState.isChannelVisible {
        return
      }
      
      mainStore.dispatch(GetPush(payload: push))
    }
  }

  fileprivate func onAuthenticated() {
    self.socket.on(CHSocketResponse.authenticated.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.authenticated.value)
      dlog("socket authenticated")
      
      if let chatId = self?.currentChatId {
        self?.join(chatId: chatId)
      }
      
      if let s = self {
        dispatch {
          self?.heartbeatTimer = Foundation.Timer.scheduledTimer(
            timeInterval: 30,
            target: s,
            selector: #selector(WsService.heartbeat),
            userInfo: nil, repeats: true)
        }
      }
    }
  }
  
  fileprivate func onUnauthorized() {
    self.socket.on(CHSocketResponse.unauthorized.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.authenticated.value)
      dlog("unauthorized")
    }
  }
  
  fileprivate func onReconnectAttempt() {
    self.socket.on(CHSocketResponse.reconnect.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.reconnect.value)
      dlog("socket reconnect attempt")
      mainStore.dispatch(SocketReconnecting())
      self?.invalidateTimer()
    }
    
  }
  
  fileprivate func onDisconnect() {
    self.socket.on(CHSocketResponse.disconnect.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.disconnect.value)
      dlog("socket disconnected")
      mainStore.dispatch(SocketDisconnected())
    }
  }
  
  fileprivate func onError() {
    self.socket.on(CHSocketResponse.error.value) { [weak self] (data, ack) in
      self?.eventSubject.onNext(CHSocketResponse.error.value)
      dlog("socket error with data: \(data)")
      mainStore.dispatch(SocketDisconnected())
    }
  }
  
  fileprivate func emitAuth() {
    dlog("socket submitting auth")
    guard let channelId = PrefStore.getCurrentChannelId() else {
        //authentication cannot be completed due to missing data
        //mainStore.dispatch(WsError())
        return
    }
    
    let userId = PrefStore.getCurrentUserId()
    let veilId = PrefStore.getCurrentVeilId()
    if userId == nil  && veilId == nil {
      //error
      return
    }
    
    let guestId = (userId ?? "").isEmpty ? veilId : userId
    let guestType = (userId ?? "").isEmpty ? "Veil" : "User"
    
    let submission = [
      "type": "Plugin",
      "channelId": channelId,
      "guestId":  guestId,
      "guestType": guestType
    ]
    self.socket.emit("authentication", submission)
  }
}
