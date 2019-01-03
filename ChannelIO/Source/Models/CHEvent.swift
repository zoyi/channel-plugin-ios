//
//  CHEvent.swift
//  CHPlugin
//
//  Created by Haeun Chung on 28/08/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

enum CHDefaultEvent: String {
  case boot = "Boot"
  case open = "ChannelOpen"
  case pageView = "PageView"
}

struct CHEvent {
  var id: String = ""
  var channelId: String = ""
  var personId: String = ""
  var personType: String = ""
  var name: String = ""
  var properties: [String: AnyObject] = [:]
  var sysProperties: [String: AnyObject] = [:]
  var createdAt: Date
  var expireAt: Date
}

extension CHEvent {
  static func send(
    pluginId: String,
    name: String,
    properties: [String: Any?]? = nil,
    sysProperties: [String: Any?]? = nil) -> Observable<(CHEvent, [CHNudge])> {
    return EventPromise.sendEvent(pluginId: pluginId, name: name, properties: properties, sysProperties: sysProperties)
  }
}

extension CHEvent: Mappable {
  init?(map: Map) {
    self.createdAt = Date()
    self.expireAt = Date()
  }
  
  mutating func mapping(map: Map) {
    id              <- map["id"]
    channelId       <- map["channelId"]
    personId        <- map["personId"]
    personType      <- map["personType"]
    name            <- map["name"]
    properties      <- map["property"]
    sysProperties   <- map["sysProperty"]
    createdAt       <- (map["createdAt"], CustomDateTransform())
    expireAt        <- (map["updatedAt"], CustomDateTransform())
  }
}
