//
//  ChanneMessageParserListener.swift
//  ch-desk-ios
//
//  Created by intoxicated on 03/01/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import UIKit

extension ParserRuleContext: Hashable, Equatable {
  func hash(into hasher: inout Hasher) {
    hasher.combine("\(type(of: self))")
  }

  static func == (lhs: ParserRuleContext, rhs: ParserRuleContext) -> Bool {
    return type(of: lhs) == type(of: rhs)
  }
}

class CHTextParserListener: TextBlockParserListener {
  var input: CharStream
  var config: CHMessageParserConfig
  var emojiMap: [String: String] = [:]
  var results: [NSAttributedString] = []

  var isBold = false
  var isItalic = false
  var isLink = false
  var isVariable = false
  var isOnlyEmoji = true
  var isInappPush = false
  var isEscape = false
  
  var stack: [CHPBlock] = []
  var profiles: [String: Any] = [:]

  var escapingStrings = [
    "&lt;": "<",
    "&gt;": ">",
    "&amp;": "&",
    "&quot;": "\"",
    "&dollar;": "$"
  ]

  init(
    input: CharStream,
    emojiMap: [String: String],
    config: CHMessageParserConfig,
    isInappPush: Bool) {
    self.input = input
    self.emojiMap = emojiMap
    self.config = config
    self.isInappPush = isInappPush
  }

  func enterBlock(_ ctx: TextBlockParser.BlockContext) {}
  func exitBlock(_ ctx: TextBlockParser.BlockContext) {
    var result: [NSAttributedString] = []
    let attributedText = self.results.reduce(NSMutableAttributedString()) {
      $0.append($1)
      return $0
    }

    let texts = attributedText
      .split(seperateBy: "\n")
      .map { NSMutableAttributedString(attributedString: $0) }

    for (index, text) in texts.enumerated() {
      let onlyEmoji = text.string.containsOnlyEmoji
      self.isOnlyEmoji = self.isOnlyEmoji && onlyEmoji
      let font = onlyEmoji && !isInappPush ? self.config.emojiOnlyFont : self.config.font
      if onlyEmoji && !isInappPush {
        text.addAttributes(
          [.font: font,
           .kern: self.config.letterSpacing,
           .paragraphStyle: UIFactory.onlyEmojiParagraphStyle,
           .baselineOffset: (UIFactory.onlyEmojiParagraphStyle.minimumLineHeight - font.lineHeight)/4
          ],
          range: NSRange(location: 0, length: text.string.utf16.count)
        )
      }

      result.append(text)
      if index != texts.count - 1 {
        result.append(NSAttributedString(string: "\n", attributes: [ .font : font ]))
      }
    }

    self.results = result
  }

  func enterTag(_ ctx: TextBlockParser.TagContext) {
    self.handleTagScope(ctx, enter: true)
    guard
      let tagString = self.getNodeText(from: ctx.TAG_NAME(0)),
      let type = CHPTagType(rawValue: tagString) else {
      return
    }

    let tag = CHPTag(interval: ctx.getSourceInterval(), type: type)
    self.stack.append(tag)
  }

  func exitTag(_ ctx: TextBlockParser.TagContext) {
    guard let tag = self.popAndMerge(until: CHPTag.self) else {
      return
      //fatalError("last element of stack has to be content")
    }

    var result: NSMutableAttributedString?

    if tag.type == .link {
      var linkString = tag.merge()?.string ?? ""

      let type = tag.attributes[.type]
      let value = tag.attributes[.value]

      switch type {
      case .url:
        if case .value(let v) = value {
          linkString = v
        }
      case .manager:
        if case .value(let v) = value {
          linkString = "mention://\(v)"
        }
      case .email:
        if case .value(let v) = value {
          linkString = "mailto:\(v)"
        } else {
          linkString = "mailto:\(linkString)"
        }
      default:
        linkString = ""
      }

      let encodedUrl = linkString
        .removingPercentEncoding?
        .addingPercentEncoding(
          withAllowedCharacters: .urlQueryAllowed
        ) ?? linkString

      if let url = URL(string: encodedUrl), let merged = tag.merge() {
        merged.addAttributes([
          .link: url,
          .foregroundColor: self.config.linkColor
        ],
        range: NSRange(location: 0, length: merged.string.utf16.count))
        result = merged
      }
    }

    if var prevTag = self.stack.popLastIf(CHPTag.self) {
      prevTag.merge(with: result ?? tag.merge())
      self.stack.append(prevTag)
    } else if let result = result {
      self.results.append(result)
    } else if let result = tag.merge() {
      self.results.append(result)
    }

    self.handleTagScope(ctx, enter: false)
  }

  func enterAttribute(_ ctx: TextBlockParser.AttributeContext) {
    guard
      let name = self.getNodeText(from: ctx.TAG_NAME()),
      let type = CHPAttributeKeyType(rawValue: name) else {
      return
    }

    let attr = CHPAttribute(interval: ctx.getSourceInterval(), type: type)
    self.stack.append(attr)
  }

  func exitAttribute(_ ctx: TextBlockParser.AttributeContext) {
    guard let attr = self.popAndMerge(until: CHPAttribute.self) else {
      return
      //fatalError("last element of the stack has to be attribute type")
    }

    guard var tag = self.popAndMerge(until: CHPTag.self) else {
      return
      //fatalError("last element of the stack has to be tag type")
    }

    if let attrValue = attr.value {
      tag.attributes[attr.type] = attrValue
    }
    self.stack.append(tag)
  }

  func enterAttrValue(_ ctx: TextBlockParser.AttrValueContext) {
    let attrValue = CHPAttributeValue(interval: ctx.getSourceInterval())
    self.stack.append(attrValue)
  }

  func exitAttrValue(_ ctx: TextBlockParser.AttrValueContext) {
    guard let attrValue = self.popAndMerge(until: CHPAttributeValue.self) else {
      return
    }

    guard
      let rawValue = attrValue.merge()?.string,
      let value = CHPAttributeValueType(rawValue: rawValue) else {
      return
    }

    guard var attr = self.stack.popLastIf(CHPAttribute.self) else {
      return
      //fatalError("last element of the stack has to be attribute type")
    }

    attr.value = value
    self.stack.append(attr)
  }

  func enterContent(_ ctx: TextBlockParser.ContentContext) {
    let content = CHPContent(interval: ctx.getSourceInterval())
    self.stack.append(content)
  }

  func exitContent(_ ctx: TextBlockParser.ContentContext) {
    guard let content = self.popAndMerge(until: CHPContent.self) else {
      return
      //fatalError("last element of stack has to be content")
    }

    if var tag = self.stack.popLastIf(CHPTag.self),
      let result = content.merge() {
      tag.merge(with: result)
      self.stack.append(tag)
    } else if let result = content.merge() {
      self.results.append(result)
    }
  }

  func enterEmoji(_ ctx: TextBlockParser.EmojiContext) {}
  func exitEmoji(_ ctx: TextBlockParser.EmojiContext) {
    guard var content = self.stack.popLastIf(CHPContent.self) else {
      return
    }

    let emojiCode = self.getNodeText(from: ctx.EMOJI()) ?? ""
    let emoji = self.emojiMap[emojiCode.replace(":", withString: "")] ?? emojiCode

    let attributedString = NSMutableAttributedString(
      string: emoji,
      attributes: [
        .foregroundColor: self.config.textColor,
        .font: self.config.font,
        .kern: self.config.letterSpacing,
        .paragraphStyle: self.config.style,
        .baselineOffset: (self.config.style.minimumLineHeight - self.config.font.lineHeight)/4
      ])

    content.merge(with: attributedString)
    self.stack.append(content)
  }

  func enterVariable(_ ctx: TextBlockParser.VariableContext) {
    self.isVariable = true
  }

  func exitVariable(_ ctx: TextBlockParser.VariableContext) {
    guard var block = self.stack.popLast() else {
      return
    }

    if let name = self.getNodeText(from: ctx.VAR_NAME()),
      let data = self.profiles[name] {
      block.merge(with: self.addAttributesForNormalText("\(data)"))
    } else if let fallbackCtx = ctx.variableFallback(),
      let text = self.getText(from: fallbackCtx) {
      block.merge(with: self.addAttributesForNormalText(text))
    } else {
    }
    self.stack.append(block)
    self.isVariable = false
  }

  func enterVariableFallback(_ ctx: TextBlockParser.VariableFallbackContext) {}
  func exitVariableFallback(_ ctx: TextBlockParser.VariableFallbackContext) {}

  func enterPlain(_ ctx: TextBlockParser.PlainContext) {}
  func exitPlain(_ ctx: TextBlockParser.PlainContext) {
    guard
      let text = self.getText(from: ctx),
      var block = self.stack.popLast() else { return }
    block.merge(with: self.addAttributesForNormalText(text))
    self.stack.append(block)
  }

  func enterEscape(_ ctx: TextBlockParser.EscapeContext) {
    self.isEscape = true
  }
  
  func exitEscape(_ ctx: TextBlockParser.EscapeContext) {
    guard
      let text = self.getText(from: ctx),
      var block = self.stack.popLast() else { return }
    block.merge(with: self.addAttributesForNormalText(text))
    self.stack.append(block)
    self.isEscape = false
  }

  func visitTerminal(_ node: TerminalNode) {
    guard
      !isEscape,
      var block = self.stack.popLastIf(CHPAttributeValue.self),
      let text = self.getNodeText(from: node),
      self.isVariable == false else { return }

    block.merge(with: self.addAttributesForNormalText(text))
    self.stack.append(block)
  }

  func visitErrorNode(_ node: ErrorNode) {}
  func enterEveryRule(_ ctx: ParserRuleContext) throws {}
  func exitEveryRule(_ ctx: ParserRuleContext) throws {}

  private func popAndMerge<T>(until type: T.Type) -> T? {
    let subResults = NSMutableAttributedString()
    var block: CHPBlock? = self.stack.popLast()

    while !(block is T) && self.stack.count != 0 {
      if let block = block, let result = block.merge() {
        subResults.append(result)
      }
      block = self.stack.popLast()
    }

    block?.merge(with: subResults)
    return block as? T
  }

  private func handleTagScope(_ ctx: TextBlockParser.TagContext, enter: Bool) {
    guard
      let text = self.getNodeText(from: ctx.TAG_NAME(0)),
      let tag = CHPTagType(rawValue: text) else {
      return
    }

    switch tag {
    case .bold: isBold = enter
    case .italic: isItalic = enter
    case .link: isLink = enter
    default: break
    }
  }

  private func getText(from ctx: ParserRuleContext) -> String? {
    guard
      let s = ctx.getStart()?.getStartIndex(),
      let e = ctx.getStop()?.getStopIndex() else {
      return nil
    }

    return try? self.input.getText(Interval(s, e))
  }

  private func getNodeText(from node: TerminalNode?) -> String? {
    guard
      let s = node?.getSymbol()?.getStartIndex(),
      let e = node?.getSymbol()?.getStopIndex() else {
      return nil
    }

    return try? self.input.getText(Interval(s, e))
  }

  private func addAttributesForNormalText(_ text: String) -> NSMutableAttributedString {
    var font: UIFont

    if self.isBold && self.isItalic {
      font = self.config.font.boldItalic()
    } else if self.isBold {
      font = self.config.font.bold()
    } else if self.isItalic {
      font = self.config.font.italic()
    } else {
      font = self.config.font
    }

    var plainText: String
    if let value = self.escapingStrings[text] {
      plainText = value
    } else {
      plainText = text
    }

    return NSMutableAttributedString(
      string: plainText,
      attributes: [
        .font: font,
        .kern: self.config.letterSpacing,
        .foregroundColor: self.config.textColor,
        .paragraphStyle: self.config.style,
        .baselineOffset: (self.config.style.minimumLineHeight - font.lineHeight)/4
      ])
  }
}
