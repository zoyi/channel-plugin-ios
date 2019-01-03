//
//  TargetEvaluator.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct TargetEvaluatorService {
  
  static func evaluate(with conditions: [[CHTargetCondition]]?, userInfo: [String: Any]) -> Bool {
    guard let conditions = conditions else { return true }
    
    for andConditions in conditions {
      if !self.evaluate(andConditions, userInfo: userInfo) {
        return false
      }
    }
    return true
  }
  
  static func evaluate(_ conditions: [CHTargetCondition], userInfo: [String: Any]) -> Bool {
    for orCondition in conditions {
      if self.evaluate(with: orCondition, userInfo: userInfo) {
        return true
      }
    }
    return false
  }
  
}

extension TargetEvaluatorService {
  
  static func evaluate(with condition: CHTargetCondition, userInfo: [String : Any]) -> Bool {
    guard let key = condition.key else { return false }
    guard let conditionValue = condition.value else { return false }
    
    var testValue: Any?
    switch key {
    case .guestProfile:
      guard let subKey = condition.subKey else { return false }
      guard let profiles = userInfo[TargetKey.guestProfile.rawValue] as? [String : Any] else { return false }
      testValue = profiles[subKey]
    //handled by server
    case .os, .country, .browser, .device, .url, .guestId, .guestType:
      return true
    default:
      testValue = userInfo[key.rawValue]
    }

    guard let op = condition.op else { return false }
    return self.evaluate(with:op, conditionValue: conditionValue, value:testValue)
  }
 
  static func evaluate(with op: TargetOperator, conditionValue: String, value: Any?) -> Bool {
    switch op {
    case .equal:
      guard let value = value as? String else { return false }
      return conditionValue == value
    case .notEqual:
      guard let value = value as? String else { return false }
      return conditionValue != value
    case .greaterThan:
      guard let value = value as? String,
        let dValue = Double(value),
        let checkValue = Double(conditionValue) else { return false }
      return checkValue < dValue
    case .greaterThanOrEqual:
      guard let value = value as? String,
        let dValue = Double(value),
        let checkValue = Double(conditionValue)  else { return false }
      return checkValue <= dValue
    case .lessThan:
      guard let value = value as? String,
        let dValue = Double(value),
        let checkValue = Double(conditionValue)  else { return false }
      return checkValue > dValue
    case .lessThanOrEqual:
      guard let value = value as? String,
        let dValue = Double(value),
        let checkValue = Double(conditionValue)  else { return false }
      return checkValue >= dValue
    case .contain:
      guard let value = value as? String else { return false }
      return value.contains(conditionValue)
    case .notContain:
      guard let value = value as? String else { return false }
      return !value.contains(conditionValue)
    case .exist:
      return value != nil
    case .notExist:
      return value == nil
    case .prefix:
      guard let value = value as? String else { return false }
      return value.hasPrefix(conditionValue)
    case .notPrefix:
      guard let value = value as? String else { return false }
      return !value.hasPrefix(conditionValue)
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
