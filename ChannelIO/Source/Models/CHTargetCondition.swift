//
//  CHNudgeCondition.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 5/2/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHTargetCondition {
  var key: TargetKey?
  var value: TargetValue?
  var op: TargetOperator?
  var subKey: TargetSubKey?
}

extension CHTargetCondition {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    key     <- map["key"]
    value   <- map["value"]
    op      <- map["operator"]
    subKey  <- map["subKey"]
  }
}
