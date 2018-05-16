//
//  String+Utils.swift
//  CHPlugin
//
//  Created by Haeun Chung on 17/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

extension NSAttributedString {
  func addFont(_ font: UIFont, color: UIColor, on range: NSRange) -> NSAttributedString {
    let attributedText = NSMutableAttributedString(attributedString: self)
    attributedText.addAttributes([
      NSAttributedStringKey.foregroundColor: color,
      NSAttributedStringKey.font: font], range: range)
    return attributedText
  }
  
  func combine(_ text: NSAttributedString) -> NSAttributedString {
    let attributedText = NSMutableAttributedString(attributedString: self)
    attributedText.append(text)
    return attributedText
  }
}

extension String {
  func addFont(_ font: UIFont, color: UIColor, on range: NSRange) -> NSMutableAttributedString {
    let attributedText = NSMutableAttributedString(string: self)
    attributedText.addAttributes([
      NSAttributedStringKey.foregroundColor: color,
      NSAttributedStringKey.font: font], range: range)
    return attributedText
  }
  
  func replace(_ target: String, withString: String) -> String {
    return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
  }
  
  subscript (i: Int) -> Character {
    return self[self.index(self.startIndex, offsetBy: i)]
  }

  static func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
      let rand = arc4random_uniform(len)
      var nextChar = letters.character(at: Int(rand))
      randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
  }
  
  func versionToInt() -> [Int] {
    return self.components(separatedBy: ".")
      .map { Int.init($0) ?? 0 }
  }
  
  func decodeHTML() throws -> String? {
    guard let data = data(using: .utf8) else { return nil }
    
    return try NSAttributedString(
      data: data,
      options: [
        .documentType: NSAttributedString.DocumentType.html,
        //iOS 8 symbol error
        //https://stackoverflow.com/questions/46484650/documentreadingoptionkey-key-corrupt-after-swift4-migration
        //NSAttributedString.DocumentReadingOptionKey("CharacterEncoding"): String.Encoding.utf8.rawValue
        .characterEncoding: String.Encoding.utf8.rawValue
      ],
      documentAttributes: nil).string
  }
  
  func guessLanguage() -> String {
    let length = self.utf16.count
    let languageCode = CFStringTokenizerCopyBestStringLanguage(
      self as CFString, CFRange(location: 0, length: length)
      ) as String? ?? ""
    
    let locale = Locale(identifier: languageCode)
    return locale.localizedString(forLanguageCode: languageCode) ?? "Unknown"
  }
}
