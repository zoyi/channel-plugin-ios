//
//  Log.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 17..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

struct CHLog {
  var action = ""
  var values: [String] = []
}

extension CHLog: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {

  }
  mutating func mapping(map: ObjectMapper_Map) {
    action       <- map["action"]
    values       <- map["values"]
  }
}
