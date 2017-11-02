//
//  Date+Extensions.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
  func readableShortString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: self)
  }
  
  func readableDateString() -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter.string(from: self)
  }
  
  func readableTimestamp() -> String {
    let now = DateInRegion()
    let timeAt = DateInRegion(absoluteDate: self, in: Date.defaultRegion)
    let suffix = timeAt.hour >= 12 ? "PM" : "AM"
    let hour = timeAt.hour > 12 ? timeAt.hour - 12 : timeAt.hour
    if timeAt.isToday {
      return String(format:"%d:%02d %@", hour, timeAt.minute, suffix)
    } else if timeAt.year == now.year {
      return "\(timeAt.month)/\(timeAt.day)"
    }
    return "\(timeAt.year)/\(timeAt.month)/\(timeAt.day)"
  }
  
  func printDate() -> String {
    let todaysDate:Date = Date()
    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
    let comps = (cal as Calendar).dateComponents([.year,.month,.day], from: todaysDate)
    let comps2 = (cal as Calendar).dateComponents([.year,.month,.day], from: self)
    if comps.year == comps2.year && comps.month == comps2.month && comps.day == comps2.day {
      return self.readableShortString()
    } else {
      if comps.year == comps2.year {
        return String(describing: comps2.month!) + "/" + String(describing: comps2.day!)
      } else {
        return String(describing: comps2.year!) + "/" + String(describing: comps2.month!) + "/" + String(describing: comps2.day!)
      }
    }
  }
  
  func getMicroseconds() -> Int64 {
    return Int64(self.timeIntervalSince1970 * 1000.0 * 1000.0)
  }
  
  static func from(year: Int, month: Int, day: Int) -> Date {
    let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
    
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    
    let date = gregorianCalendar.date(from: dateComponents)!
    return date
  }
}
