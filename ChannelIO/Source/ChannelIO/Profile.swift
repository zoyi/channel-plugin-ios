//
//  Checkin.swift
//  CHPlugin
//
//  Created by Haeun Chung on 17/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//
import Foundation

@objc
public class Profile : NSObject, NSCoding {
  @objc var name: String? = nil
  @objc var avatarUrl: String? = nil
  @objc var mobileNumber: String? = nil
  @objc var email: String? = nil
  var property:[String:AnyObject?] = [:]
  
  @objc
  override public init() { }
  
  @objc
  public init(name: String?, avatarUrl: String?, mobileNumber: String?, email: String?) {
    self.name = name
    self.avatarUrl = avatarUrl
    self.mobileNumber = mobileNumber
    self.email = email
  }
  
  required convenience public init(coder aDecoder: NSCoder) {
    let name = aDecoder.decodeObject(forKey: "name") as? String
    let avatarUrl = aDecoder.decodeObject(forKey: "avatarUrl") as? String
    let mobileNumber = aDecoder.decodeObject(forKey: "mobileNumber") as? String
    let email = aDecoder.decodeObject(forKey: "email") as? String
    
    self.init(name: name, avatarUrl: avatarUrl, mobileNumber: mobileNumber, email: email)
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.name, forKey: "name")
    aCoder.encode(self.avatarUrl, forKey: "avatarUrl")
    aCoder.encode(self.mobileNumber, forKey: "mobileNumber")
    aCoder.encode(self.email, forKey: "email")
  }
  
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
