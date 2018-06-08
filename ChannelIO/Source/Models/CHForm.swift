//
//  CHForm.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHForm {
  var type: String = ""
  var inputs: [CHInput] = []
}

extension CHForm: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    type        <- map["type"]
    inputs      <- map["inputs"]
  }
}

struct CHInput {
  var key: String = ""
  var value: CHi18n? = nil
  var selected: Bool? = nil
}

extension CHInput: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    key         <- map["key"]
    value       <- map["value"]
    selected    <- map["selected"]
  }
}
