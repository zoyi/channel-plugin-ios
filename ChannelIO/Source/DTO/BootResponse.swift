//
//  BootResponse.swift
//  ChannelIO
//
//  Created by intoxicated on 15/11/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

struct BootResponse {
  var channel: CHChannel?
  var plugin: CHPlugin?
  var user: CHUser?
  var sessionJWT: String?
  var veilId: String?
}

extension BootResponse: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {}
  
  mutating func mapping(map: ObjectMapper_Map) {
    channel <- map["channel"]
    plugin <- map["plugin"]
    user <- map["user"]
    sessionJWT <- map["sessionJWT"]
    veilId <- map["veilId"]
  }
}
