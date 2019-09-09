//
//  PluginAction.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

struct CheckInSuccess: Action {
  public let payload: [String: Any]
}

struct CheckOutSuccess: Action {}

struct UpdateLoungeInfo: Action {
  public let channel: CHChannel
  public let plugin: CHPlugin
  public let bot: CHBot?
  public let operators: [CHManager]
}

struct GetPlugin: Action {
  public let plugin: CHPlugin
  public let bot: CHBot?
}

struct UpdateChannel: Action {
  public let payload: CHChannel
}

struct UpdateLocale: Action {
  public let payload: CHLocaleString
}

struct GetSupportBotEntry: Action {
  public let bot: CHBot?
  public let entry: CHSupportBotEntryInfo
}
