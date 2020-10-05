//
//  CHTargetCondition.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 5/2/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct CHTargetCondition {
  var key: TargetKey?
  var value: TargetValue?
  var op: TargetOperator?
  var subKey: TargetSubKey?
}

extension CHTargetCondition: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    key     <- map["key"]
    value   <- map["value"]
    op      <- map["operator"]
    subKey  <- map["subKey"]
  }
}
