//
//  Checkin.swift
//  CHPlugin
//
//  Created by Haeun Chung on 17/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//
import Foundation

@objc
public class Profile : NSObject {
  @objc var name: String? = nil
  @objc var avatarUrl: String? = nil
  @objc var mobileNumber: String? = nil
  @objc var email: String? = nil
  var property:[String:AnyObject?] = [:]
  
  @discardableResult
  @objc public func set(name: String) -> Profile {
    self.name = name
    return self
  }
  
  @discardableResult
  @objc public func set(avatarUrl: String) -> Profile {
    self.avatarUrl = avatarUrl
    return self
  }
  
  @discardableResult
  @objc public func set(mobileNumber: String) -> Profile {
    self.mobileNumber = mobileNumber
    return self
  }
  
  @discardableResult
  @objc public func set(email: String) -> Profile {
    self.email = email
    return self
  }
  
  @discardableResult
  @objc public func set(propertyKey:String, value:AnyObject?) -> Profile {
    self.property[propertyKey] = value
    return self
  }
}
