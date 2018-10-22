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

struct CHSupportBot {
  var id: String = ""
  var channelId: String = ""
  var pluginId: String = ""
  var target: [CHTargetCondition]? = nil

  static func getBots(with pluginId: String, fetch: Bool) -> Observable<[CHSupportBot]> {
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
        subscriber.onNext([])
        subscriber.onCompleted()
      }
      
      return Disposables.create {
        disposable?.dispose()
      }
    })
  }
  
  static func reply(with userChatId: String?, formId: String?, key: String?) -> Observable<CHMessage> {
    return SupportBotPromise.replySupportBot(userChatId: userChatId, formId: formId, key: key)
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

struct CHSupportBotStep {
  var id: String = ""
  var message: String = ""
  var imageMeta: CHImageMeta? = nil
  var imageUrl: String? = nil
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
  let step: CHSupportBotStep?
  let actions: [CHSupportBotAction]
}
