//
//  ChannelPluginSettings.swift
//  CHPlugin
//
//  Created by Haeun Chung on 29/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

@objc
public class ChannelPluginSettings: NSObject, NSCoding {
  /* pluinkey that you can obtain from channel desk */
  @objc public var pluginKey: String = ""
  
  /* true if debug information to be printed in console. Default is false */
  @objc public var debugMode: Bool = false
  
  /* true if default launcher button not to be displayed. Default is false */
  @objc public var hideDefaultLauncher: Bool = false
  
  /* true if default in-app push notification not to be displayed. Default is false */
  @objc public var hideDefaultInAppPush: Bool = false
  
  /* true if tracking default event. Default is true **/
  @objc public var enabledTrackDefaultEvent: Bool = true
  
  /* force to use a specific langauge. Currently supports en, ko, ja*/
  @objc public var locale: String? {
    get {
      return self.appLocale?.rawValue
    }
    set {
      if locale == "en" {
        self.appLocale = .english
      } else if locale == "ko" {
        self.appLocale = .korean
      } else if locale == "ja" {
        self.appLocale = .japanese
      } else {
        self.appLocale = nil
      }
    }
  }
  
  var appLocale: CHLocale? = nil
  
  @objc
  override public init() {
    super.init()
  }
  
  @objc
  public init(
    pluginKey: String,
    debugMode: Bool = false,
    hideDefaultLauncher: Bool = false,
    hideDefaultInAppPush: Bool = false,
    enabledTrackDefaultEvent: Bool = true,
    locale: String? = nil) {
    super.init()
    
    self.pluginKey = pluginKey
    self.debugMode = debugMode
    self.hideDefaultLauncher = hideDefaultLauncher
    self.hideDefaultInAppPush = hideDefaultInAppPush
    self.enabledTrackDefaultEvent = enabledTrackDefaultEvent
    self.locale = locale
  }
  
  required convenience public init(coder aDecoder: NSCoder) {
    let pluginKey = aDecoder.decodeObject(forKey: "pluginKey") as! String
    let debugMode = aDecoder.decodeBool(forKey: "debugMode")
    let hideDefaultLauncher = aDecoder.decodeBool(forKey: "hideDefaultLauncher")
    let hideDefaultInAppPush = aDecoder.decodeBool(forKey: "hideDefaultInAppPush")
    let enabledTrackDefaultEvent = aDecoder.decodeBool(forKey: "enabledTrackDefaultEvent")
    let locale = aDecoder.decodeObject(forKey: "locale") as? String
    
    self.init(pluginKey: pluginKey,
              debugMode: debugMode,
              hideDefaultLauncher: hideDefaultLauncher,
              hideDefaultInAppPush: hideDefaultInAppPush,
              enabledTrackDefaultEvent: enabledTrackDefaultEvent,
              locale: locale)
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.pluginKey, forKey: "pluginKey")
    aCoder.encode(self.debugMode, forKey: "debugMode")
    aCoder.encode(self.hideDefaultLauncher, forKey: "hideDefaultLauncher")
    aCoder.encode(self.hideDefaultInAppPush, forKey: "hideDefaultInAppPush")
    aCoder.encode(self.enabledTrackDefaultEvent, forKey: "enabledTrackDefaultEvent")
    aCoder.encode(self.appLocale?.rawValue, forKey: "locale")
  }
}
