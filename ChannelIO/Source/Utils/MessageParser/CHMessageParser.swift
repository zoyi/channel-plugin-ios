//
//  CHMessageParser.swift
//  ch-desk-ios
//
//  Created by intoxicated on 03/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

class CHMessageParser {
  private var config: CHMessageParserConfig

  var input: CharStream?
  var codeParser: CHCodeParser?
  var bulletParser: CHBulletParser?
  var textParser: TextBlockParser?
  var walker: ParseTreeWalker?
  var listener: CHTextParserListener?

  var emojiMap: [String: String] = [:]
  var profiles: [String: Any] = [:]
  var results: [CHMessageBlock] = []

  init(
    config: CHMessageParserConfig,
    emojiMap: [String: String],
    profiles: [String: Any] = [:]) {
    self.config = config
    self.emojiMap = emojiMap
    self.profiles = profiles

    self.codeParser = CHCodeParser(config: config)
    self.bulletParser = CHBulletParser(config: config)
    self.bulletParser?.textParser = self
  }

  @discardableResult
  func parse(blocks: [CHMessageBlock]) -> NSMutableAttributedString {
    for (index, block) in blocks.enumerated() {
      let result = self.parse(block: block)

      if let result = result {
        if index != blocks.count - 1 {
          result.append(NSAttributedString(string: "\n"))
        }

        var updatedBlock = block
        updatedBlock.displayText = result
        self.results.append(updatedBlock)
      }
    }
    
    return self.results.reduce(NSMutableAttributedString()) { result, block in
      if let text = block.displayText {
        result.append(text)
      }
      return result
    }
  }

  func parse(block: CHMessageBlock?) -> NSMutableAttributedString? {
    guard let block = block else { return nil }
    switch block.type {
    case .bullets: return self.parseBullets(block)
    case .code: return self.parseCode(block)
    case .text: return self.parseText(block.value)
    }
  }

  func parseCode(_ block: CHMessageBlock?) -> NSMutableAttributedString? {
    guard let block = block else { return nil }
    self.codeParser?.block = block
    return self.codeParser?.parse()
  }

  func parseBullets(_ block: CHMessageBlock?) -> NSMutableAttributedString? {
    guard let block = block, block.type == .bullets else { return nil }
    self.bulletParser?.block = block
    return self.bulletParser?.parse()
  }

  func parseText(_ input: String?) -> NSMutableAttributedString? {
    guard let input = input else { return nil }

    let charStream = ANTLRInputStream(input)
    let lexer = TextBlockLexer(charStream)
    let tokenStream = CommonTokenStream(lexer)
    let listener = CHTextParserListener(
      input: charStream,
      emojiMap: self.emojiMap,
      config: self.config
    )
    listener.profiles = profiles
    let walker = ParseTreeWalker()

    guard let textParser = try? TextBlockParser(tokenStream) else {
      return nil
    }

    self.input = charStream
    self.textParser = textParser
    self.walker = walker
    self.listener = listener

    try? self.walker?.walk(listener, textParser.block())
    let result = NSMutableAttributedString()

    return listener.results.reduce(result) { result, item in
      result.append(item)
      return result
    }
  }
}
