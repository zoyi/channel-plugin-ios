//
//  BootResponse.swift
//  ChannelIO
//
//  Created by intoxicated on 15/11/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import ObjectMapper

struct BootResponse {
  var channel: CHChannel?
  var plugin: CHPlugin?
  var user: CHUser?
  var sessionJWT: String?
  var veilId: String?
}

extension BootResponse: Mappable {
  init?(map: Map) {}
  
  mutating func mapping(map: Map) {
    channel <- map["channel"]
    plugin <- map["plugin"]
    user <- map["user"]
    sessionJWT <- map["sessionJWT"]
    veilId <- map["veilId"]
  }
}
