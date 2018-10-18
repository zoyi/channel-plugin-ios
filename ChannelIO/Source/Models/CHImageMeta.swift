//
//  PreviewThumb.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHImageMeta {
  var width = 0.0
  var height = 0.0
  var url = ""
}

extension CHImageMeta: Mappable {
  init?(map: Map) {

  }
  mutating func mapping(map: Map) {
    width   <- map["width"]
    height  <- map["height"]
    url     <- map["url"]
  }
}
