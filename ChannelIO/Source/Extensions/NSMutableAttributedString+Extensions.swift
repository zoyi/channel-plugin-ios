//
//  NSMutableAttributedString+Extensions.swift
//  ChannelIO
//
//  Created by Jam on 16/09/2019.
//

import Foundation

extension NSMutableAttributedString {
  func changeFont(fontSize: CGFloat) {
    self.enumerateAttribute(.font, in: NSMakeRange(0, self.length), options: []) {
      value, range, stop in
      guard let currentFont = value as? UIFont else { return }
      let newFont = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) ?
        UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
      self.addAttributes([.font: newFont], range: range)
    }
  }
}
