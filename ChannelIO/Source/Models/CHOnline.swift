//
//  CHOnline.swift
//  ChannelIO
//
//  Created by intoxicated on 18/11/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

struct CHOnline {
  var channelId = ""
  var personType: PersonType!
  var personId = ""
  var createdAt = Date()
  var updatedAt = Date()
}

extension CHOnline: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }

  mutating func mapping(map: ObjectMapper_Map) {
    channelId <- map["channelId"]
    personType <- map["personType"]
    personId <- map["personId"]
    createdAt <- (map["createdAt"], CustomDateTransform())
    updatedAt <- (map["updatedAt"], CustomDateTransform())
  }
}

extension CHOnline: Equatable {
  static func == (lhs: CHOnline, rhs: CHOnline) -> Bool {
    return lhs.channelId == rhs.channelId &&
      lhs.personType == rhs.personType &&
      lhs.personId == rhs.personId &&
      lhs.updatedAt == rhs.updatedAt
  }
}
