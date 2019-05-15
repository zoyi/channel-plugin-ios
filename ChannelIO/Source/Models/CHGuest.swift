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
}

extension CHGuest {
  func getWelcome() -> String? {
    if self.named {
      return mainStore.state.plugin.welcomeNamedI18n?.getMessage()?.replace("${name}", withString: self.name)
    } else {
      return mainStore.state.plugin.welcomeI18n?.getMessage()
    }
  }
  
  func updateProfile(key: String, value: Any?) -> Observable<(CHGuest?, Any?)> {
    return GuestPromise.updateProfile(with: [key: value])
  }
}
