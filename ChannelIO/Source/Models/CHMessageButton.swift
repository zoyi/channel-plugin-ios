//
//  CHMessageButton.swift
//  ChannelIO
//
//  Created by Jam on 2020/07/21.
//  Copyright © 2020 ZOYI. All rights reserved.
//

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
  
  var linkURL: URL? {
    get {
      guard
        let link = self.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      else {
        return URL(string: url)
      }
      return URL(string: link)
    }
  }
}

extension CHLinkButton: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }

  mutating func mapping(map: ObjectMapper_Map) {
    title <- map["title"]
    theme <- map["theme"]
    url <- map["url"]
  }
}
