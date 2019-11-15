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
  var profileData: [String: Any]?
  var sessionJWT: String?
  var veilId: String?
  
  struct ParamKey {
    static let profile = "profile"
    static let memberId = "memberId"
    static let session = "sessionJWT"
    static let veilId = "veilId"
  }
  
  @discardableResult
  func with(profile: [String: Any]) -> BootParamBuilder {
    self.profileData = profile
    return self
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
  
  private func buildProfileData() -> [String: Any]? {
    guard let profileData = self.profileData else { return nil }
    return profileData
  }
  
  private func buildProfile() -> [String: Any?]? {
    guard let profile = self.profile else { return nil }
    
    var params = [String: Any?]()
    params["name"] = profile.name
    params["email"] = profile.email
    params["mobileNumber"] = profile.mobileNumber
    params["avatarUrl"] = profile.avatarUrl
    
    let merged = params.merging(profile.property, uniquingKeysWith: { (first, _) in first })
    return merged
  }
  
  func build() -> CHParam {
    var data = [String: Any]()
    if let profile = self.buildProfile(),
      let jsonData = CHUtils.jsonStringify(data: profile) {
      data[ParamKey.profile] = jsonData
    }
    
    if let profileData = self.buildProfileData() {
      if let profile = data[ParamKey.profile] as? [String: Any] {
        let merged = profile.merging(profileData, uniquingKeysWith: { (_, second) in second })
        let jsonData = CHUtils.jsonStringify(data: merged)
        if let jsonData = jsonData {
          data[ParamKey.profile] = jsonData
        }
      } else if let jsonData = CHUtils.jsonStringify(data: profileData) {
        data[ParamKey.profile] = jsonData
      }
    }
    
    if let memberId = self.memberId {
      data[ParamKey.memberId] = memberId
    }
    
    if let veilId = self.veilId {
      data[ParamKey.veilId] = veilId
    } else if let veilId = PrefStore.getVeilId() {
      data[ParamKey.veilId] = veilId
    }
    
//    if let sessionJWT = self.sessionJWT {
//      data[ParamKey.session] = sessionJWT
//    } else if let sessionJWT = PrefStore.getSessionJWT() {
//      data[ParamKey.session] = sessionJWT
//    }
    
    return ["url": data]
  }
}
