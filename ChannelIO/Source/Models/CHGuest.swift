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
  
  var locale: String { get set }
  var alert: Int? { get set }
  var unread: Int? { get set }
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
    
  var dict: [String: Any] {
    var data = [String: Any]()
    
    data["named"] = self.named ? "true" : "false"
    data["country"] = self.country
    data["city"] = self.city
    data["locale"] = self.locale
    
    if let alert = self.alert {
      data["alert"] = alert
    }
    if let unread = self.unread {
      data["unread"] = unread
    }
    if let profile = self.profile {
      data["profile"] = profile
    }
    if let segment = self.segment {
      data["segment"] = segment
    }
    if let createdAt = self.createdAt {
      data["createdAt"] = UInt64(createdAt.timeIntervalSince1970 * 1000)
    }
    if let updatedAt = self.updatedAt {
      data["updatedAt"] = UInt64(updatedAt.timeIntervalSince1970 * 1000)
    }
    return data
  }
  
  func isSame(_ otherGuest: CHGuest) -> Bool {
    if self.type != otherGuest.type { return false }
    
    return self.named == otherGuest.named &&
      self.country == otherGuest.country &&
      self.city == otherGuest.city &&
      self.alert == otherGuest.alert &&
      self.unread == otherGuest.unread &&
      self.createdAt == otherGuest.createdAt &&
      self.updatedAt == otherGuest.updatedAt
  }
}

extension CHGuest {
  func getWelcome() -> NSAttributedString? {
    if self.named {
      return mainStore.state.plugin
        .welcomeNamedI18n?
        .getMessage()?
        .replace("${name}", with: self.name)
    } else {
      return mainStore.state.plugin
        .welcomeI18n?
        .getMessage()
    }
  }
  
  func updateProfile(key: String, value: Any?) -> Observable<(CHGuest?, Any?)> {
    return GuestPromise.updateProfile(with: [key: value])
  }
}
