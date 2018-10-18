//
//  TargetType.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

enum TargetKey: String {
  case ip = "ip"
  case url = "url"
  case browser = "browser"
  case os = "os"
  case device = "device"
  case deviceCategory = "deviceCategory"
  case country = "country"
  case city = "city"
  case cookie = "cookie"
  case locale = "locale"
  case urlPath = "urlPath"
  case guestId = "guest.id"
  case guestType = "guest.type"
  case guestCreatedAt = "guest.createdAt"
  case guestUpdatedAt = "guest.updatedAt"
  case guestMobileNumber = "guest.mobileNumber"
  case guestName = "guest.name"
  case guestProfile = "guest.profile"
  case guestSegment = "guest.segment"
}

typealias TargetValue = String
typealias TargetSubKey = String

enum TargetOperator: String {
  case equal = "$eq"
  case notEqual = "$ne"
  case contain = "$in"
  case notContain = "$nin"
  case exist = "$exist"
  case notExist = "$nexist"
  case prefix = "$prefix"
  case notPrefix = "$nprefix"
  case greaterThan = "$gt"
  case greaterThanOrEqual = "$gte"
  case lessThan = "$lt"
  case lessThanOrEqual = "$lte"
  case regex = "$regex"
}
