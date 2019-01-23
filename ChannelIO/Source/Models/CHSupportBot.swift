//
//  CHSupportBot.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

protocol CHEvaluatable {
  var target: [[CHTargetCondition]]? { get set }
}

struct CHSupportBot: CHEvaluatable {
  var id: String = ""
  var channelId: String = ""
  var pluginId: String = ""
  var target: [[CHTargetCondition]]? = nil
}

extension CHSupportBot {
  static func getBots(with pluginId: String, fetch: Bool) -> Observable<CHSupportBotEntryInfo> {
    return Observable.create({ (subscriber) -> Disposable in
      var disposable: Disposable?
      if fetch {
        disposable = SupportBotPromise.getSupportBots(pluginId: pluginId)
          .subscribe(onNext: { (bots) in
            dlog("fetched support bot")
            subscriber.onNext(bots)
            subscriber.onCompleted()
          }, onError: { (error) in
            subscriber.onError(error)
          })
      } else {
        subscriber.onNext(CHSupportBotEntryInfo())
        subscriber.onCompleted()
      }
      
      return Disposables.create {
        disposable?.dispose()
      }
    })
  }
  
  static func reply(with userChatId: String?, actionId: String?, buttonId: String?, requestId: String? = nil) -> Observable<CHMessage> {
    return SupportBotPromise.replySupportBot(userChatId: userChatId, actionId: actionId, buttonId: buttonId, requestId: requestId)
  }
  
  static func reply(with message: CHMessage, actionId: String? = nil) -> Observable<CHMessage> {
    let actionId = actionId ?? message.id
    
    return SupportBotPromise.replySupportBot(
      userChatId: message.chatId,
      actionId: actionId,
      buttonId: message.submit?.key,
      requestId: message.requestId)
  }
  
  static func create(with botId: String) -> Observable<ChatResponse> {
    return SupportBotPromise.createSupportBotUserChat(supportBotId: botId)
  }
}

extension CHSupportBot: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id            <- map["id"]
    channelId     <- map["channelId"]
    pluginId      <- map["pluginId"]
    target        <- map["target"]
  }
}

struct CHSupportBotStep: CHImageable {
  var id: String = ""
  var message: String = ""
  var imageMeta: CHImageMeta? = nil
  var imageUrl: String? = nil
  var imageRedirectUrl: String? = nil
}

extension CHSupportBotStep: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id            <- map["id"]
    message       <- map["message"]
    imageMeta     <- map["imageMeta"]
    imageUrl      <- map["imageUrl"]
  }
}

struct CHSupportBotAction {
  var id: String = ""
  var key: String = ""
  var text: String = ""
}

extension CHSupportBotAction: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id            <- map["id"]
    key           <- map["key"]
    text          <- map["text"]
  }
}

struct CHSupportBotEntryInfo {
  let supportBot: CHSupportBot? = nil
  let step: CHSupportBotStep? = nil
  let actions: [CHSupportBotAction] = []
}
