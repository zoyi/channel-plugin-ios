//
//  CHChannel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

struct CHChannel: CHEntity {
  // ModelType
  var id = ""
  // Avatar
  var avatarUrl: String?
  var initial = ""
  var color = ""
  // Channel
  var name = ""
  var domain = ""
  var country = ""
  var desc = ""
  var defaultPluginId = ""
  var textColor = "white"
  var working = true
  var workingTimeRanges: [TimeRange]?
  var phoneNumber: String?
  var requestUserInfo = true
  var messengerPlan: ChannelPlanType = .none
  var supportBotPlan: ChannelPlanType = .none
  var blocked = false
  var homepageUrl = ""
  var expectedResponseDelay = ""
  var timeZone = ""
  var utcOffset = ""
  var awayOption: ChannelAwayOptionType = .active
  var workingType: ChannelWorkingType = .always
  var trial = true
  var trialEndDate: Date? = nil
  var state: ChannelState?
}

extension CHChannel {
  var defaultPluginLink: String {
    return "https://\(self.domain).channel.io"
  }
  
  var canUseSDK: Bool {
    return !self.blocked && (self.messengerPlan == .pro || self.trial)
  }

  var canUseSupportBot: Bool {
    return !self.blocked && (self.supportBotPlan != .none || self.trial)
  }
  
  var shouldHideLauncher: Bool {
    return self.awayOption == .hidden && !self.working
  }
  
  var allowNewChat: Bool {
    return self.workingType == .always ||
      self.awayOption == .active ||
      (self.workingType == .custom && self.working)
  }
  
  var shouldShowWorkingTimes: Bool {
    if let workingTimeRanges = self.workingTimeRanges, workingTimeRanges.count != 0 {
      return self.workingType == .custom && !self.working
    }
    return false
  }
  
  private func rangeToWorkingTimeString(_ range: TimeRange) -> String {
    let days: String = range
      .dayOfWeeks
      .sorted(by: {
        guard
          let first = daysSortOrder(rawValue: $0)?.order,
          let second = daysSortOrder(rawValue: $1)?.order else {
          return daysSortOrder(rawValue: $0)?.order != nil
        }
        return first < second
      })
      .reduce("") {
        $0 == "" ?
          CHAssets.localized("ch.out_of_work.\($1)") :
          $0 + ", \(CHAssets.localized("ch.out_of_work.\($1)"))"
      }
    
    let fromValue = range.from
    let toValue = range.to

    let from = min(1439, fromValue)
    let to = min(1439, toValue)
    let fromTxt = from >= 720 ? "PM" : "AM"
    let toTxt = to >= 720 ? "PM" : "AM"
    let fromMin = from % 60
    let fromHour = from / 60 > 12 ? from / 60 - 12 : from / 60
    let toMin = to % 60
    let toHour = to / 60 > 12 ? to / 60 - 12 : to / 60

    let timeStr = String(
      format: "%@\n%d:%02d%@ ~ %d:%02d%@",
      days, fromHour, fromMin, fromTxt, toHour, toMin, toTxt
    )
    
    return timeStr
  }
  
  var workingTimeString: String {
    guard let workingTimeRanges = self.workingTimeRanges else { return "unknown" }
    
    return workingTimeRanges
      .reduce("") {
        $0 == "" ?
          self.rangeToWorkingTimeString($1) :
          $0 + "\n" + self.rangeToWorkingTimeString($1)
      } + "\n" + self.timeZone
  }
  
  func closestWorkingTime(from date: Date) -> (nextTime: Date, timeLeft: Int)? {
    guard self.workingType == .custom else { return nil }
    guard let workingTimeRanges = self.workingTimeRanges else { return nil }
    
    var workingTimes = DateUtils.emptyArrayWithWeekday()
    
    for range in workingTimeRanges {
      for dayString in range.dayOfWeeks {
        if let day = Weekday(rawValue: dayString) {
          workingTimes[day]?.append(range)
        }
      }
    }

    if workingTimes.reduce(true, { (result, workingTime) in
      return result && workingTime.value.count == 0
    }) {
      return nil
    }
    
    //convert to remote date
    guard let remoteTime = date.convertTimeZone(with: self.timeZone) else { return nil }
    //get weekday, minutes result
    if let result = DateUtils.getClosestTimeFromWeekdayRange(date: remoteTime, weekdayRange: workingTimes) {
      if remoteTime.minutes == result.time && remoteTime.weekday == result.weekday {
        //is in working hour...
        return (date, 0)
      }
      
      //this point, either before working time or after working time
      guard let nextDate = Date().next(weekday: result.weekday, mintues: result.time) else { return nil }
      
      //get weekday and left hours
      let components = date.diff(from: nextDate, components: [.hour, .minute,])
      if let hours = components.hour, let minutes = components.minute {
        let totalMinutes = hours * 60 + minutes
        return (nextDate, totalMinutes)
      }
      return nil
    }
    
    return nil
  }
}

extension CHChannel {
  static func get() -> _RXSwift_Observable<CHChannel> {
    return ChannelPromise.getChannel()
  }
}

extension CHChannel: Equatable {
  static func == (lhs:CHChannel, rhs:CHChannel) -> Bool {
    return lhs.id == rhs.id &&
      lhs.avatarUrl == rhs.avatarUrl &&
      lhs.initial == rhs.initial &&
      lhs.color == rhs.color &&
      lhs.name == rhs.name &&
      lhs.domain == rhs.domain &&
      lhs.phoneNumber == rhs.phoneNumber &&
      lhs.working == rhs.working &&
      lhs.textColor == rhs.textColor &&
      lhs.expectedResponseDelay == rhs.expectedResponseDelay &&
      lhs.messengerPlan == lhs.messengerPlan &&
      lhs.trial == rhs.trial &&
      lhs.awayOption == rhs.awayOption &&
      lhs.workingType == rhs.workingType &&
      lhs.allowNewChat == rhs.allowNewChat
  }
}

extension CHChannel: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {}
  
  mutating func mapping(map: ObjectMapper_Map) {
    id                      <- map["id"]
    avatarUrl               <- map["avatarUrl"]
    initial                 <- map["initial"]
    color                   <- map["color"]
    name                    <- map["name"]
    domain                  <- map["domain"]
    desc                    <- map["description"]
    defaultPluginId         <- map["defaultPluginId"]
    country                 <- map["country"]
    textColor               <- map["textColor"]
    phoneNumber             <- map["phoneNumber"]
    working                 <- map["working"]
    state                   <- map["state"]
    workingTimeRanges       <- map["workingTimeRanges"]
    requestUserInfo         <- map["requestUserInfo"]
    homepageUrl             <- map["homepageUrl"]
    expectedResponseDelay   <- map["expectedResponseDelay"] //delayed
    timeZone                <- map["timeZone"]
    utcOffset               <- map["utcOffset"]
    messengerPlan           <- map["messengerPlan"]
    supportBotPlan          <- map["supportBotPlan"]
    blocked                 <- map["blocked"]
    workingType             <- map["workingType"] //always, never, custom
    awayOption              <- map["awayOption"] //active, disabled, hidden
    trial                   <- map["trial"]
    trialEndDate            <- (map["trialEndDate"], CustomDateTransform())
  }
}

struct TimeRange {
  var dayOfWeeks: [String] = []
  var from = 0
  var to = 0
}

extension TimeRange : ExpressibleByArrayLiteral {
  typealias ArrayLiteralElement = Int
  
  init(arrayLiteral elements: Int...) {
    precondition(elements.count == 2)
    self.from = elements[0]
    self.to = elements[1]
  }
}

extension TimeRange : ObjectMapper_Mappable, Equatable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    dayOfWeeks <- map["dayOfWeeks"]
    from <- map["from"]
    to <- map["to"]
  }
  
  static func == (lhs:TimeRange, rhs:TimeRange) -> Bool {
    return lhs.from == rhs.from && lhs.to == lhs.to
  }
}

enum ChannelPlanType: String {
  case none
  case standard
  case pro
}

enum ChannelWorkingType: String {
  case always
  case never
  case custom
}

enum ChannelAwayOptionType: String {
  case active
  case disabled
  case hidden
}

enum ChannelState: String {
  case waiting
  case active
  case unpaid
  case banned
  case removed
}

enum daysSortOrder: String {
  case mon
  case tue
  case wed
  case thu
  case fri
  case sat
  case sun
  
  var order: Int {
    switch self {
    case .mon:
      return 1
    case .tue:
      return 2
    case .wed:
      return 3
    case .thu:
      return 4
    case .fri:
      return 5
    case .sat:
      return 6
    case .sun:
      return 7
    }
  }
}
