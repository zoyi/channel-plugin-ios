//
//  CHBot.swift
//  CHPlugin
//
//  Created by Haeun Chung on 05/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ObjectMapper

struct CHBot : CHEntity {
  var id = ""
  var channelId = ""
  var name = ""
  var avatarUrl: String? = ""
  var initial = ""
  var color = ""
  var createdAt: Date? = nil
  
  var isDefaultBot: Bool = false
}

extension CHBot : Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id               <- map["id"]
    channelId        <- map["channelId"]
    name             <- map["name"]
    avatarUrl        <- map["avatarUrl"]
    initial          <- map["initial"]
    color            <- map["color"]
    createdAt        <- (map["createdAt"], CustomDateTransform())
  }
}

extension CHBot: Equatable {
  static func == (lhs:CHBot, rhs:CHBot) -> Bool {
    return lhs.id == rhs.id &&
      lhs.channelId == rhs.channelId &&
      lhs.name == rhs.name &&
      lhs.avatarUrl == rhs.avatarUrl &&
      lhs.initial == rhs.initial &&
      lhs.color == rhs.color
  }
}
