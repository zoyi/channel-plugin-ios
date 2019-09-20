//
//  Veil.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHVeil: CHGuest, CHEntity {
  // ModelType
  var id = ""
  
  var name = ""
  var avatarUrl: String?
  var named = false
  var mobileNumber: String?
  
  var alert: Int? = 0
  var unread: Int? = 0
  var segment: String?
  var profile: [String : Any]?
  
  var country: String = ""
  var city: String = ""
  var locale: String = ""
  
  var createdAt: Date?
  var updatedAt: Date?
}

extension CHVeil: Mappable {
  init?(map: Map) { }
  
  init(id: String, name: String,
       avatarUrl: String?, named: Bool,
       mobileNumber: String?, profile: [String: Any]?) {
    self.id = id
    self.name = name
    self.avatarUrl = avatarUrl
    self.named = named
    self.mobileNumber = mobileNumber
    self.profile = profile
  }
  
  mutating func mapping(map: Map) {
    id              <- map["id"]
    name            <- map["name"]
    mobileNumber    <- map["mobileNumber"]
    avatarUrl       <- map["avatarUrl"]
    named           <- map["named"]
    alert           <- map["alert"]
    unread          <- map["unread"]
    segment         <- map["segment"]
    profile         <- map["profile"]
    country         <- map["country"]
    city            <- map["city"]
    locale          <- map["locale"]
    createdAt       <- (map["createdAt"], CustomDateTransform())
    updatedAt       <- (map["updatedAt"], CustomDateTransform())
  }
}

extension CHVeil: Equatable {}

func ==(lhs: CHVeil, rhs: CHVeil) -> Bool {
  return lhs.id == rhs.id
}
