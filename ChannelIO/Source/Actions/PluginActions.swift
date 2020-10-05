//
//  PluginAction.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

struct GetTouchSuccess: ReSwift_Action {
  let payload: BootResponse
}

struct BootSuccess: ReSwift_Action {
  let payload: BootResponse
}

struct ShutdownSuccess: ReSwift_Action {
  let isSleeping: Bool
}

struct UpdateLoungeInfo: ReSwift_Action {
  let channel: CHChannel
  let plugin: CHPlugin
  let bot: CHBot?
  let operators: [CHManager]
  let supportBotEntryInfo: CHSupportBotEntryInfo?
  let userChats: UserChatsResponse
}

struct GetPlugin: ReSwift_Action {
  let plugin: CHPlugin
  let bot: CHBot?
}

struct UpdateChannel: ReSwift_Action {
  let payload: CHChannel
}

struct UpdateLocale: ReSwift_Action {
  let payload: CHLocaleString
}
