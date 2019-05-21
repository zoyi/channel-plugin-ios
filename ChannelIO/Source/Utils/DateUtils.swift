//
//  DateUtils.swift
//  ChannelIO
//
//  Created by R3alFr3e on 5/16/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

enum Weekday: String {
  case sun, mon, tue, wed, thu, fri, sat
  
  var toIndex: Int {
    switch self {
    case .sun: return 1
    case .mon: return 2
    case .tue: return 3
    case .wed: return 4
    case .thu: return 5
    case .fri: return 6
    case .sat: return 7
    }
  }
  
  static func toWeekday(from index: Int) -> Weekday {
    let index = index > 7 ? index % 8 + 1 : index
    switch index {
    case 1: return .sun
    case 2: return .mon
    case 3: return .tue
    case 4: return .wed
    case 5: return .thu
    case 6: return .fri
    case 7: return .sat
    default: return .sun
    }
  }
  
  static let all: [Weekday] = [.sun, .mon, .tue, .wed, .thu, .fri, .sat]
}

struct DateUtils {
  static func emptyArrayWithWeekday() -> [Weekday: [TimeRange]] {
    let result:[Weekday: [TimeRange]] = [:]
    return Weekday.all.reduce(result, { (result, weekday) -> [Weekday:[TimeRange]] in
      var result = result
      result[weekday] = []
      return result
    })
  }
  
  static func merge(ranges: [TimeRange]) -> [TimeRange] {
    var last: TimeRange?
    return ranges
      .sorted(by: { (r1, r2) -> Bool in
        return r1.from < r2.from
      })
      .reduce([], { (result, range) -> [TimeRange] in
        var result = result
        if let lastRange = last {
          if range.from > lastRange.to {
            last = range
            result.append(range)
          }
          else if range.to > lastRange.to {
            last?.to = range.to
          }
        } else {
          last = range
          result.append(range)
        }
        
        return result
      })
  }
  
  static func substract(ranges: [TimeRange], otherRanges: [TimeRange]) -> [TimeRange] {
    struct TimeRangeOperation {
      var time: Int
      var isAddition: Bool
      var isFrom: Bool
    }
    
    var operations: [TimeRangeOperation] = []
    
    DateUtils.merge(ranges: ranges).forEach { (range) in
      operations.append(TimeRangeOperation(time: range.from, isAddition: true, isFrom: true))
      operations.append(TimeRangeOperation(time: range.to, isAddition: true, isFrom: false))
    }
    DateUtils.merge(ranges: otherRanges).forEach { (range) in
      operations.append(TimeRangeOperation(time: range.from, isAddition: false, isFrom: true))
      operations.append(TimeRangeOperation(time: range.to, isAddition: false, isFrom: false))
    }
    operations = operations.sorted(by:{ $0.time < $1.time })
    
    var inAddition: Bool?
    var inSubstraction: Bool?
    var lastFrom: Int = 0
    var result: [TimeRange] = []
    
    for op in operations {
      if op.isAddition {
        if op.isFrom {
          if inSubstraction == nil || inSubstraction == false {
            lastFrom = op.time
          }
          inAddition = true
        } else {
          if inSubstraction == nil || inSubstraction == false {
            result.append([lastFrom, op.time])
          }
          inAddition = false
        }
      } else {
        if op.isFrom {
          if inAddition == true {
            result.append([lastFrom, op.time])
          }
          inSubstraction = true
        } else {
          if inAddition == true {
            lastFrom = op.time
          }
          inSubstraction = false
        }
      }
    }
    return result
  }
  
  static func getClosestTimeFromWeekdayRange(
    date: Date,
    weekdayRange: [Weekday: [TimeRange]]) -> (weekday: Weekday, time: Int)? {
    let weekday = Calendar.current.component(.weekday, from: date)
    let currentWeekdayIndex = weekday
    let currentMinutes = date.minutes
    
    for i in currentWeekdayIndex..<14 {
      let wd = Weekday.toWeekday(from: i)
      if let ranges = weekdayRange[wd], ranges.count != 0 {
        for eachRange in ranges {
          if wd == Weekday.toWeekday(from: currentWeekdayIndex) {
            if currentMinutes < eachRange.from {
              return (wd, eachRange.from)
            }
            if eachRange.from <= currentMinutes && currentMinutes < eachRange.to {
              return (wd, currentMinutes)
            }
          } else {
            return (wd, eachRange.from)
          }
        }
      }
    }
    return nil
  }
}
