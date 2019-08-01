//
//  MarkdownParser.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//

import UIKit

class MarkdownParser {

  // MARK: Element Arrays
  fileprivate var escapingElements: [MarkdownElement]
  fileprivate var defaultElements: [MarkdownElement]
  fileprivate var unescapingElements: [MarkdownElement]

  public var customElements: [MarkdownElement]

  // MARK: Basic Elements
  public var quote: MarkdownQuote
  public var link: MarkdownLink
  public var automaticLink: MarkdownAutomaticLink
  public var bold: MarkdownBold
  public var italic: MarkdownItalic
  public var boldItalic: MarkdownBoldItalic
  public var header: MarkdownHeader
  public var code: MarkdownCode
  public var emoji: MarkdownEmoji
  public var mention: MarkdownMention
  
  // MARK: Escaping Elements
  fileprivate var codeEscaping = MarkdownCodeEscaping()
  fileprivate var escaping = MarkdownEscaping()
  fileprivate var unescaping = MarkdownUnescaping()

  // MARK: Configuration
  /// Enables or disables detection of URLs even without Markdown format
  public var automaticLinkDetectionEnabled: Bool = true
  public var font: UIFont
  
  let emojiFont: UIFont = UIFont.systemFont(ofSize: 40)
  
  // MARK: Initializer
  public init(font: UIFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
              automaticLinkDetectionEnabled: Bool = true,
              customElements: [MarkdownElement] = []) {
    self.font = font
    
    self.quote = MarkdownQuote(font: font)
    self.link = MarkdownLink(font: font)
    self.automaticLink = MarkdownAutomaticLink(font: font)
    self.bold = MarkdownBold(font: font)
    self.boldItalic = MarkdownBoldItalic(font: font)
    self.italic = MarkdownItalic(font: font)
    self.header = MarkdownHeader(font: font, maxLevel: 5, fontIncrease: 2, color: CHColors.dark)
    self.code = MarkdownCode(font: font)
    self.emoji = MarkdownEmoji(font: font, map: CHUtils.emojiMap())
    self.mention = MarkdownMention(font: font)
    
    self.escapingElements = [escaping] //[codeEscaping, escaping]
    self.defaultElements = [quote, link, automaticLink, boldItalic, bold, italic, mention, emoji]
    self.unescapingElements = [unescaping] //[code, unescaping]
    self.automaticLinkDetectionEnabled = automaticLinkDetectionEnabled
    self.customElements = customElements
  }

  // MARK: Element Extensibility
  open func addCustomElement(_ element: MarkdownElement) {
    customElements.append(element)
  }

  open func removeCustomElement(_ element: MarkdownElement) {
    guard let index = customElements.firstIndex(where: { someElement -> Bool in
      return element === someElement
    }) else {
      return
    }
    customElements.remove(at: index)
  }

  // MARK: Parsing
  open func parse(_ markdown: String) -> (NSAttributedString?, Bool) {
    let tokens = markdown.components(separatedBy: "```")
    let attributedString = NSMutableAttributedString(string: markdown)

    var location = 0
    for (index, token) in tokens.enumerated() {
      var range = NSRange(location: location, length: token.utf16.count)
      if index % 2 != 1 && token != "" {
        let parsed = parse(NSAttributedString(string: token))
        attributedString.replaceCharacters(in: range, with: parsed)
        location += parsed.length
      } else if index % 2 == 1 && (index != tokens.count - 1) {
        let startPart = NSRange(location: range.location, length: 3)
        let endPart = NSRange(location: range.location + token.count + 3, length: 3)
        attributedString.deleteCharacters(in: endPart)
        attributedString.deleteCharacters(in: startPart)
        attributedString.addAttributes([.font: self.font], range: range)
        location += range.length
      } else if index == tokens.count - 1 && token != "" {
        let parsed = parse(NSAttributedString(string: token))
        range.location += 3
        attributedString.replaceCharacters(in: range, with: parsed)
        location += parsed.length
      }
    }

    let onlyEmoji = attributedString.string.containsOnlyEmoji
    if onlyEmoji {
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.alignment = .left
      paragraphStyle.minimumLineHeight = 20
      attributedString.addAttributes(
        [.font: self.emojiFont, .paragraphStyle:paragraphStyle],
        range: NSRange(location: 0, length: attributedString.length))
    }
    
    return (attributedString, onlyEmoji)
  }

  open func parse(_ markdown: NSAttributedString) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(attributedString: markdown)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = attributedString.string.guessLanguage() == "日本語" ? .byCharWrapping : .byWordWrapping
    paragraphStyle.alignment = .left
    paragraphStyle.minimumLineHeight = 20
    
    attributedString.addAttributes(
      [.font: self.font, .paragraphStyle:paragraphStyle],
      range: NSRange(location: 0, length: attributedString.length))
    
    var elements: [MarkdownElement] = escapingElements
    elements.append(contentsOf: defaultElements)
    elements.append(contentsOf: customElements)
    elements.append(contentsOf: unescapingElements)
    elements.forEach { element in
      if automaticLinkDetectionEnabled || type(of: element) != MarkdownAutomaticLink.self {
        element.parse(attributedString)
      }
    }
    return attributedString
  }

}
