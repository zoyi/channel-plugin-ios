//
//  CHMessageBlock.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

enum MessageBlockType: String {
  case bullets
  case code
  case text
}

struct CHMessageBlock {
  var type: MessageBlockType = .text
  var blocks: [CHMessageBlock] = []
  var language: String?
  var value: String?
  
  var displayText: NSAttributedString?
  var isOnlyEmoji: Bool = false
}

extension CHMessageBlock: ObjectMapper_Mappable, Equatable {
  init?(map: ObjectMapper_Map) { }

  mutating func mapping(map: ObjectMapper_Map) {
    type <- map["type"]
    blocks <- map["blocks"]
    value <- map["value"]
    language <- map["language"]
  }
  
  static func == (lhs: CHMessageBlock, rhs: CHMessageBlock) -> Bool {
    return lhs.type == rhs.type
      && lhs.value == rhs.value
      && lhs.language == rhs.language
      && lhs.blocks == rhs.blocks
      && lhs.displayText == rhs.displayText
  }
}
