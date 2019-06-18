//
//  MarkdownQuote.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//

import UIKit

class MarkdownQuote: MarkdownLevelElement {

  fileprivate static let regex = "^(\\>{1,%@})\\s*(.+)$"

  open var maxLevel: Int
  open var font: UIFont?
  open var color: UIColor?
  open var separator: String
  open var indicator: String

  open var regex: String {
    let level: String = maxLevel > 0 ? "\(maxLevel)" : ""
    return String(format: MarkdownQuote.regex, level)
  }

  public init(font: UIFont? = nil, maxLevel: Int = 0, indicator: String = ">",
              separator: String = "  ", color: UIColor? = nil) {
    self.maxLevel = maxLevel
    self.indicator = indicator
    self.separator = separator
    self.font = font
    self.color = color
  }

  open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
    var string = (0..<level).reduce("") { (string: String, _: Int) -> String in
      return "\(string)\(separator)"
    }
    string = "\(string)\(indicator) "
    attributedString.replaceCharacters(in: range, with: string)
  }
}
