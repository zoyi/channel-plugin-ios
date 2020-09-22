//
//  PluginAction.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

struct GetTouchSuccess: ReSwift_Action {
  public let payload: BootResponse
}

struct BootSuccess: ReSwift_Action {
  public let payload: BootResponse
}

struct ShutdownSuccess: ReSwift_Action {
  public let isSleeping: Bool
}

struct UpdateLoungeInfo: ReSwift_Action {
  public let channel: CHChannel
  public let plugin: CHPlugin
  public let bot: CHBot?
  public let operators: [CHManager]
  public let supportBotEntryInfo: CHSupportBotEntryInfo?
  public let userChats: UserChatsResponse
}

struct GetPlugin: ReSwift_Action {
  public let plugin: CHPlugin
  public let bot: CHBot?
}

struct UpdateChannel: ReSwift_Action {
  public let payload: CHChannel
}

struct UpdateLocale: ReSwift_Action {
  public let payload: CHLocaleString
}
