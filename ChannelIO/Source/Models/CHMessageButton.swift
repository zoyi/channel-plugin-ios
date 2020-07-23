//
//  CHMessageButton.swift
//  ChannelIO
//
//  Created by Jam on 2020/07/21.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import ObjectMapper

enum LinkButtonTheme: String {
  case blue
  case green
  case orange
  case red
  
  var color: UIColor {
    switch self {
    case .blue:
      return .cobalt400
    case .green:
      return .green400
    case .orange:
      return .orange400
    case .red:
      return .red400
    }
  }
}

struct CHLinkButton {
  var title: String = ""
  var theme: LinkButtonTheme?
  var url: String = ""
}

extension CHLinkButton: Mappable {
  init?(map: Map) { }

  mutating func mapping(map: Map) {
    title <- map["title"]
    theme <- map["theme"]
    url <- map["url"]
  }
}
