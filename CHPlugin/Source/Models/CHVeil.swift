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
  // Entity
  var name = ""
  var avatarUrl: String?
  var initial = ""
  var color = ""
  // Guest
  var ghost = false
  var mobileNumber: String?
  var meta: [String : AnyObject]?

  //
  var alert = 0
  var unread = 0
}

extension CHVeil: Mappable {
  init?(map: Map) { }
  
  init(id: String, name: String,
       avatarUrl: String?, initial: String,
       color: String, ghost: Bool,
       mobileNumber: String?, meta: [String: AnyObject]?) {
    self.id = id
    self.name = name
    self.avatarUrl = avatarUrl
    self.initial = initial
    self.ghost = ghost
    self.mobileNumber = mobileNumber
    self.meta = meta
    self.color = color
  }
  
  mutating func mapping(map: Map) {
    id              <- map["id"]
    name            <- map["name"]
    avatarUrl       <- map["avatarUrl"]
    initial         <- map["initial"]
    color           <- map["color"]
    ghost           <- map["ghost"]
    mobileNumber    <- map["mobileNumber"]
    meta            <- map["meta"]
    
    alert           <- map["alert"]
    unread          <- map["unread"]
  }
}

extension CHVeil: Equatable {}

func ==(lhs: CHVeil, rhs: CHVeil) -> Bool {
  return lhs.id == rhs.id
}