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
  case ready
  case supporting
  case unassigned
  case assigned
  case holding
  case solved
  case closed
  case removed
}

struct CHUserChat: ModelType {
  // ModelType
  var id = ""
  // UserChat
  var personType: String = ""
  var personId: String = ""
  var channelId: String = ""
  var state: UserChatState = .ready
  var review: String = ""
  var createdAt: Date?
  var openedAt: Date?
  var updatedAt: Date?
  var followedAt: Date?
  var resolvedAt: Date?
  var closedAt: Date?
  var assigneeId: String? = nil
  var assigneeType: String? = nil
  
  var appMessageId: String?
  var resolutionTime: Int = 0
  
  // Dependencies
  var lastMessage: CHMessage?
  var session: CHSession?
  var channel: CHChannel?
  var hasRemoved: Bool = false
  
  var assignee: CHEntity? {
    return personSelector(state: mainStore.state, personType: self.assigneeType, personId: self.assigneeId)
  }
  
  var readableUpdatedAt: String {
    if let updatedAt = self.lastMessage?.createdAt {
      return updatedAt.readableTimeStamp()
    }
    return ""
  }
  
  var name: String {
    if let host = self.assignee {
      return host.name
    }
    
    return self.channel?.name ?? CHAssets.localized("ch.unknown")
  }
}

extension CHUserChat: Mappable {
  init?(map: Map) {}
  
  init(chatId: String, lastMessageId: String) {
    self.id = chatId
    self.state = .ready
    self.appMessageId = lastMessageId
    self.createdAt = Date()
    self.updatedAt = Date()
  }
  
  mutating func mapping(map: Map) {
    id               <- map["id"]
    personType       <- map["personType"]
    personId         <- map["personId"]
    channelId        <- map["channelId"]
    review           <- map["review"]
    createdAt        <- (map["createdAt"], CustomDateTransform())
    openedAt         <- (map["openedAt"], CustomDateTransform())
    followedAt       <- (map["followedAt"], CustomDateTransform())
    resolvedAt       <- (map["resolvedAt"], CustomDateTransform())
    closedAt         <- (map["closedAt"], CustomDateTransform())
    updatedAt        <- (map["appUpdatedAt"], CustomDateTransform())
    appMessageId     <- map["appMessageId"]
    assigneeId       <- map["assigneeId"]
    assigneeType     <- map["assigneeType"]
    resolutionTime   <- map["resolutionTime"]
    
    if let s = map["stateV2"].currentValue as? String {
      state <- map["stateV2"]
    } else {
      state <- map["state"]
    }
  }
}

//TODO: Refactor to AsyncActionCreator
extension CHUserChat {
  
  static func get(userChatId: String) -> Observable<ChatResponse> {
    return UserChatPromise.getChat(userChatId: userChatId)
  }
  
  static func getChats(since: Int64?=nil, showCompleted: Bool = false) -> Observable<[String: Any?]> {
    return UserChatPromise.getChats(since: since, limit: 30, showCompleted: showCompleted)
  }
  
  static func create(pluginId: String) -> Observable<ChatResponse>{
    return UserChatPromise.createChat(pluginId: pluginId)
  }

  func remove() -> Observable<Any?> {
    if self.isLocal {
      return .just(nil)
    }
    return UserChatPromise.remove(userChatId: self.id)
  }
  
  func close(mid: String, requestId: String = "") -> Observable<CHUserChat> {
    return UserChatPromise.close(userChatId: self.id, formId: mid, requestId: requestId)
  }
  
  func review(mid: String, rating: ReviewType, requestId: String) -> Observable<CHUserChat> {
    return UserChatPromise.review(userChatId: self.id, formId: mid, rating: rating, requestId: requestId)
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
          let user = userSelector(state: mainStore.stae)
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
  
  var fromNudge: Bool {
    return self.id.hasPrefix(CHConstants.nudgeChat)
  }
  
  var nudgeId: String? {
    return self.id.components(separatedBy: CHConstants.nudgeChat).last
  }
  
  var isActive: Bool {
    return self.state != .closed && self.state != .solved && self.state != .removed
  }
  
  var isClosed: Bool {
    return self.state == .closed
  }
  
  var isRemoved: Bool {
    return self.state == .removed
  }
  
  var isSolved: Bool {
    return self.state == .solved
  }
  
  var isCompleted: Bool {
    return self.state == .closed || self.state == .solved || self.state == .removed
  }
  
  var isReadyOrOpen: Bool {
    return self.state == .ready || self.state == .unassigned
  }
  
  var isUnassigned: Bool {
    return self.state == .unassigned
  }
  
  var isReady: Bool {
    return self.state == .ready
  }
  
  var isEngaged: Bool {
    return self.state == .solved || self.state == .closed || self.state == .assigned
  }
  
  var isSupporting: Bool {
    return self.state == .supporting
  }

  static func becomeActive(current: CHUserChat?, next: CHUserChat?) -> Bool {
    guard let current = current, let next = next else { return false }
    return current.isReadyOrOpen && !next.isReadyOrOpen
  }
  
  static func becomeOpen(current: CHUserChat?, next: CHUserChat?) -> Bool {
    guard let current = current, let next = next else { return false }
    return current.isSolved && next.isReadyOrOpen
  }
  
  static func createLocal(writer: CHEntity?, variant: CHNudgeVariant?) -> (CHUserChat?, CHMessage?, CHSession?) {
    guard let writer = writer, let variant = variant else { return (nil, nil, nil) }
    let file = variant.attachment == .image ?
      CHFile.create(imageable: variant) : nil
    let button = variant.attachment == .button ?
      [CHLink(title: variant.buttonTitle ?? "", url: variant.buttonRedirectUrl ?? "")] : nil
    let chatId = CHConstants.nudgeChat + variant.nudgeId
    let message = CHMessage(
      chatId: chatId,
      entity: writer,
      title: variant.title,
      message: variant.message,
      file: file,
      buttons: button)
    
    let session = CHSession(id: chatId, chatId: chatId, user: mainStore.state.user, alert: 1)
    let userChat = CHUserChat(chatId: chatId, lastMessageId: message.id)
    return (userChat, message, session)
  }
}

extension CHUserChat: Equatable {
  static func ==(lhs: CHUserChat, rhs: CHUserChat) -> Bool {
    return lhs.id == rhs.id &&
      lhs.session?.alert == rhs.session?.alert &&
      lhs.state == rhs.state &&
      lhs.lastMessage == rhs.lastMessage &&
      lhs.assigneeId == rhs.assigneeId &&
      lhs.assigneeType == rhs.assigneeType &&
      lhs.resolutionTime == rhs.resolutionTime
  }
}

