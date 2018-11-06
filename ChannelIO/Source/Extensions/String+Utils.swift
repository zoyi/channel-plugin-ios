//
//  String+Utils.swift
//  CHPlugin
//
//  Created by Haeun Chung on 17/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

enum StringTagType : String {
  case bold = "b"
}

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

extension StringProtocol where Index == String.Index {
  func nsRange(from range: Range<Index>) -> NSRange {
    return NSRange(range, in: self)
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

extension UnicodeScalar {
  var isEmoji: Bool {
    
    switch value {
    case 0x1F600...0x1F64F, // Emoticons
    0x1F300...0x1F5FF, // Misc Symbols and Pictographs
    0x1F680...0x1F6FF, // Transport and Map
    0x1F1E6...0x1F1FF, // Regional country flags
    0x2600...0x26FF,   // Misc symbols
    0x2700...0x27BF,   // Dingbats
    0xFE00...0xFE0F,   // Variation Selectors
    0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
    65024...65039, // Variation selector
    8400...8447: // Combining Diacritical Marks for Symbols
      return true
    default: return false
    }
  }
  
  var isZeroWidthJoiner: Bool {
    return value == 8205
  }
}

extension String {
  var glyphCount: Int {
    let richText = NSAttributedString(string: self)
    let line = CTLineCreateWithAttributedString(richText)
    return CTLineGetGlyphCount(line)
  }
  
  var isSingleEmoji: Bool {
    return glyphCount == 1 && containsEmoji
  }
  
  var containsEmoji: Bool {
    return unicodeScalars.contains { $0.isEmoji }
  }
  
  var containsOnlyEmoji: Bool {
    return !isEmpty && !unicodeScalars.contains(where: {
      !$0.isEmoji && !$0.isZeroWidthJoiner
    })
  }
  
  var emojiString: String {
    return emojiScalars.map { String($0) }.reduce("", +)
  }
  
  var emojis: [String] {
    var scalars: [[UnicodeScalar]] = []
    var currentScalarSet: [UnicodeScalar] = []
    var previousScalar: UnicodeScalar?
    
    for scalar in emojiScalars {
      
      if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
        
        scalars.append(currentScalarSet)
        currentScalarSet = []
      }
      currentScalarSet.append(scalar)
      
      previousScalar = scalar
    }
    
    scalars.append(currentScalarSet)
    
    return scalars.map { $0.map{ String($0) } .reduce("", +) }
  }
  
  fileprivate var emojiScalars: [UnicodeScalar] {
    var chars: [UnicodeScalar] = []
    var previous: UnicodeScalar?
    for cur in unicodeScalars {
      
      if let previous = previous, previous.isZeroWidthJoiner && cur.isEmoji {
        chars.append(previous)
        chars.append(cur)
        
      } else if cur.isEmoji {
        chars.append(cur)
      }
      
      previous = cur
    }
    
    return chars
  }
}

func unwrap(any: Any) -> Any {
  let mi = Mirror(reflecting: any)
  if mi.displayStyle != .optional {
    return any
  }
  if mi.children.count == 0 { return NSNull() }
  let (_, some) = mi.children.first!
  return some
}

//protocol OptionalProtocol {
//  func isSome() -> Bool
//  func unwrap() -> Any
//}
//
//extension Optional : OptionalProtocol {
//  func isSome() -> Bool {
//    switch self {
//    case .none: return false
//    case .some: return true
//    }
//  }
//
//  func unwrap() -> Any {
//    switch self {
//    case .none: preconditionFailure("trying to unwrap nil")
//    case .some(let unwrapped): return unwrapped
//    }
//  }
//}
//
//func unwrapUsingProtocol<T>(_ any: T) -> Any{
//  guard let optional = any as? OptionalProtocol, optional.isSome() else {
//    return any
//  }
//  return optional.unwrap()
//}

