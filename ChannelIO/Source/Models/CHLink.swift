//
//  CHLink.swift
//  ChannelIO
//
//  Created by Haeun Chung on 07/12/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHLink {
  var title: String = ""
  var url: String = ""
}

extension CHLink: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    title           <- map["title"]
    url             <- map["url"]
  }
}
