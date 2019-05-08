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
  
  var userId: String? = nil
  var profile: Profile?
  var profileData: [String: Any]?
  var sysProfile: [String: Any]?
  var includeDefaultSysProfile = false
  
  struct ParamKey {
    static let profile = "profile"
    static let sysProfile = "sysProfile"
    static let userId = "userId"
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
  func with(userId: String?) -> BootParamBuilder {
    self.userId = userId
    return self
  }
  
  @discardableResult
  func with(sysProfile: [String: Any]?, includeDefault: Bool) -> BootParamBuilder {
    self.sysProfile = sysProfile
    self.includeDefaultSysProfile = includeDefault
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
  
  private func buildSysProps() -> [String: Any]? {
    var params = [String :Any]()
    if let sysProfile = self.sysProfile {
      params = sysProfile
    }
    
    if !self.includeDefaultSysProfile {
      return [ParamKey.sysProfile:params]
    }
    
    params["platform"] = "iOS"
    params["version"] = Bundle(for: ChannelIO.self)
      .infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    
    return params
  }
  
  func build() -> CHParam {
    var data = [String: Any]()
    if let profile = self.buildProfile() {
      data[ParamKey.profile] = profile
    }
    
    if let profileData = self.buildProfileData() {
      if let profile = data[ParamKey.profile] as? [String: Any] {
        data[ParamKey.profile] = profile.merging(profileData, uniquingKeysWith: { (_, second) in second })
      } else {
        data[ParamKey.profile] = profileData
      }
    }
    
    if let sysProfile = self.buildSysProps() {
      data[ParamKey.sysProfile] = sysProfile
    }
    
    if let userId = self.userId {
      data[ParamKey.userId] = userId
    }
    
    return ["body": data]
  }
}
