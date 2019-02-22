//
//  String+UTF16.swift
//
//  Created by Ivan Bruel on 19/07/16.
//
//

import Foundation

extension String {
  
  /// Converts each character to its UTF16 form in hexadecimal value (e.g. "H" -> "0048")
  func escapeUTF16() -> String {
    return Array(utf16).map {
      String(format: "%04x", $0)
    }.reduce("") {
      return $0 + $1
    }
  }
  
  /// Converts each 4 digit characters to its String form  (e.g. "0048" -> "H")
  func unescapeUTF16() -> String? {
    var utf16Array = [UInt16]()
    stride(from: 0, to: self.count, by: 4).forEach {
      let startIndex = self.index(self.startIndex, offsetBy: $0)
      let endIndex = self.index(self.startIndex, offsetBy: $0 + 4)
      let hex4 = self[startIndex..<endIndex]
      
      if let utf16 = UInt16(hex4, radix: 16) {
        utf16Array.append(utf16)
      }
    }
    
    return String(utf16CodeUnits: utf16Array, count: utf16Array.count)
  }
}