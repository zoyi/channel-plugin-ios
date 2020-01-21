//
//  CHBulletParser.swift
//  ch-desk-ios
//
//  Created by intoxicated on 03/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

class CHBulletParser {
  var config: CHMessageParserConfig
  var block: CHMessageBlock?
  var maxLevel = 2

  let filledDotIndicator = "• "
  let emptyDotIndicator = "◦ "
  let indent = "    "

  weak var textParser: CHMessageParser?

  init(block: CHMessageBlock? = nil, config: CHMessageParserConfig, maxLevel: Int = 2) {
    self.block = block
    self.config = config
    self.maxLevel = maxLevel
  }

  func parse(level: Int, block: CHMessageBlock?) -> NSMutableAttributedString? {
    guard let block = block, self.maxLevel > level else { return nil }

    let result = NSMutableAttributedString()
    let dot = level % 2 == 1 ? self.emptyDotIndicator : self.filledDotIndicator
    let indent = String(repeating: self.indent, count: level)

    if let value = block.value {
      if let textResult = self.textParser?.parseText(indent + dot + value) {
        result.append(textResult)
        result.append(NSAttributedString(string: "\n"))
      }
    }

    for each in block.blocks {
      let nextLevel = block.value == nil ? level : level + 1
      if let subResult = self.parse(level: nextLevel, block: each) {
        result.append(subResult)
      }
    }

    return result
  }

  func parse() -> NSMutableAttributedString? {
    guard let block = self.block else { return nil }
    if let result = self.parse(level: 0, block: block) {
      result.deleteCharacters(in: NSRange(location: result.length - 1, length: 1))
      return result
    }
    return nil
  }
}
