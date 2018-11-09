//
//  TargetEvaluator.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct TargetEvaluatorService {
  //refactor guest + userInfo into one params
  static func evaluate(object: CHEvaluatable, userInfo: [String: Any]) -> Bool {
    guard let target = evaluableObject.target else { return }
    
    for andConditions in target {
      if !self.evaluate(with: andConditions, userInfo: userInfo) {
        return false
      }
    }
    return true
  }
  
  private static func evaluate(with conditions: [CHTargetCondition], userInfo: [String: Any]) -> Bool {
    for orCondition in conditions {
      if self.evaluate(with: orCondition, userInfo: userInfo) {
        return true
      }
    }
    return false
  }
}

private extension TargetEvaluator {
  //evaluate target with given guest and userInfo
  private static func evaluate(with condition: CHTargetCondition, userInfo: [String:Any]) -> Bool {
    guard let key = condition.key else { return false }
    guard let value = condition.value else { return false }
    
//    var testValue: Any? = userInfo[key]
//    switch key {
//    case .mobilePageName:
//      testValue = userInfo[key]
//    case .os, .device, .city, .country, .deviceCategory, .locale:
//      testValue = userInfo[key]
//    case .ip:
//      testValue = userInfo[key]
//    case .guestId:
//      testValue = guest?.id
//    case .guestCreatedAt:
//      testValue = guest?.createdAt
//    case .guestUpdatedAt:
//      testValue = guest?.updatedAt
//    case .guestMobileNumber:
//      testValue = guest?.mobileNumber
//    case .guestSegment:
//      testValue = guest?.segment
//    case .guestType:
//      testValue = guest?.type
//    case .guestName:
//      testValue = guest?.name
//    case .guestProfile:
//      guard let subKey = target.subKey else { return false }
//      testValue = guest?.profile?[subKey]
//    default:
//      return false
//    }
    
    return self.evaluate(with: condition, value:userInfo[key])
  }
  
  //evaluate value with condition with operator
  private static func evaluate(with condition: CHTargetCondition, value: Any?) -> Bool {
    guard let op = condition.op, let key = condition.key,
      let conditionValue = condition.value,
      let subKey = condition.subKey else { return false }
    
    switch op {
    case .equal:
      guard let value = value else { return false }
      return conditionValue == value
    case .notEqual:
      guard let value = value else { return false }
      return conditionValue != value
    case .greaterThan:
      guard let value = Double(value), let checkValue = Double(conditionValue) else { return false }
      return checkValue < value
    case .greaterThanOrEqual:
      guard let value = Double(value), let checkValue = Double(conditionValue)  else { return false }
      return checkValue =< value
    case .lessThan:
      guard let value = Double(value), let checkValue = Double(conditionValue)  else { return false }
      return checkValue > value
    case .lessThanOrEqual:
      guard let value = Double(value), let checkValue = Double(conditionValue) else { return false }
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
