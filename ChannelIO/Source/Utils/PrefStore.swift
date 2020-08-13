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
  static let USER_ID_KEY = "CHPlugin_UserId"
  static let PUSH_OPTION_KEY = "CHPlugin_PushOption"
  static let VISIBLE_CLOSED_USERCHAT_KEY = "CHPlugin_show_closed_userchat"
  static let CHANNEL_PLUGIN_SETTINGS_KEY = "CHPlugin_settings"
  static let BOOT_CONFIG = "CHBoot_Config"
  static let VISIBLE_TRANSLATION = "CHPlugin_visible_translation"
  static let SESSION_JWT_KEY = "CHPlugin_session_jwt"
  static let VEIL_ID_KEY = "CHPlugin_veil_id"
  static let MEMBER_ID_KEY = "CHPlugin_member_id"
  static let PUSH_DATA = "CHPlugin_push_data"
  static let TOKEN_STATE = "CHPlugin_token_state"
  
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
  
  static func getCurrentUserId() -> String? {
    return PrefStore.getStorage().string(forKey: USER_ID_KEY)
  }
  
  static func setCurrentUserId(_ userId: String?) {
    if let userId = userId {
      PrefStore.getStorage().set(userId, forKey: USER_ID_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func clearCurrentUserId() {
    PrefStore.getStorage().removeObject(forKey: USER_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func getCurrentMemberId() -> String? {
    return PrefStore.getStorage().string(forKey: MEMBER_ID_KEY)
  }
  
  static func setCurrentMemberId(_ memberId: String?) {
    if let memberId = memberId {
      PrefStore.getStorage().set(memberId, forKey: MEMBER_ID_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func clearCurrentMemberId() {
    PrefStore.getStorage().removeObject(forKey: MEMBER_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func getCurrentChannelId() -> String? {
    return PrefStore.getStorage().string(forKey: CHANNEL_ID_KEY)
  }
  
  static func setCurrentChannelId(channelId: String) {
    PrefStore.getStorage().set(channelId, forKey: CHANNEL_ID_KEY)
    PrefStore.getStorage().synchronize()
  }

  static func clearCurrentChannelId() {
    PrefStore.getStorage().removeObject(forKey: CHANNEL_ID_KEY)
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
  // TODO: Will deprecated
  static func setChannelPluginSettings(pluginSetting: ChannelPluginSettings) {
    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: pluginSetting)
    PrefStore.getStorage().set(encodedData, forKey: CHANNEL_PLUGIN_SETTINGS_KEY)
    PrefStore.getStorage().synchronize()
  }
  // TODO: Will deprecated
  static func getChannelPluginSettings() -> ChannelPluginSettings? {
    if let data = PrefStore.getStorage().object(forKey: CHANNEL_PLUGIN_SETTINGS_KEY) as? Data {
      return NSKeyedUnarchiver.unarchiveObject(with: data) as? ChannelPluginSettings
    }
    return nil
  }
  // TODO: Will deprecated
  static func clearCurrentChannelPluginSettings() {
    PrefStore.getStorage().removeObject(forKey: CHANNEL_PLUGIN_SETTINGS_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func setBootConfig(bootConfig: BootConfig) {
    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: bootConfig)
    PrefStore.getStorage().set(encodedData, forKey: BOOT_CONFIG)
    PrefStore.getStorage().synchronize()
  }

  static func getBootConfig() -> BootConfig? {
    if let data = PrefStore.getStorage().object(forKey: BOOT_CONFIG) as? Data {
      return NSKeyedUnarchiver.unarchiveObject(with: data) as? BootConfig
    }
    return nil
  }

  static func clearBootConfig() {
    PrefStore.getStorage().removeObject(forKey: BOOT_CONFIG)
    PrefStore.getStorage().synchronize()
  }
  
  static func getTokenState() -> Bool {
    return PrefStore.getStorage().bool(forKey: TOKEN_STATE)
  }
  
  static func setTokenState(_ isRegster: Bool) {
    PrefStore.getStorage().set(isRegster, forKey: TOKEN_STATE)
    PrefStore.getStorage().synchronize()
  }
  
  static func clearTokenState() {
    PrefStore.getStorage().removeObject(forKey: TOKEN_STATE)
    PrefStore.getStorage().synchronize()
  }
  
  static func setSessionJWT(_ jwt: String?) {
    if let jwt = jwt {
      PrefStore.getStorage().set(jwt, forKey: SESSION_JWT_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func getSessionJWT() -> String? {
    return PrefStore.getStorage().string(forKey: SESSION_JWT_KEY)
  }
  
  static func clearSessionJWT() {
    PrefStore.getStorage().removeObject(forKey: SESSION_JWT_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func setVeilId(_ veilId: String?) {
    if let veilId = veilId {
      PrefStore.getStorage().set(veilId, forKey: VEIL_ID_KEY)
      PrefStore.getStorage().synchronize()
    }
  }
  
  static func getVeilId() -> String? {
    return PrefStore.getStorage().string(forKey: VEIL_ID_KEY)
  }
  
  static func clearVeilId() {
    PrefStore.getStorage().removeObject(forKey: VEIL_ID_KEY)
    PrefStore.getStorage().synchronize()
  }
  
  static func setPushData(userInfo: [AnyHashable : Any]) {
    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: userInfo)
    PrefStore.getStorage().set(encodedData, forKey: PUSH_DATA)
    PrefStore.getStorage().synchronize()
  }
  
  static func getPushData() -> [AnyHashable : Any]? {
    if let data = PrefStore.getStorage().object(forKey: PUSH_DATA) as? Data {
      return NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable : Any]
    }
    return nil
  }
  
  static func clearPushData() {
    PrefStore.getStorage().removeObject(forKey: PUSH_DATA)
    PrefStore.getStorage().synchronize()
  }
  
  static func clearAllLocalData() {
    PrefStore.clearCurrentUserId()
    PrefStore.clearCurrentMemberId()
    PrefStore.clearCurrentChannelId()
    PrefStore.clearCurrentChannelPluginSettings()
    if ChannelIO.isNewVersion {
      if PrefStore.getTokenState() == false {
        PrefStore.clearBootConfig()
      }
    } else {
      PrefStore.clearSessionJWT()
    }
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
