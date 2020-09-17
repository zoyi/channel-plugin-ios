//
//  Manager.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

struct CHManager: CHEntity {
  // ModelType
  var id = ""
  // Person
  var name = ""
  // Avatar
  var avatarUrl: String?

  // Manager
  var username = ""
  var mobileNumber: String?
  var desc = ""
  var online: CHOnline?
  
  //local
  var color = ""
  var initial = ""

  var key: String {
    get {
      return "Manager:\(self.id)"
    }
  }
}

extension CHManager: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {

  }
  mutating func mapping(map: ObjectMapper_Map) {
    id              <- map["id"]
    name            <- map["name"]
    username        <- map["username"]
    mobileNumber    <- map["mobileNumber"]
    avatarUrl       <- map["avatarUrl"]
    initial         <- map["initial"]
    color           <- map["color"]

    
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
      lhs.online == rhs.online &&
      lhs.mobileNumber == rhs.mobileNumber
  }
}
