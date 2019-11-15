//
//  TargetType.swift
//  ChannelIO
//
//  Created by Haeun Chung on 18/10/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

enum TargetKey: String {
  case ip = "ip" //x
  case url = "url"
  case browser = "browser" //x
  case os = "os"
  case device = "device"
  case deviceCategory = "deviceCategory"
  case country = "country"
  case city = "city"
  case cookie = "cookie" //x subkey required
  case locale = "locale"
  case urlPath = "urlPath" //x
  case userId = "user.id"
  case userCreatedAt = "user.createdAt"
  case userUpdatedAt = "user.updatedAt"
  case userMobileNumber = "user.mobileNumber"
  case userName = "user.name"
  case userProfile = "user.profile" //subkey required
  case userSegment = "user.segment"
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
