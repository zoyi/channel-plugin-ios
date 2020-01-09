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
  var text: NSAttributedString?
  var en: NSAttributedString?
  var ja: NSAttributedString?
  var ko: NSAttributedString?

  func getMessage() -> NSAttributedString? {
    let key = CHUtils.getLocale()
    
    if key == .english {
      return en ?? text
    } else if key == .japanese {
      return ja ?? text
    } else if key == .korean {
      return ko ?? text
    }
    return text
  }
}

extension CHi18n: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    text    <- (map ["text"], CustomMessageTransform())
    en      <- (map["en"], CustomMessageTransform())
    ja      <- (map["ja"], CustomMessageTransform())
    ko      <- (map["ko"], CustomMessageTransform())
  }
}

extension CHi18n: Equatable {}

func ==(lhs: CHi18n, rhs: CHi18n) -> Bool {
  return lhs.text == rhs.text && lhs.ko == rhs.ko &&
    lhs.ja == rhs.ja && lhs.en == rhs.en
}
