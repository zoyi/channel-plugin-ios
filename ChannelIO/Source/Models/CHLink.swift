//
//  CHLink.swift
//  ChannelIO
//
//  Created by Haeun Chung on 07/12/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct CHLink {
  var title: String = ""
  var url: String = ""
}

extension CHLink: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    title           <- map["title"]
    url             <- map["url"]
  }
}
