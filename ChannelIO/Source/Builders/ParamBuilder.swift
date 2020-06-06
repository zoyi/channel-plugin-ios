//
//  ParamBuilder.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/08/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

typealias CHParam = [String: Any]

protocol ParamBuilder {
  func build() -> CHParam
}

class BootParamBuilder: ParamBuilder {
  var data = [String: Any]()
  var memberId: String? = nil
  var profile: Profile?
  var sessionJWT: String?
  var veilId: String?
  var unsubscribed: Bool?
  
  struct ParamKey {
    static let profile = "profile"
    static let memberId = "memberId"
    static let session = "sessionJWT"
    static let veilId = "veilId"
    static let unsubscribed = "unsubscribed"
  }
  
  @discardableResult
  func with(profile: Profile?) -> BootParamBuilder {
    self.profile = profile
    return self
  }
  
  @discardableResult
  func with(memberId: String?) -> BootParamBuilder {
    self.memberId = memberId
    return self
  }
  
  @discardableResult
  func with(sessionJWT: String?) -> BootParamBuilder {
    self.sessionJWT = sessionJWT
    return self
  }
  
  @discardableResult
  func with(veilId: String?) -> BootParamBuilder {
    self.veilId = veilId
    return self
  }
  
  @discardableResult
  func with(unsubscribed: Bool?) -> BootParamBuilder {
    self.unsubscribed = unsubscribed
    return self
  }
  
  private func buildProfile() -> [String: AnyObject?]? {
    guard let profile = self.profile else { return nil }
    
    var params = [String: AnyObject?]()
    if let name = profile.name as AnyObject? {
      params["name"] = name
    }
    if let email = profile.email as AnyObject? {
      params["email"] = email
    }
    if let mobileNumber = profile.mobileNumber as AnyObject? {
      params["mobileNumber"] = mobileNumber
    }
    if let avatarUrl = profile.avatarUrl as AnyObject? {
      params["avatarUrl"] = avatarUrl
    }
    
    let merged = params.merging(profile.property, uniquingKeysWith: { (first, _) in first })
    return merged
  }
  
  func build() -> CHParam {
    var data = [String: Any]()
    if let profile = self.buildProfile(),
      let jsonData = CHUtils.jsonStringify(data: profile) {
      data[ParamKey.profile] = jsonData
    }
    
    if let memberId = self.memberId {
      data[ParamKey.memberId] = memberId
    }
    
    if let veilId = self.veilId {
      data[ParamKey.veilId] = veilId
    } else if let veilId = PrefStore.getVeilId() {
      data[ParamKey.veilId] = veilId
    }
    
    if let unsubscribed = self.unsubscribed {
      data[ParamKey.unsubscribed] = unsubscribed
    }
    
    return ["url": data]
  }
}
