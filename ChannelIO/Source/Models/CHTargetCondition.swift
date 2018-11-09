//
//  CHNudgeCondition.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 5/2/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

struct CHTargetCondition {
  var key: TargetKey?
  var value: TargetValue?
  var op: TargetOperator?
  var subKey: TargetSubKey?
}

extension CHTargetCondition {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    key     <- map["key"]
    value   <- map["value"]
    op      <- map["operator"]
    subKey  <- map["subKey"]
  }
}


extension CHTargetCondition {
  func evaluate(with value: Any?) -> Bool {
    guard let op = self.op, let key = key,
      let conditionValue = self.value,
      let subKey = self.subKey else { return false }
    
    switch op {
    case .equal:
      guard let value = value else { return false }
      return conditionValue == value
    case .notEqual:
      guard let value = value else { return false }
      return conditionValue != value
    case .greaterThan:
      guard let value = Double(value) else { return false }
      guard let checkValue = Double(conditionValue) else { return false }
      return checkValue < value
    case .greaterThanOrEqual:
      guard let value = Double(value) else { return false }
      guard let checkValue = Double(conditionValue) else { return false }
      return checkValue =< value
    case .lessThan:
      guard let value = Double(value) else { return false }
      guard let checkValue = Double(conditionValue) else { return false }
      return checkValue > value
    case .lessThanOrEqual:
      guard let value = Double(value) else { return false }
      guard let checkValue = Double(conditionValue) else { return false }
      return checkValue >= value
    case .contain:
      guard let value = value as? String else { return false }
      return conditionValue.contains(value)
    case .notContain:
      guard let value = value as? String else { return false }
      return !conditionValue.contains(value)
    case .exist:
      return value != nil
    case .notExist:
      return value == nil
    case .regex:
      guard let value = value as? String else { return false }
      do {
        let regex = try NSRegularExpression(pattern: conditionValue, options: .caseInsensitive)
        let results = regex.matches(in: value, range:  NSRange(value.startIndex..., in: value))
        return results.count != 0
      } catch {
        return false
      }
    }
  }
}

//typealias TargetOp = (Any?) -> Bool
//
//struct TargetOperatorFunc {
//  let equal: TargetOp = {
//    return $0 == $1
//  }
//  let notEqual: TargetOp = {
//    return $0 != $1
//  }
//  let exist: TargetOp = {
//    return $0 != nil
//  }
//  let notExist: TargetOp = {
//    return $0 == nil
//  }
//}
