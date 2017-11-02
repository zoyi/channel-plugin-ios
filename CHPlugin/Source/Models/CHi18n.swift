//
//  CHi18n.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHi18n {
  var en: String?
  var ja: String?
  var ko: String?

  func getMessage() -> String? {
    guard let str = NSLocale.preferredLanguages.get(index: 0) else { return nil }
    let start = str.startIndex
    let end = str.index(str.startIndex, offsetBy: 2)
    let range = start..<end
    let locale = str.substring(with: range)
    if locale == "en" {
      return en
    } else if locale == "ja" {
      return ja
    } else if locale == "ko" {
      return ko
    }
    return nil
  }
}

extension CHi18n: Mappable {
  init?(map: Map) {

  }
  mutating func mapping(map: Map) {
    en <- map["en"]
    ja <- map["ja"]
    ko <- map["ko"]
  }
}
