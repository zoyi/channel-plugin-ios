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
  
  /* */
  var locale: String = ""
  
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
    enabledTrackDefaultEvent: Bool = true) {
    self.pluginKey = pluginKey
    self.debugMode = debugMode
    self.hideDefaultLauncher = hideDefaultLauncher
    self.hideDefaultInAppPush = hideDefaultInAppPush
    self.enabledTrackDefaultEvent = enabledTrackDefaultEvent
  }
  
  required convenience public init(coder aDecoder: NSCoder) {
    let pluginKey = aDecoder.decodeObject(forKey: "pluginKey") as! String
    let debugMode = aDecoder.decodeBool(forKey: "debugMode")
    let hideDefaultLauncher = aDecoder.decodeBool(forKey: "hideDefaultLauncher")
    let hideDefaultInAppPush = aDecoder.decodeBool(forKey: "hideDefaultInAppPush")
    let enabledTrackDefaultEvent = aDecoder.decodeBool(forKey: "enabledTrackDefaultEvent")
    self.init(pluginKey: pluginKey,
              debugMode: debugMode,
              hideDefaultLauncher: hideDefaultLauncher,
              hideDefaultInAppPush: hideDefaultInAppPush,
              enabledTrackDefaultEvent: enabledTrackDefaultEvent
    )
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.pluginKey, forKey: "pluginKey")
    aCoder.encode(self.debugMode, forKey: "debugMode")
    aCoder.encode(self.hideDefaultLauncher, forKey: "hideDefaultLauncher")
    aCoder.encode(self.hideDefaultInAppPush, forKey: "hideDefaultInAppPush")
    aCoder.encode(self.enabledTrackDefaultEvent, forKey: "enabledTrackDefaultEvent")
  }
}
