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
  case open
  case following
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
  var followedBy: String = ""
  var hostId: String?
  var hostType: String?
  
  var appMessageId: String?
  var resolutionTime: Int = 0
  
  var readableUpdatedAt: String {
    if let updatedAt = self.lastMessage?.createdAt {
      return updatedAt.readableTimeStamp()
    }
    return ""
  }
  
  var name: String {
    if let host = self.lastTalkedHost {
      return host.name
    }
    
    return self.channel?.name ?? CHAssets.localized("ch.unknown")
  }

  // Dependencies
  var lastMessage: CHMessage?
  var session: CHSession?
  var lastTalkedHost: CHEntity?
  var channel: CHChannel?
  var hasRemoved: Bool = false
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
    state            <- map["state"]
    review           <- map["review"]
    createdAt        <- (map["createdAt"], CustomDateTransform())
    openedAt         <- (map["openedAt"], CustomDateTransform())
    followedAt       <- (map["followedAt"], CustomDateTransform())
    resolvedAt       <- (map["resolvedAt"], CustomDateTransform())
    closedAt         <- (map["closedAt"], CustomDateTransform())
    updatedAt        <- (map["appUpdatedAt"], CustomDateTransform())
    followedBy       <- map["followedBy"]
    appMessageId     <- map["appMessageId"]
    hostId           <- map["hostId"]
    hostType         <- map["hostType"]
    
    resolutionTime   <- map["resolutionTime"]
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
    if self.isLocalChat() {
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
      let signal = self.isLocalChat() ?
        Observable.just(nil) :
        UserChatPromise.setMessageRead(userChatId: self.id)
          
      let dispose = signal.subscribe(onNext: { (_) in
        if self.isLocalChat() {
          let guest = personSelector(
            state: mainStore.state,
            personType: self.personType,
            personId: self.personId
          ) as? CHGuest
          mainStore.dispatch(UpdateGuestWithLocalRead(guest:guest, session:self.session))
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
  func isLocalChat() -> Bool {
    return self.id.hasPrefix(CHConstants.local)
  }
  
  func isNudgeChat() -> Bool {
    return self.id.hasPrefix(CHConstants.nudgeChat)
  }
  
  func getNudgeId() -> String {
    return self.id.components(separatedBy: CHConstants.nudgeChat).last ?? ""
  }
  
  func isActive() -> Bool {
    return self.state != .closed && self.state != .solved && self.state != .removed
  }
  
  func isClosed() -> Bool {
    return self.state == .closed
  }
  
  func isRemoved() -> Bool {
    return self.state == .removed
  }
  
  func isSolved() -> Bool {
    return self.state == .solved
  }
  
  func isCompleted() -> Bool {
    return self.state == .closed || self.state == .solved || self.state == .removed
  }
  
  func isReadyOrOpen() -> Bool {
    return self.state == .ready || self.state == .open
  }
  
  func isOpen() -> Bool {
    return self.state == .open
  }
  
  func isReady() -> Bool {
    return self.state == .ready
  }
  
  func isEngaged() -> Bool {
    return self.state == .solved || self.state == .closed || self.state == .following
  }
  
  func isSupporting() -> Bool {
    return self.state == .supporting
  }

  static func becomeActive(current: CHUserChat?, next: CHUserChat?) -> Bool {
    guard let current = current, let next = next else { return false }
    return current.isReadyOrOpen() && !next.isReadyOrOpen()
  }
  
  static func becomeOpen(current: CHUserChat?, next: CHUserChat?) -> Bool {
    guard let current = current, let next = next else { return false }
    return current.isSolved() && next.isReadyOrOpen()
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
    
    let session = CHSession(id: chatId, chatId: chatId, guest: mainStore.state.guest, alert: 1)
    let userChat = CHUserChat(chatId: chatId, lastMessageId: message.id)
    return (userChat, message, session)
  }
}

extension CHUserChat: Equatable {
  static func ==(lhs: CHUserChat, rhs: CHUserChat) -> Bool {
    return lhs.id == rhs.id &&
      lhs.session?.alert == rhs.session?.alert &&
      lhs.state == rhs.state &&
      lhs.lastMessage == rhs.lastMessage
  }
}

