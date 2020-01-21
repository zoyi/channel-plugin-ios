//
//  CHCodeParser.swift
//  ch-desk-ios
//
//  Created by intoxicated on 03/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

class CHCodeParser {
  var block: CHMessageBlock?
  var config: CHMessageParserConfig

  init(block: CHMessageBlock? = nil, config: CHMessageParserConfig) {
    self.block = block
    self.config = config
  }

  func parse() -> NSMutableAttributedString? {
    guard
      let block = self.block,
      let text = block.value,
      block.type == .code else { return nil }

    return NSMutableAttributedString(
      string: text,
      attributes: [
        .foregroundColor: self.config.textColor,
        .paragraphStyle: self.config.style,
        .font: self.config.font
      ])
  }
}
