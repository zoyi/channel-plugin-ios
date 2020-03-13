//
//  Character+Extensions.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/17.
//

import Foundation

extension Character {
  func unicodeScalarCodePoint() -> UInt32 {
    let characterString = String(self)
    let scalars = characterString.unicodeScalars
    return scalars[scalars.startIndex].value
  }
}
