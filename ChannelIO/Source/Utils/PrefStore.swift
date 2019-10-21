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
  static let VISIBLE_CLOSED_USERCHAT_KEY = "CHPlugin_show_closed_userchat"
  static let CHANNEL_PLUGIN_SETTINGS_KEY = "CHPlugin_settings"
  static let VISIBLE_TRANSLATION = "CHPlugin_visible_translation"
  static let GUEST_KEY = "CHPlugin_x_guest_key"
  
  static var userDefaults: UserDefaults? = nil
  
  static func getStorage() -> UserDefaults {
    if NSClassFromString("XCTest") != nil {
      if let userDefaults = PrefStore.userDefaults {
        return userDefaults
      } else {
        PrefStore.userDefaults = MockUserDefaults()
        return PrefStore.userDefaults!
      }
    } else {
      return UserDefaults.standard
    }
  }
  
  static func getCurrentChannelId() -> String? {
    return PrefStore.getStorage().string(forKey: CHANNEL_ID_KEY)
  }
  
  static func getCurrentVeilId() -> String? {
    return PrefStore.getStorage().string(forKey: VEIL_ID_KEY)
  }
  
  static func getCurrentUserId() -> String? {
    return PrefStore.getStorage().string(forKey: USER_ID_KEY)
  }
  
  static func setCurrentChannelId(channelId: String) {
    PrefStore.getStorage().set(channelId, forKey: CHANNEL_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func setCurrentVeilId(veilId: String?) {
    if let veilId = veilId {
      PrefStore.getStorage().set(veilId, forKey: VEIL_ID_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func setCurrentUserId(userId: String?) {
    if let userId = userId {
      PrefStore.getStorage().set(userId, forKey: USER_ID_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func clearCurrentChannelId() {
    PrefStore.getStorage().removeObject(forKey: CHANNEL_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func clearCurrentVeilId() {
    PrefStore.getStorage().removeObject(forKey: VEIL_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func clearCurrentUserId() {
    PrefStore.getStorage().removeObject(forKey: USER_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func setVisibilityOfClosedUserChat(on: Bool) {
    PrefStore.getStorage().set(on, forKey: VISIBLE_CLOSED_USERCHAT_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func getVisibilityOfClosedUserChat() -> Bool {
    if let closed = PrefStore.getStorage().object(forKey: VISIBLE_CLOSED_USERCHAT_KEY) as? Bool {
      return closed
    }
    return true
  }
  
  static func setVisibilityOfTranslation(on: Bool) {
    PrefStore.getStorage().set(on, forKey: VISIBLE_TRANSLATION)
    PrefStore.getStorage().synchronize()
  }
  
  static func getVisibilityOfTranslation() -> Bool {
    if let visible = PrefStore.getStorage().object(forKey: VISIBLE_TRANSLATION) as? Bool {
      return visible
    }
    return true
  }
  
  static func setChannelPluginSettings(pluginSetting: ChannelPluginSettings) {
    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: pluginSetting)
    PrefStore.getStorage().set(encodedData, forKey: CHANNEL_PLUGIN_SETTINGS_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func getChannelPluginSettings() -> ChannelPluginSettings? {
    if let data = PrefStore.getStorage().object(forKey: CHANNEL_PLUGIN_SETTINGS_KEY) as? Data {
      return NSKeyedUnarchiver.unarchiveObject(with: data) as? ChannelPluginSettings
    }
    return nil
  }
  
  static func clearCurrentChannelPluginSettings() {
    PrefStore.getStorage().removeObject(forKey: CHANNEL_PLUGIN_SETTINGS_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func setCurrentGuestKey(_ key: String?) {
    if let key = key {
      PrefStore.getStorage().set(key, forKey: GUEST_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func getCurrentGuestKey() -> String? {
    return PrefStore.getStorage().string(forKey: GUEST_KEY)
  }
  
  static func clearCurrentGuestKey() {
    PrefStore.getStorage().removeObject(forKey: GUEST_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func clearAllLocalData() {
    PrefStore.clearCurrentUserId()
    PrefStore.clearCurrentVeilId()
    PrefStore.clearCurrentChannelId()
    PrefStore.clearCurrentChannelPluginSettings()
    PrefStore.clearCurrentGuestKey()
  }
}

class MockUserDefaults: UserDefaults {
  convenience init() {
    self.init(suiteName: "test user defaults")!
  }
  
  override init?(suiteName: String?) {
    UserDefaults().removePersistentDomain(forName: suiteName!)
    super.init(suiteName: suiteName)
  }
}
