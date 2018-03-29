//
//  ChannelPluginSettings.swift
//  CHPlugin
//
//  Created by Haeun Chung on 29/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

@objc
public class ChannelPluginSettings: NSObject {
  /** pluinkey that you can obtain from channel desk **/
  @objc public var pluginKey: String = ""
  
  /** true if debug information to be printed in console. Default is false **/
  @objc public var debugMode: Bool = false
  
  /** true if default launcher button not to be displayed. Default is false **/
  @objc public var hideDefaultLauncher: Bool = false
  
  /** true if default in-app push notification not to be displayed. Default is false **/
  @objc public var hideDefaultInAppPush: Bool = false
  
  /** true if tracking default event. Default is true **/
  @objc public var enabledTrackDefaultEvent: Bool = true
  
  /** **/
  var locale: String = ""
  
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
}
