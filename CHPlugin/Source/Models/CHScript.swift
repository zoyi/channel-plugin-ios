//
//  Script.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHScript: ModelType {
  var id = ""
  var key = ""
  var message = ""
  var i18n: CHi18n?

  func getTranslatedMessage() -> String {
    do {
      if let translated = self.i18n?.getMessage() {
        return translated
      }
      return self.message
    }
  }
}

extension CHScript: Mappable {
  init?(map: Map) {

  }
  mutating func mapping(map: Map) {
    id      <- map["id"]
    key     <- map["key"]
    message <- map["message"]
    i18n    <- map["i18n"]
  }
}
