//
//  Manager.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
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
  var desc = ""
  var online = false
  
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
    online      <- map["online"]
  }
}

extension CHManager: Equatable {
  static func == (lhs:CHManager, rhs:CHManager) -> Bool {
    return lhs.id == rhs.id &&
      lhs.name == rhs.name &&
      lhs.avatarUrl == rhs.avatarUrl &&
      lhs.initial == rhs.initial &&
      lhs.color == rhs.color &&
      lhs.username == rhs.username &&
      lhs.online == rhs.online
  }
}
