//
//  CHi18n.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

struct CHi18n {
  var text: String = ""
  var en: String?
  var ja: String?
  var ko: String?

  func getAttributedMessage(with config: CHMessageParserConfig? = nil) -> NSAttributedString? {
    let key = CHUtils.getLocale()
    var i18nText: String = self.text
    if key == .english {
      i18nText = self.en ?? self.text
    } else if key == .japanese {
      i18nText = self.ja ?? self.text
    } else if key == .korean {
      i18nText = self.ko ?? self.text
    }
    
    let config = config ?? CHMessageParserConfig(font: UIFont.systemFont(ofSize: 14))
    let transformer = CustomBlockTransform(config: config)
    return transformer.parser.parseText(i18nText)
  }
  
  func getMessageBlock() -> CHMessageBlock? {
    let key = CHUtils.getLocale()
    var i18nText: String? = self.text
    if key == .english {
      i18nText = self.en ?? self.text
    } else if key == .japanese {
      i18nText = self.ja ?? self.text
    } else if key == .korean {
      i18nText = self.ko ?? self.text
    }
    return CHMessageBlock(type: .text, value: i18nText)
  }
}

extension CHi18n: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    text    <- map["text"]
    en      <- map["en"]
    ja      <- map["ja"]
    ko      <- map["ko"]
  }
}

extension CHi18n: Equatable {}

func ==(lhs: CHi18n, rhs: CHi18n) -> Bool {
  return lhs.text == rhs.text
    && lhs.ko == rhs.ko
    && lhs.ja == rhs.ja
    && lhs.en == rhs.en
}
