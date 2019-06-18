//
//  Date+Extensions.swift
//  CHPlugin
//
//  Created by Haeun Chung on 08/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

extension Date {
  var microseconds: Double {
    return Double(self.timeIntervalSince1970 * 1000.0 * 1000.0)
  }
  
  var miliseconds: Double {
    return Double(self.timeIntervalSince1970 * 1000.0)
  }
  
  var minutes: Int {
    var totalMinutues: Int = 0
    totalMinutues += self.hours * 60
    totalMinutues += Calendar.current.component(.minute, from: self)
    return totalMinutues
  }
  
  var hours: Int {
    return Calendar.current.component(.hour, from: self)
  }
  
  var weekday: Weekday {
    return Weekday.toWeekday(from: Calendar.current.component(.weekday, from: self))
  }
}

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
  
  func fullDateString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    return formatter.string(from: self)
  }

  func readableTimeStamp() -> String {
    let cal = NSCalendar.current
    let now = Date()
    
    let end = now
    let start = self
    
    //let flags = NSCalendarUnit.Day
    let startComponents = cal.dateComponents([.year, .day, .month,.minute, .hour], from: start)
    let endComponents = cal.dateComponents([.year], from: end)
    
    if cal.isDate(start, inSameDayAs: end), var hours = startComponents.hour, let minute = startComponents.minute {
      let suffix = hours >= 12 ? "PM" : "AM"
      hours = hours > 12 ? hours - 12 : hours
      return String(format:"%d:%02d %@", hours, minute, suffix)
    } else if let startYear = startComponents.year, let endYear = endComponents.year, startYear == endYear {
      return "\(startComponents.month ?? 0)/\(startComponents.day ?? 0)"
    }
    
    let year = startComponents.year ?? 0
    let month = startComponents.month ?? 0
    let day = startComponents.day ?? 0
    return "\(year)/\(month)/\(day)"
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
  
  func next(weekday: Weekday, mintues: Int) -> Date? {
    var dateComponents = DateComponents.init()
    dateComponents.weekday = weekday.toIndex
    dateComponents.hour = mintues / 60
    dateComponents.minute =  mintues % 60
    
    return Calendar.current.nextDate(after: self, matching: dateComponents, matchingPolicy: .nextTime)
  }
  
  static func from(dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    formatter.timeZone = Calendar.current.timeZone
    
    return formatter.date(from: dateString)
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
  
  func diff(from date: Date, components: Set<Calendar.Component>) -> DateComponents {
    return Calendar.current.dateComponents(components, from: self, to: date)
  }
  
  func parseUTCOffset(string: String) -> Int? {
    let components = string.components(separatedBy: ":")
    if let hours = Int(components[0]), let minutes = Int(components[1]) {
      return minutes * 60 + hours * 60 * 60
    }
    return nil
  }
  
  //take either timezone string as "ETC/GTM+9" or "GMT+9" or abbreviation
  func convertTimeZone(with string: String) -> Date? {
    var remoteZone: NSTimeZone
    if let timezoneKey = TimeZone
      .abbreviationDictionary
      .filter({ $0.value == string })
      .first?.key,
      let timeZone = NSTimeZone.init(abbreviation: timezoneKey) {
      remoteZone = timeZone
    }
    else if let timeZone = NSTimeZone(name: string) {
      remoteZone = timeZone
    }
    else if string.contains("/") {
      if let gmt = string.components(separatedBy: "/").last,
        let timeZone = NSTimeZone(name: gmt){
        remoteZone = timeZone
      } else {
        return nil
      }
    }
    else {
      print("Unrecognized timezone abbreviation")
      return nil
    }
    
    let localZone = NSTimeZone.local
    let currentOffset = TimeInterval(localZone.secondsFromGMT(for: self))
    let remoteOffset = TimeInterval(remoteZone.secondsFromGMT(for: self))
    let diff = currentOffset - remoteOffset

    if diff == 0 {
      return self
    }
    else {
      return Date(timeInterval: remoteOffset, since: self)
    }
  }
}

