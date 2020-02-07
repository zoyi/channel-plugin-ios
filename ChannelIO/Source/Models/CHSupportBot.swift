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

extension CHSupportBot: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id            <- map["id"]
    channelId     <- map["channelId"]
    pluginId      <- map["pluginId"]
    target        <- map["target"]
  }
}

extension CHSupportBot {
  static func reply(with message: CHMessage, actionId: String? = nil) -> Observable<CHMessage> {
    let actionId = actionId ?? message.id
    
    return SupportBotPromise.replySupportBot(
      userChatId: message.chatId,
      actionId: actionId,
      buttonKey: message.submit?.key,
      requestId: message.requestId)
  }
  
  static func create(with botId: String) -> Observable<ChatResponse> {
    return SupportBotPromise.createSupportBotUserChat(
      supportBotId: botId,
      url: ChannelIO.hostTopControllerName ?? ""
    )
  }
}

struct CHSupportBotStep {
  var id: String = ""
  var message: CHMessage?
}

extension CHSupportBotStep: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id            <- map["id"]
    message       <- map["message"]
  }
}

struct CHSupportBotEntryInfo {
  var supportBot: CHSupportBot? = nil
  var step: CHSupportBotStep? = nil
  var buttons: [CHActionButton] = []
  
  init() { }
  
  init(
    supportBot: CHSupportBot?,
    step: CHSupportBotStep?,
    buttons: [CHActionButton] = []) {
    self.supportBot = supportBot
    self.step = step
    self.buttons = buttons
  }
}

extension CHSupportBotEntryInfo: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    supportBot      <- map["supportBot"]
    step            <- map["step"]
    buttons         <- map["buttons"]
  }
}
