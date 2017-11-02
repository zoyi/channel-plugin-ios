//
//  Checkin.swift
//  CHPlugin
//
//  Created by Haeun Chung on 17/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

@objc
public class CheckIn : NSObject {
  var userId = ""
  var name = ""
  var avatarUrl = ""
  var mobileNumber = ""
  var meta = [String:Any]()
  
  public override init() {
    
  }
  
  @discardableResult
  public func with(name: String) -> CheckIn {
    self.name = name
    return self
  }
  
  @discardableResult
  public func with(userId: String) -> CheckIn {
    self.userId = userId
    return self
  }
  
  @discardableResult
  public func with(avatarUrl: String) -> CheckIn {
    self.avatarUrl = avatarUrl
    return self
  }
  
  @discardableResult
  public func with(mobileNumber: String) -> CheckIn {
    self.mobileNumber = mobileNumber
    return self
  }
  
  @discardableResult
  public func with(metaKey:String, metaValue:Any) -> CheckIn {
    self.meta[metaKey] = metaValue
    return self
  }
  
  internal func generateParams() -> [String: Any] {
    var params = [String: Any]()
    if self.name != "" {
      params["name"] = self.name
    }
    
    if self.mobileNumber != "" {
      params["mobileNumber"] = self.mobileNumber
    }
    
    if self.avatarUrl != "" {
      params["avatarUrl"] = self.avatarUrl
    }
    
    if self.meta.count != 0 {
      params["meta"] = self.meta
    }
    
    return params
  }
}
