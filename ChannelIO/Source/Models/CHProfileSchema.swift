//
//  CHProfileSchema.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

enum ProfileSchemaType: String {
  case string
  case number
  case boolean
  case date
  case list
}

struct CHProfileSchema {
  var id: String = ""
  var channelId: String = ""
  var key: String = ""
  var nameI18n: CHi18n? = nil
  var type: ProfileSchemaType = .string
  var visible:Bool = false
  var createdAt: Date? = nil
  var updatedAt: Date? = nil
}

extension CHProfileSchema: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    id                <- map["id"]
    channelId         <- map["channelId"]
    key               <- map["key"]
    nameI18n          <- map["nameI18n"]
    type              <- map["type"]
    visible           <- map["visible"]
    createdAt         <- (map["createdAt"], CustomDateTransform())
    updatedAt         <- (map["updatedAt"], CustomDateTransform())
  }
}
