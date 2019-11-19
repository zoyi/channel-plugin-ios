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
  var personType: PersonType!
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
    property: [String: Any?]? = nil,
    sysProperty: [String: Any?]? = nil) -> Observable<CHEvent> {
    return EventPromise.sendEvent(
      pluginId: pluginId,
      name: name,
      property: property,
      sysProperty: sysProperty
    )
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
