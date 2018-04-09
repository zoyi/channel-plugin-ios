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
    let key = CHUtils.getLocale()
    
    if key == .english {
      return en
    } else if key == .japanese {
      return ja
    } else if key == .korean {
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
