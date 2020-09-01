//
//  Models.swift
//  ChannelIO
//
//  Created by R3alFr3e on 5/23/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

// TODO: Will deprecated
@available(*, deprecated, renamed: "PushData")
@objc
public class PushEvent: NSObject {
  @objc public let chatId: String
  @objc public let message: String
  @objc public let senderName: String
  @objc public let senderAvatarUrl: String
  
  init(with pushData: CHPushDisplayable?) {
    self.chatId = pushData?.chatId ?? ""
    self.message = pushData?.blocks.reduce("") { $0 + ($1.displayText?.string ?? "") } ?? ""
    self.senderName = pushData?.writer?.name ?? ""
    self.senderAvatarUrl = pushData?.writer?.avatarUrl ?? ""
  }
  
  @objc
  public func toJson() -> Dictionary<String, Any> {
    return [
      "chatId": self.chatId,
      "message": self.message,
      "senderName": self.senderName,
      "senderAvatarUrl": self.senderAvatarUrl
    ]
  }
}

@objc
public class PushData: NSObject {
  @objc public let chatId: String
  @objc public let message: String
  @objc public let name: String
  @objc public let avatarUrl: String
  
  init(with pushData: CHPushDisplayable?) {
    self.chatId = pushData?.chatId ?? ""
    self.message = pushData?.blocks.reduce("") { $0 + ($1.displayText?.string ?? "") } ?? ""
    self.name = pushData?.writer?.name ?? ""
    self.avatarUrl = pushData?.writer?.avatarUrl ?? ""
  }
  
  @objc
  public func toJson() -> Dictionary<String, Any> {
    return [
      "chatId": self.chatId,
      "message": self.message,
      "name": self.name,
      "avatarUrl": self.avatarUrl
    ]
  }
}

@objc
public class User: NSObject {
  @objc public let id: String
  @objc public let memberId: String
  @objc public let name: String
  @objc public let avatarUrl: String?
  @objc public let profile: [String : Any]?
  @objc public let alert: Int
  @objc public let tags: [String]?
  @objc public let language: String?
  @objc public let unsubscribed: Bool
  
  init(with user: CHUser) {
    self.id = user.id
    self.memberId = user.memberId
    self.name = user.name
    self.avatarUrl = user.avatarUrl
    self.profile = user.profile
    self.alert = user.alert ?? 0
    self.tags = user.tags
    self.language = user.language
    self.unsubscribed = user.unsubscribed
  }
  
  @objc
  public func toJson() -> Dictionary<String, Any> {
    return [
      "id": self.id,
      "memberId": self.memberId,
      "name": self.name,
      "avatarUrl": self.avatarUrl ?? "",
      "profile": self.profile ?? "",
      "alert": self.alert,
      "tags": self.tags ?? [],
      "language": self.language ?? "",
      "unsubscribed": self.unsubscribed
    ]
  }
}

// TODO: Will deprecated
@available(*, deprecated, renamed: "ChannelButtonPosition")
@objc
public enum LauncherPosition: Int {
  case right
  case left
}

// TODO: Will deprecated
@available(*, deprecated, renamed: "ChannelButtonOption")
@objc
public class LauncherConfig: NSObject, NSCoding {
  @objc public var position: LauncherPosition = .right
  @objc public var xMargin: Float = 20
  @objc public var yMargin: Float = 20

  @objc
  override public init() { }
  
  @objc
  public init(position: LauncherPosition, xMargin: Float, yMargin: Float) {
    self.position = position
    self.xMargin = xMargin
    self.yMargin = yMargin
  }
  
  required convenience public init(coder aDecoder: NSCoder) {
    let position = LauncherPosition(
      rawValue: aDecoder.decodeInteger(forKey: "position")
    ) ?? .right
    let xMargin = aDecoder.decodeFloat(forKey: "xMargin")
    let yMargin = aDecoder.decodeFloat(forKey: "yMargin")
    
    self.init(position: position, xMargin: xMargin, yMargin: yMargin)
  }
 
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.position.rawValue, forKey: "position")
    aCoder.encode(self.xMargin, forKey: "xMargin")
    aCoder.encode(self.yMargin, forKey: "yMargin")
  }
}

@objc
public enum ChannelButtonPosition: Int {
  case right
  case left
}

@objc
public class ChannelButtonOption: NSObject, NSCoding {
  @objc public var position: ChannelButtonPosition = .right
  @objc public var xMargin: Float = 20
  @objc public var yMargin: Float = 20

  @objc
  override public init() { }
  
  @objc
  public init(position: ChannelButtonPosition, xMargin: Float, yMargin: Float) {
    self.position = position
    self.xMargin = xMargin
    self.yMargin = yMargin
  }
  
  init(launcherConfig: LauncherConfig?) {
    guard let launcherConfig = launcherConfig else { return }
    self.position = ChannelButtonPosition(rawValue: launcherConfig.position.rawValue) ?? .right
    self.xMargin = launcherConfig.xMargin
    self.yMargin = launcherConfig.yMargin
  }
  
  required convenience public init(coder aDecoder: NSCoder) {
    let position = ChannelButtonPosition(
      rawValue: aDecoder.decodeInteger(forKey: "position")
    ) ?? .right
    let xMargin = aDecoder.decodeFloat(forKey: "xMargin")
    let yMargin = aDecoder.decodeFloat(forKey: "yMargin")
    
    self.init(position: position, xMargin: xMargin, yMargin: yMargin)
  }
 
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.position.rawValue, forKey: "position")
    aCoder.encode(self.xMargin, forKey: "xMargin")
    aCoder.encode(self.yMargin, forKey: "yMargin")
  }
}
