//
//  PrefStore.swift
//  CHPlugin
//
//  Created by Haeun Chung on 06/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

class PrefStore {
  static let CHANNEL_ID_KEY = "CHPlugin_ChannelId"
  static let VEIL_ID_KEY = "CHPlugin_VeilId"
  static let USER_ID_KEY = "CHPlugin_UserId"
  static let PUSH_OPTION_KEY = "CHPlugin_PushOption"
  static let VISIBLE_CLOSED_USERCHAT_KEY = "CHPlugin_visible_closed_userchat"
  static let CHANNEL_PLUGIN_SETTINGS_KEY = "CHPlugin_settings"
  
  static func getCurrentChannelId() -> String? {
    return UserDefaults.standard.string(forKey: CHANNEL_ID_KEY)
  }
  
  static func getCurrentVeilId() -> String? {
    return UserDefaults.standard.string(forKey: VEIL_ID_KEY)
  }
  
  static func getCurrentUserId() -> String? {
    return UserDefaults.standard.string(forKey: USER_ID_KEY)
  }
  
  static func setCurrentChannelId(channelId: String) {
    UserDefaults.standard.set(channelId, forKey: CHANNEL_ID_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func setCurrentVeilId(veilId: String?) {
    if veilId != nil {
      UserDefaults.standard.set(veilId, forKey: VEIL_ID_KEY)
      UserDefaults.standard.synchronize()
    }
  }
  
  static func setCurrentUserId(userId: String?) {
    if userId != nil {
      UserDefaults.standard.set(userId, forKey: USER_ID_KEY)
      UserDefaults.standard.synchronize()
    }
  }
  
  static func clearCurrentChannelId() {
    UserDefaults.standard.removeObject(forKey: CHANNEL_ID_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func clearCurrentVeilId() {
    UserDefaults.standard.removeObject(forKey: VEIL_ID_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func clearCurrentUserId() {
    UserDefaults.standard.removeObject(forKey: USER_ID_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func setVisibilityOfClosedUserChat(on: Bool) {
    UserDefaults.standard.set(on, forKey: VISIBLE_CLOSED_USERCHAT_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func getVisibilityOfClosedUserChat() -> Bool {
    return UserDefaults.standard.bool(forKey: VISIBLE_CLOSED_USERCHAT_KEY)
  }
  
  static func setChannelPluginSettings(pluginSetting: ChannelPluginSettings) {
    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: pluginSetting)
    UserDefaults.standard.set(encodedData, forKey: CHANNEL_PLUGIN_SETTINGS_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func getChannelPluginSettings() -> ChannelPluginSettings? {
    if let data = UserDefaults.standard.object(forKey: CHANNEL_PLUGIN_SETTINGS_KEY) as? Data {
      return NSKeyedUnarchiver.unarchiveObject(with: data) as? ChannelPluginSettings
    }
    return nil
  }
  
  static func clearCurrentChannelPluginSettings() {
    UserDefaults.standard.removeObject(forKey: CHANNEL_PLUGIN_SETTINGS_KEY)
    UserDefaults.standard.synchronize()
  }
  
  static func clearAllLocalData() {
    PrefStore.clearCurrentUserId()
    PrefStore.clearCurrentVeilId()
    PrefStore.clearCurrentChannelId()
    PrefStore.clearCurrentChannelPluginSettings()
  }
}
