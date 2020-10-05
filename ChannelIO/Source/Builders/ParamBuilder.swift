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
  var memberHash: String? = nil
  var profile: Profile?
  var sessionJWT: String?
  var veilId: String?
  var unsubscribed: Bool?
  
  struct ParamKey {
    static let profile = "profile"
    static let memberId = "memberId"
    static let memberHash = "memberHash"
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
  func with(memberHash: String?) -> BootParamBuilder {
    self.memberHash = memberHash
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
    
    if let memberHash = self.memberHash {
      data[ParamKey.memberHash] = memberHash
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

public typealias UpdateUserParam = [String: Any]

public class UpdateUserParamBuilder: ParamBuilder {
  private var params = [
    "body": [String: AnyObject?]()
  ]
  
  private struct ParamKey {
    static let profile = "profile"
    static let profileOnce = "profileOnce"
    static let tags = "tags"
    static let language = "language"
  }
  
  @discardableResult
  public func with(profile: [String: Any?]?) -> UpdateUserParamBuilder {
    self.params["body"]?[ParamKey.profile] =  profile?
      .mapValues { (value) -> AnyObject? in
        return value as AnyObject?
      } as AnyObject?
    
    return self
  }
  
  @discardableResult
  public func with(profileOnce: [String: Any?]?) -> UpdateUserParamBuilder {
    self.params["body"]?[ParamKey.profileOnce] = profileOnce?
      .mapValues { (value) -> AnyObject? in
        return value as AnyObject?
      } as AnyObject?
    return self
  }
  
  @discardableResult
  public func with(tags: [String]?) -> UpdateUserParamBuilder {
    self.params["body"]?[ParamKey.tags] = tags as AnyObject?
    return self
  }
  
  @discardableResult
  public func with(language: LanguageOption) -> UpdateUserParamBuilder {
    guard language != .device else { return self }
    
    var locale: CHLocaleString = .english
    if language == .japanese {
      locale = .japanese
    } else if language == .korean {
      locale = .korean
    } else {
      locale = .english
    }
    
    self.params["body"]?[ParamKey.language] = locale.rawValue as AnyObject?
    return self
  }
  
  public func build() -> UpdateUserParam {
    return self.params
  }
}

public class UpdateUserParamObjcBuilder: NSObject, ParamBuilder {
  private var params = [
    "body": [String: AnyObject?]()
  ]
  
  private var profile:[String:AnyObject?] = [:]
  private var profileOnce:[String:AnyObject?] = [:]
  
  private var hasProfile = false
  private var hasProfileOnce = false
  
  private struct ParamKey {
    static let profile = "profile"
    static let profileOnce = "profileOnce"
    static let tags = "tags"
    static let language = "language"
  }
  
  @discardableResult
  @objc public func with(profileKey:String, value:AnyObject?) -> UpdateUserParamObjcBuilder {
    self.hasProfile = true
    self.profile[profileKey] = value
    return self
  }
  
  @discardableResult
  @objc public func setProfileNil() -> UpdateUserParamObjcBuilder {
    self.hasProfile = true
    self.profile = [:]
    return self
  }
  
  @discardableResult
  @objc public func with(profileOnceKey:String, value:AnyObject?) -> UpdateUserParamObjcBuilder {
    self.hasProfileOnce = true
    self.profileOnce[profileOnceKey] = value
    return self
  }
  
  @discardableResult
  @objc public func setProfileOnceNil() -> UpdateUserParamObjcBuilder {
    self.hasProfileOnce = true
    self.profileOnce = [:]
    return self
  }
  
  @discardableResult
  @objc
  public func with(tags: [String]?) -> UpdateUserParamObjcBuilder {
    self.params["body"]?[ParamKey.tags] = tags as AnyObject?
    return self
  }
  
  @discardableResult
  @objc
  public func with(language: LanguageOption) -> UpdateUserParamObjcBuilder {
    guard language != .device else { return self }
    
    var locale: CHLocaleString = .english
    if language == .japanese {
      locale = .japanese
    } else if language == .korean {
      locale = .korean
    } else {
      locale = .english
    }
    
    self.params["body"]?[ParamKey.language] = locale.rawValue as AnyObject?
    return self
  }
  
  @objc
  public func build() -> UpdateUserParam {
    if self.hasProfile, self.profile.count != 0 {
      self.params["body"]?[ParamKey.profile] = self.profile
        .mapValues { (value) -> AnyObject? in
          return value as AnyObject?
        } as AnyObject?
    } else if hasProfile, self.profile.count == 0 {
      self.params["body"]?[ParamKey.profile] = nil as AnyObject?
    }
    
    if self.hasProfileOnce, self.profileOnce.count != 0 {
      self.params["body"]?[ParamKey.profileOnce] = self.profileOnce
        .mapValues { (value) -> AnyObject? in
          return value as AnyObject?
        } as AnyObject?
    } else if self.hasProfileOnce, self.profileOnce.count == 0 {
      self.params["body"]?[ParamKey.profileOnce] = nil as AnyObject?
    }
    
    return self.params
  }
}

