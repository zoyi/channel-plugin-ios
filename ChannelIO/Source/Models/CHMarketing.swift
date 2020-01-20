//
//  CHMarketing.swift
//  ChannelIO
//
//  Created by Jam on 2020/01/20.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import ObjectMapper

struct CHMarketing {
  var type: String = ""
  var id: String = ""
  var enableSupportBot: String = ""
  var advertising: Bool = false
  var exposureType: InAppNotificationType = .banner
}

extension CHMarketing: Mappable {
  init?(map: Map) { }

  mutating func mapping(map: Map) {
    type              <- map["type"]
    id                <- map["id"]
    enableSupportBot  <- map["enableSupportBot"]
    advertising       <- map["advertising"]
    exposureType      <- map["exposureType"]
  }
}

extension CHMarketing: Equatable {
  static func == (lhs: CHMarketing, rhs: CHMarketing) -> Bool {
    return lhs.type == rhs.type &&
      lhs.id == rhs.id &&
      lhs.enableSupportBot == rhs.enableSupportBot &&
      lhs.advertising == rhs.advertising &&
      lhs.exposureType == rhs.exposureType
  }
}
