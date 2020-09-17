//
//  CHEvent.swift
//  CHPlugin
//
//  Created by Haeun Chung on 28/08/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

enum CHDefaultEvent: String {
  case boot = "Boot"
  case open = "ChannelOpen"
  case pageView = "PageView"
}

struct CHEvent {
  var id: String = ""
  var userId: String = ""
  var channelId: String = ""
  var name: String = ""
  var properties: [String: AnyObject] = [:]
  var createdAt: Date
  var expireAt: Date
}

extension CHEvent {
  static func send(
    pluginId: String,
    name: String,
    property: [String: Any?]? = nil) -> Observable<CHEvent> {
    return EventPromise.sendEvent(
      pluginId: pluginId,
      name: name,
      property: property
    )
  }
}

extension CHEvent: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {
    self.createdAt = Date()
    self.expireAt = Date()
  }
  
  mutating func mapping(map: ObjectMapper_Map) {
    id              <- map["id"]
    channelId       <- map["channelId"]
    userId          <- map["userId"]
    name            <- map["name"]
    properties      <- map["property"]
    createdAt       <- (map["createdAt"], CustomDateTransform())
    expireAt        <- (map["updatedAt"], CustomDateTransform())
  }
}
