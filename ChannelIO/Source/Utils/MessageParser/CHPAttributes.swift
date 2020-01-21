//
//  CHAttributes.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 1/6/20.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

enum CHPTagType: String {
  case bold = "b"
  case italic = "i"
  case link = "link"
  case unknown

  init?(rawValue: String) {
    switch rawValue {
    case "b": self = .bold
    case "i": self = .italic
    case "link": self = .link
    default: self = .unknown
    }
  }
}

enum CHPAttributeKeyType: String {
  case type
  case value
  case unknown

  public init?(rawValue: String) {
    switch rawValue {
    case "type": self = .type
    case "value": self = .value
    default: self = .unknown
    }
  }
}

enum CHPAttributeValueType {
  public init?(rawValue: String) {
    switch rawValue {
    case "url": self = .url
    case "email": self = .email
    case "manager": self = .manager
    case "profile": self = .profile
    default: self = .value(v: rawValue)
    }
  }

  case url
  case email
  case manager
  case profile
  case value(v: String)
}
