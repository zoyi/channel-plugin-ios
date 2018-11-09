//
//  Guest.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

protocol CHGuest: CHEntity {
  var named: Bool { get set }
  var mobileNumber: String? { get set }
  var profile: [String : Any]? { get set }
  var country: String { get set }
  var city: String { get set }
  
  var alert: Int { get set }
  var unread: Int { get set }
  var segment: String? { get set }
  
  var createdAt: Date? { get set }
  var updatedAt: Date? { get set }
}

extension CHGuest {
  var type: String! {
    if self is CHUser {
      return "User"
    } else {
      return "Veil"
    }
  }
  
  var userInfo: [String: Any] {
    var info: [String: Any] = [:]
    info[TargetKey.city.rawValue] = self.city
    info[TargetKey.country.rawValue] = self.country
    info[TargetKey.guestMobileNumber.rawValue] = self.mobileNumber ?? ""
    info[TargetKey.guestSegment.rawValue] = self.segment ?? ""
    info[TargetKey.guestCreatedAt.rawValue] = self.createdAt ?? Date()
    info[TargetKey.guestUpdatedAt.rawValue] = self.updatedAt ?? Date()
    info[TargetKey.locale.rawValue] = CHUtils.getLocale()?.rawValue ?? ""
    info[TargetKey.guestType.rawValue] = self.type
    info[TargetKey.guestName.rawValue] = self.name
    info[TargetKey.guestId.rawValue] = self.id
    if let profile = profile {
      info.merge(profile, uniquingKeysWith: { (first, _) in first })
    }
    return info
  }
}

extension CHGuest {
  func getWelcome() -> String? {
    if self.named {
      return mainStore.state.plugin.welcomeNamedI18n?.getMessage()?.replace("${name}", withString: self.name)
    } else {
      return mainStore.state.plugin.welcomeI18n?.getMessage()
    }
  }
  
  func touch() -> Observable<CHGuest> {
    return GuestPromise.touch()
  }
}
