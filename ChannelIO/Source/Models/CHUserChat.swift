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

struct CHUserChat: ModelType {
  // ModelType
  var id = ""
  // UserChat
  var personType: String = ""
  var personId: String = ""
  var channelId: String = ""
  var bindFromId: String = ""
  var state: String = ""
  var review: String = ""
  var createdAt: Date?
  var openedAt: Date?
  var updatedAt: Date?
  var followedAt: Date?
  var resolvedAt: Date?
  var followedBy: String = ""
  var hostId: String?
  var hostType: String?
  
  var lastMessageId: String?
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
}

extension CHUserChat: Mappable {
  init?(map: Map) {}
  
  mutating func mapping(map: Map) {
    id               <- map["id"]
    personType       <- map["personType"]
    personId         <- map["personId"]
    channelId        <- map["channelId"]
    bindFromId       <- map["bindFromId"]
    state            <- map["state"]
    review           <- map["review"]
    createdAt        <- (map["createdAt"], CustomDateTransform())
    openedAt         <- (map["openedAt"], CustomDateTransform())
    followedAt       <- (map["followedAt"], CustomDateTransform())
    resolvedAt       <- (map["resolvedAt"], CustomDateTransform())
    updatedAt        <- (map["updatedAt"], CustomDateTransform())
    followedBy       <- map["followedBy"]
    lastMessageId    <- map["lastMessageId"]
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
  
  static func getChats(
    since: Int64?=nil,
    sortOrder: String,
    showCompleted: Bool = false) -> Observable<[String: Any?]> {
    return UserChatPromise.getChats(
      since: since,
      limit: 30,
      sortOrder: sortOrder,
      showCompleted: showCompleted)
  }
  
  static func create(pluginId: String, timeStamp: Date?) -> Observable<ChatResponse>{
    return UserChatPromise.createChat(pluginId: pluginId, timeStamp: timeStamp)
  }
  
  func remove() -> Observable<Any?> {
    return UserChatPromise.remove(userChatId: self.id)
  }
  
  func feedback(rating: String) -> Observable<ChatResponse> {
    return UserChatPromise.done(userChatId: self.id, rating: rating)
  }
  
  func readAll() -> Observable<Bool> {
    return Observable.create({ (subscriber) in
      let signal = UserChatPromise.setMessageReadAll(userChatId: self.id)
        .subscribe(onNext: { (_) in
          self.readAllManually()
          subscriber.onNext(true)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onNext(false)
          subscriber.onCompleted()
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func readAllManually() {
    guard var session = self.session else { return }
    session.unread = 0
    session.alert = 0
    mainStore.dispatch(UpdateSession(payload: session))
  }
}

extension CHUserChat {
  func isActive() -> Bool {
    return self.state != "closed" && self.state != "resolved"
  }
  
  func isClosed() -> Bool {
    return self.state == "closed"
  }
  
  func isResolved() -> Bool {
    return self.state == "resolved"
  }
  
  func isRemoved() -> Bool {
    return self.state == "removed"
  }
  
  func isCompleted() -> Bool {
    return self.state == "closed" || self.state == "resolved" || self.state == "removed"
  }
  
  func isReadyOrOpen() -> Bool {
    return self.state == "ready" || self.state == "open"
  }
  
  func isOpen() -> Bool {
    return self.state == "open"
  }
  
  func isEngaged() -> Bool {
    return self.state == "resolved" || self.state == "closed" || self.state == "following"
  }
}

extension CHUserChat: Equatable {
  static func ==(lhs: CHUserChat, rhs: CHUserChat) -> Bool {
    return lhs.id == rhs.id &&
      lhs.session?.alert == rhs.session?.alert &&
      lhs.lastMessage?.lastMessage == rhs.lastMessage?.lastMessage &&
      lhs.state == rhs.state
  }
}

