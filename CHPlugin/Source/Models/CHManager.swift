//
//  Manager.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHManager: CHEntity {
  // ModelType
  var id = ""
  // Person
  var name = ""
  // Avatar
  var avatarUrl: String?
  var initial = ""
  var color = ""
  // Manager
  var username = ""
  
  var key: String {
    get {
      return "Manager:\(self.id)"
    }
  }
}

extension CHManager: Mappable {
  init?(map: Map) {

  }
  mutating func mapping(map: Map) {
    id          <- map["id"]
    name        <- map["name"]
    avatarUrl   <- map["avatarUrl"]
    initial     <- map["initial"]
    color       <- map["color"]
    username    <- map["username"]
  }
}

struct ReviewAvatar: CHEntity {
  var id = ""
  var name = CHAssets.localized("ch.review.name")
  var avatarUrl: String? = "reviewAvatar"
  var initial = ""
  var color = ""
  // Manager
  var username = ""
}
