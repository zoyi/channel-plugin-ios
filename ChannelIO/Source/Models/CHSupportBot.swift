//
//  CHSupportBot.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHSupportBot {
  var id: String = ""
  var channelId: String = ""
  var pluginId: String = ""
  var target: [CHTargetCondition]? = nil
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
  var imageUrl: String = ""
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
