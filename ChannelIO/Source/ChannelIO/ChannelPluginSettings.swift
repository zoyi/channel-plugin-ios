//
//  ChannelPluginSettings.swift
//  CHPlugin
//
//  Created by Haeun Chung on 29/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct ChannelPluginSettingKey {
  static let pluginKey = "ch_pluginKey"
  static let legacy_userId = "ch_userId" //legacy
  static let memberId = "ch_memberId"
  static let memberHash = "ch_memberHash"
  static let debugMode = "ch_debugMode"
  static let launcherConfig = "ch_launcherConfig"
  static let hideDefaultLauncher = "ch_hideDefaultLauncher"
  static let hideDefaultInAppPush = "ch_hideDefaultInAppPush"
  static let enabledTrackDefaultEvent = "ch_enabledTrackDefaultEvent"
  static let language = "ch_locale"
}

@objc
public enum ChannelStage: Int {
  case development
  case staging
  case production
  
  internal var socketEndPoint: String {
    switch self {
    case .development: return "https://ws.exp.channel.io"
    case .staging: return "https://ws.staging.channel.io"
    case .production: return "https://ws.channel.io"
    }
  }
  
  internal var restEndPoint: String {
    switch self {
    case .development: return "https://api.exp.channel.io"
    case .staging: return "https://api.staging.channel.io"
    case .production: return "https://api.channel.io"
    }
  }
  
  internal var cdnEndPoint: String {
    switch self {
    case .development: return "https://media.exp.channel.io"
    case .staging: return "https://media.staging.channel.io"
    case .production: return "https://media.channel.io"
    }
  }
}

@objc
public class ChannelPluginSettings: NSObject, NSCoding {
  /* pluinkey that you can obtain from channel desk */
  @objc public var pluginKey: String = ""
  
  /* user id to distinguish normal user and anonymous user */
  @objc public var memberId: String? = nil
  
  /* user id to distinguish normal user and anonymous user */
  @objc public var memberHash: String? = nil
  
  /* true if debug information to be printed in console. Default is false */
  @objc public var debugMode: Bool = false
  
  /* launcher specific configuration object */
  @objc public var launcherConfig: LauncherConfig?
  
  /* true if default in-app push notification not to be displayed. Default is false */
  @objc public var hideDefaultInAppPush: Bool = false
  
  /* true if tracking default event. Default is true **/
  @objc public var enabledTrackDefaultEvent: Bool = true
  
  /* force to use a specific langauge. Currently supports en, ko, ja*/
  @objc public var language: CHLocale {
    get {
      if self.appLocale == .japanese {
        return .japanese
      } else if self.appLocale == .korean {
        return .korean
      } else {
        return .english
      }
    }
    set {
      if newValue == .device {
        let deviceLocale = CHUtils.getLocale()
        if deviceLocale == .japanese {
          self.appLocale = .japanese
        } else if deviceLocale == .korean {
          self.appLocale = .korean
        } else {
          self.appLocale = .english
        }
      } else if newValue == .korean {
        self.appLocale = .korean
      } else if newValue == .japanese {
        self.appLocale = .japanese
      } else {
        self.appLocale = .english
      }
    }
  }
  
  @objc public var stage: ChannelStage = .development
  
  var unsubscribed: Bool? = nil
  var appLocale: CHLocaleString? = nil
  
  @objc
  override public init() {
    super.init()
  }
  
  @objc
  public init(
    pluginKey: String,
    memberId: String? = nil,
    memberHash: String? = nil,
    debugMode: Bool = false,
    launcherConfig: LauncherConfig? = nil,
    hideDefaultInAppPush: Bool = false,
    enabledTrackDefaultEvent: Bool = true,
    language: CHLocale = .device) {
    super.init()
    
    self.pluginKey = pluginKey
    self.memberId = memberId
    self.memberHash = memberHash
    self.debugMode = debugMode
    self.launcherConfig = launcherConfig
    self.hideDefaultInAppPush = hideDefaultInAppPush
    self.enabledTrackDefaultEvent = enabledTrackDefaultEvent

    if language == .device {
      let deviceLocale = CHUtils.getLocale()
      if deviceLocale == .japanese {
        self.language = .japanese
      } else if deviceLocale == .korean {
        self.language = .korean
      } else {
        self.language = .english
      }
    } else {
      self.language = language
    }
  }
  
  required convenience public init(coder aDecoder: NSCoder) {
    //remove legacy key later
    let pluginKey = aDecoder.decodeObject(forKey: ChannelPluginSettingKey.pluginKey) as? String ?? ""
    let memberId = aDecoder.decodeObject(forKey: ChannelPluginSettingKey.legacy_userId) as? String ??
      aDecoder.decodeObject(forKey: ChannelPluginSettingKey.memberId) as? String
    let memberHash = aDecoder.decodeObject(forKey: ChannelPluginSettingKey.memberHash) as? String
    let debugMode = aDecoder.decodeBool(forKey: ChannelPluginSettingKey.debugMode)
    let launcherConfig = aDecoder.decodeObject(forKey: ChannelPluginSettingKey.launcherConfig) as? LauncherConfig
    let hideDefaultInAppPush = aDecoder.decodeBool(forKey: ChannelPluginSettingKey.hideDefaultInAppPush)
    let enabledTrackDefaultEvent = aDecoder.decodeBool(forKey: ChannelPluginSettingKey.enabledTrackDefaultEvent)
    let language = CHLocale(rawValue: aDecoder.decodeInteger(forKey: ChannelPluginSettingKey.language)) ?? .device
    
    self.init(
      pluginKey: pluginKey,
      memberId: memberId,
      memberHash: memberHash,
      debugMode: debugMode,
      launcherConfig: launcherConfig,
      hideDefaultInAppPush: hideDefaultInAppPush,
      enabledTrackDefaultEvent: enabledTrackDefaultEvent,
      language: language
    )
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.pluginKey, forKey: ChannelPluginSettingKey.pluginKey)
    aCoder.encode(self.memberId, forKey: ChannelPluginSettingKey.memberId)
    aCoder.encode(self.memberHash, forKey: ChannelPluginSettingKey.memberHash)
    aCoder.encode(self.debugMode, forKey: ChannelPluginSettingKey.debugMode)
    aCoder.encode(self.launcherConfig, forKey: ChannelPluginSettingKey.launcherConfig)
    aCoder.encode(self.hideDefaultInAppPush, forKey: ChannelPluginSettingKey.hideDefaultInAppPush)
    aCoder.encode(self.enabledTrackDefaultEvent, forKey: ChannelPluginSettingKey.enabledTrackDefaultEvent)
    aCoder.encode(self.language.rawValue, forKey: ChannelPluginSettingKey.language)
  }
  
  @discardableResult
  @objc
  public func set(memberId: String?) -> ChannelPluginSettings {
    self.memberId = memberId
    return self
  }
  
  @discardableResult
  @objc
  public func set(memberHash: String?) -> ChannelPluginSettings {
    self.memberHash = memberHash
    return self
  }
  
  @discardableResult
  @objc
  public func set(pluginKey: String) -> ChannelPluginSettings {
    self.pluginKey = pluginKey
    return self
  }
  
  @discardableResult
  @objc
  public func set(debugMode: Bool) -> ChannelPluginSettings {
    self.debugMode = debugMode
    return self
  }
  
  @discardableResult
  @objc
  public func set(launcherConfig: LauncherConfig?) -> ChannelPluginSettings {
    self.launcherConfig = launcherConfig
    return self
  }
  
  @discardableResult
  @objc
  public func set(hideDefaultInAppPush: Bool) -> ChannelPluginSettings {
    self.hideDefaultInAppPush = hideDefaultInAppPush
    return self
  }
  
  @discardableResult
  @objc
  public func set(enabledTrackDefaultEvent: Bool) -> ChannelPluginSettings {
    self.enabledTrackDefaultEvent = enabledTrackDefaultEvent
    return self
  }
  
  @discardableResult
  @objc
  public func set(language: CHLocale) -> ChannelPluginSettings {
    self.language = language
    return self
  }
  
  @discardableResult
  @objc
  public func set(unsubscribed: Bool) -> ChannelPluginSettings {
    self.unsubscribed = unsubscribed
    return self
  }
}
