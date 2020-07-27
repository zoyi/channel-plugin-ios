//
//  MessageParserConfig.swift
//  ch-desk-ios
//
//  Created by intoxicated on 17/12/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit

struct CHMessageParserConfig {
  var font: UIFont
  var style: NSParagraphStyle
  var textColor: UIColor
  var linkColor: UIColor
  var backgroundColor: UIColor
  var codeFont: UIFont?
  var codeTextColor: UIColor
  var emojiOnlyFont: UIFont
  var letterSpacing: Float

  init(
    font: UIFont,
    emojiOnlyFont: UIFont = UIFont.systemFont(ofSize: 54),
    style: NSParagraphStyle = UIFactory.commonParagraphStyle,
    textColor: UIColor = .grey900,
    linkColor: UIColor = .cobalt400,
    backgroundColor: UIColor = .clear,
    codeFont: UIFont? = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 14),
    codeTextColor: UIColor = .grey700,
    letterSpacing: Float = 0
  ) {
    self.font = font
    self.style = style
    self.textColor = textColor
    self.linkColor = linkColor
    self.backgroundColor = backgroundColor
    self.codeFont = codeFont ?? font
    self.codeTextColor = codeTextColor
    self.emojiOnlyFont = emojiOnlyFont
    self.letterSpacing = letterSpacing
  }
}
