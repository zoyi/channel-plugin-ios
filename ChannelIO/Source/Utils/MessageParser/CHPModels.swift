//
//  ParserModels.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 1/18/20.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

protocol CHPBlock {
  var interval: Interval { get set }
  var children: [NSAttributedString] { get set }
}

extension CHPBlock {
  func merge() -> NSMutableAttributedString? {
    return self.children.reduce(NSMutableAttributedString()) {
      $0.append($1)
      return $0
    }
  }

  mutating func merge(with other: NSMutableAttributedString?) {
    guard let other = other else {
      return
    }
    self.children.append(other)
  }
}

struct CHPContent: CHPBlock, Equatable {
  var interval: Interval
  var children: [NSAttributedString] = []

  static func == (lhs: CHPContent, rhs: CHPContent) -> Bool {
    return lhs.interval == rhs.interval
  }
}

struct CHPTag: CHPBlock, Equatable {
  var interval: Interval
  var children: [NSAttributedString] = []

  var type: CHPTagType
  var attributes: [CHPAttributeKeyType: CHPAttributeValueType] = [:]

  static func == (lhs: CHPTag, rhs: CHPTag) -> Bool {
    return lhs.interval == rhs.interval
  }
}

struct CHPAttribute: CHPBlock, Equatable {
  var interval: Interval
  var children: [NSAttributedString] = []

  var type: CHPAttributeKeyType
  var value: CHPAttributeValueType?

  static func == (lhs: CHPAttribute, rhs: CHPAttribute) -> Bool {
    return lhs.interval == rhs.interval
  }
}

struct CHPAttributeValue: CHPBlock, Equatable {
  var interval: Interval
  var children: [NSAttributedString] = []

  var type: CHPAttributeValueType = .value(v: "")

  static func == (lhs: CHPAttributeValue, rhs: CHPAttributeValue) -> Bool {
    return lhs.interval == rhs.interval
  }
}
