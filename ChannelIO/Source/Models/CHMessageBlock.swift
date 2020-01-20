//
//  CHMessageBlock.swift
//  ChannelIO
//
//  Created by intoxicated on 20/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import ObjectMapper
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
}

extension CHMessageBlock: Mappable, Equatable {
  init?(map: Map) { }

  mutating func mapping(map: Map) {
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
  }
}

struct CHMessageBlockViewModel: Equatable {
  var type: MessageBlockType = .text
  var displayText: NSAttributedString?

  init(
    type: MessageBlockType,
    displayText: NSAttributedString?) {
    self.type = type
    self.displayText = displayText
  }
  
  static func == (lhs: CHMessageBlockViewModel, rhs: CHMessageBlockViewModel) -> Bool {
    return lhs.type == rhs.type && lhs.displayText == rhs.displayText
  }
}
