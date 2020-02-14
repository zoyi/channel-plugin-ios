//
//  UserChat.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

enum ReviewType: String {
  case like
  case dislike
}

enum UserChatState: String {
  case unassigned
  case assigned
  case holding
  case solved
  case closed
  case trash
}

enum ChatType: String {
  case userChat = "userChat"

  init?(_ type: String?) {
    guard let type = type else { return nil }
    switch type {
    case "UserChat": self = .userChat
    default: return nil
    }
  }
}

enum PersonType: String {
  case manager = "manager"
  case user = "user"
  case bot = "bot"

  init?(_ type: String?) {
    guard let type = type else { return nil }
    switch type {
    case "Manager": self = .manager
    case "User": self = .user
    case "Bot": self = .bot
    default: return nil
    }
  }
}

enum ChatHandlingStatus: String {
  case support
}

struct CHUserChat: ModelType {
  // ModelType
  var id = ""
  // UserChat
  var userId: String = ""
  var channelId: String = ""
  var name: String = ""
  var state: UserChatState?
  var review: String = ""
  var createdAt: Date?
  var openedAt: Date?
  var updatedAt: Date?
  var followedAt: Date?
  var resolvedAt: Date?
  var closedAt: Date?
  var assigneeId: String? = nil
  var managerIds: [String] = []
  var handling: ChatHandlingStatus?
  var frontMessageId: String?
  var resolutionTime: Int = 0
  var askedAt: Date?
  var firstOpenedAt: Date?
  
  // Dependencies
  var lastMessage: CHMessage?
  var session: CHSession?
  var channel: CHChannel?
  var hasRemoved: Bool = false
  
  var assignee: CHEntity? {
    return personSelector(
      state: mainStore.state,
      personType: .manager,
      personId: self.assigneeId
    )
  }
  
  var readableUpdatedAt: String {
    if let updatedAt = self.lastMessage?.createdAt {
      return updatedAt.readableTimeStamp()
    }
    return ""
  }
}

extension CHUserChat: Mappable {
  init?(map: Map) {}
  
  init(chatId: String, lastMessageId: String) {
    self.id = chatId
    self.state = nil
    self.frontMessageId = lastMessageId
    self.createdAt = Date()
    self.updatedAt = Date()
  }
  
  mutating func mapping(map: Map) {
    id                <- map["id"]
    userId            <- map["userId"]
    name              <- map["name"]
    channelId         <- map["channelId"]
    managerIds        <- map["managerIds"]
    review            <- map["review"]
    createdAt         <- (map["createdAt"], CustomDateTransform())
    openedAt          <- (map["openedAt"], CustomDateTransform())
    followedAt        <- (map["followedAt"], CustomDateTransform())
    resolvedAt        <- (map["resolvedAt"], CustomDateTransform())
    closedAt          <- (map["closedAt"], CustomDateTransform())
    updatedAt         <- (map["frontUpdatedAt"], CustomDateTransform())
    askedAt           <- (map["askedAt"], CustomDateTransform())
    firstOpenedAt     <- (map["firstOpenedAt"], CustomDateTransform())
    handling          <- map["handling"]
    frontMessageId    <- map["frontMessageId"]
    assigneeId        <- map["assigneeId"]
    resolutionTime    <- map["resolutionTime"]
    state             <- map["state"]
    
    self.updatedAt = self.updatedAt ?? self.createdAt
  }
}

//TODO: Refactor to AsyncActionCreator
extension CHUserChat {
  static func get(userChatId: String) -> Observable<ChatResponse> {
    return UserChatPromise.getChat(userChatId: userChatId)
  }
  
  static func getChats(
    since: String? = nil,
    showCompleted: Bool = false) -> Observable<[String: Any?]> {
    return UserChatPromise.getChats(since: since, limit: 30, showCompleted: showCompleted)
  }
  
  static func getMessages(
    userChatId: String,
    since: String,
    limit: Int,
    sortOrder:String) -> Observable<[String: Any]> {
    
    return UserChatPromise.getMessages(
      userChatId: userChatId,
      since: since,
      limit: limit,
      sortOrder: sortOrder)
  }
  
  static func create() -> Observable<ChatResponse>{
    return UserChatPromise.createChat(
      pluginId: mainStore.state.plugin.id,
      url: ChannelIO.hostTopControllerName ?? ""
    )
  }

  func remove() -> Observable<Any?> {
    if self.isLocal {
      return .just(nil)
    }
    return UserChatPromise.remove(userChatId: self.id)
  }
  
  func close(actionId: String, requestId: String = "") -> Observable<CHUserChat> {
    return UserChatPromise.close(
      userChatId: self.id,
      actionId: actionId,
      requestId: requestId
    )
  }
  
  func review(
    actionId: String,
    rating: ReviewType,
    requestId: String) -> Observable<CHUserChat> {
    return UserChatPromise.review(
      userChatId: self.id,
      actionId: actionId,
      rating: rating,
      requestId: requestId
    )
  }
  
  func shouldRequestRead(otherChat: CHUserChat?) -> Bool {
    guard let otherChat = otherChat else { return false }
    return (self.updatedAt?.miliseconds != otherChat.updatedAt?.miliseconds) ||
      (self.session?.alert != otherChat.session?.alert)
  }
  
  func read() {
    guard self.session != nil else { return }
    
    _ = UserChatPromise.setMessageRead(userChatId: self.id)
      .subscribe(onNext: { (_) in
        mainStore.dispatch(ReadSession(payload: self.session))
      }, onError: { (error) in
        
      })
  }
  
  func read() -> Observable<Bool> {
    return Observable.create({ (subscriber) in
      let signal = self.isLocal ?
        Observable.just(nil) :
        UserChatPromise.setMessageRead(userChatId: self.id)
          
      let dispose = signal.subscribe(onNext: { (_) in
        if self.isLocal {
          let user = userSelector(state: mainStore.state)
          mainStore.dispatch(UpdateUserWithLocalRead(user:user, session:self.session))
        } else {
          mainStore.dispatch(ReadSession(payload: self.session))
        }
        subscriber.onNext(true)
        subscriber.onCompleted()
      }, onError: { (error) in
        subscriber.onNext(false)
        subscriber.onCompleted()
      })
      
      return Disposables.create {
        dispose.dispose()
      }
    })
  }
}

extension CHUserChat {
  var isLocal: Bool {
    return self.id.hasPrefix(CHConstants.local)
  }
  
  var isActive: Bool {
    return self.state != .closed && self.state != .solved && self.state != .trash
  }
  
  var isClosed: Bool {
    return self.state == .closed
  }
  
  var isRemoved: Bool {
    return self.state == .trash
  }
  
  var isSolved: Bool {
    return self.state == .solved
  }
  
  var isCompleted: Bool {
    return self.state == .closed || self.state == .solved || self.state == .trash
  }
  
  var isReadyOrOpen: Bool {
    return self.state == nil || self.state == .unassigned
  }
  
  var isUnassigned: Bool {
    return self.state == .unassigned
  }
  
  var isReady: Bool {
    return self.state == nil && self.handling == nil
  }
  
  var isEngaged: Bool {
    return self.state == .solved || self.state == .closed || self.state == .assigned
  }
  
  var isSupporting: Bool {
    return self.state == nil && self.handling == .support
  }

  static func becomeActive(current: CHUserChat?, next: CHUserChat?) -> Bool {
    guard let current = current, let next = next else { return false }
    return current.isReadyOrOpen && !next.isReadyOrOpen
  }
  
  static func becomeOpen(current: CHUserChat?, next: CHUserChat?) -> Bool {
    guard let current = current, let next = next else { return false }
    return current.isSolved && next.isReadyOrOpen
  }
}

extension CHUserChat: Equatable {
  static func ==(lhs: CHUserChat, rhs: CHUserChat) -> Bool {
    return lhs.id == rhs.id &&
      lhs.session?.alert == rhs.session?.alert &&
      lhs.state == rhs.state &&
      lhs.lastMessage == rhs.lastMessage &&
      lhs.assigneeId == rhs.assigneeId &&
      lhs.resolutionTime == rhs.resolutionTime
  }
}

