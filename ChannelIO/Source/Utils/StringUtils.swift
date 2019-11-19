//
//  StringUtils.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/17.
//

import Foundation

class StringUtils {
  static func customSort(_ str1: String, str2: String) -> Bool {
    if str1.count == 0 || str2.count == 0 {
      return str1.count < str2.count
    }

    let end = min(str1.count, i2: str2.count)

    for index in 0...end - 1 {
      let c1 = str1[index]
      let c2 = str2[index]
      if c1 == c2 { continue }

      let b1 = asciiCase(c1)
      let b2 = asciiCase(c2)
      if b1 != b2 { return b2 }

      let i1 = foldCase(c1)
      let i2 = foldCase(c2)
      if i1 != i2 {
        return i1 > i2 ? false : true
      }
    }

    return str1.count > str2.count ? false : true
  }
  
  private static func min(_ i1: Int, i2: Int) -> Int {
    return i1 > i2 ? i2 : i1
  }

  private static func asciiCase(_ ch: Character) -> Bool {
    return ch.unicodeScalarCodePoint() < 128
  }
  
  private static func foldCase(_ ch: Character) -> UInt32 {
    if ch.unicodeScalarCodePoint() < 128 {
      if "A" <= ch && ch <= "Z" {
        let small: Character = "a"
        let capital: Character = "A"
        return ch.unicodeScalarCodePoint() + small.unicodeScalarCodePoint() - capital.unicodeScalarCodePoint()
      }
      return ch.unicodeScalarCodePoint()
    }
    return Character(String(ch).uppercased().lowercased() as String).unicodeScalarCodePoint()
  }
}
