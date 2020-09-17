//
//  CHProfileBot.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/16/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit

struct CHProfileItem {
  var id            : String = ""
  var key           : String = ""
  var type          : ProfileSchemaType = .string
  var name          : String = ""
  var value         : Any? = nil
  
  var fieldType     : ProfileInputType = .text
}

extension CHProfileItem: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    id              <- map["id"]
    key             <- map["key"]
    type            <- map["type"]
    name            <- map["name"]
    value           <- map["value"]
    
    if key == "mobileNumber" {
      fieldType = .mobileNumber
    } else if key == "email" {
      fieldType = .email
    } else if type == .number {
      fieldType = .number
    } else {
      fieldType = .text
    }
  }
}

extension CHProfileItem: Equatable {}

func ==(lhs: CHProfileItem, rhs: CHProfileItem) -> Bool {
  let lv = "\(lhs.value ?? 0)"
  let hv = "\(rhs.value ?? 0)"
  
  return lhs.id == rhs.id &&
    lhs.key == rhs.key &&
    lhs.name == rhs.name &&
    lv == hv
}
