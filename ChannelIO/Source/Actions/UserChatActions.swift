//
//  UserChatActions.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

struct FetchedUserChatPrep: Action {
  public let followers: [CHManager]
  public let plugin: CHPlugin
  public let bot: CHBot?
  public let supportBotEntry: CHSupportBotEntryInfo
}

struct GetUserChats: Action {
  public let payload: [String: Any?]
}

struct FailedGetUserChats: Action {
  public let error: Error
}

struct GetMessages: Action {
  public let payload: [String: Any]
}

//struct FailedGetMessages: Action {
//  public let error: Error
//}

struct RemoveMessages: Action {
  public let payload: String?
}

struct GetNudgeChat: Action {
  public let nudgeId: String
  public let payload: ChatResponse
}

struct GetUserChat: Action {
  public let payload: ChatResponse
}

struct CreateUserChat: Action {
  public let payload: CHUserChat
}

struct CreateLocalUserChat: Action {
  public let chat: CHUserChat?
  public let message: CHMessage?
  public let writer: CHEntity?
  public let session: CHSession?
}

struct UpdateUserChat: Action {
  public let payload: CHUserChat
}

struct DeleteUserChat: Action {
  public let payload: String
}

struct DeleteUserChats: Action {
  public let payload: [String]
}

struct DeleteUserChatsAll: Action {}

struct JoinedUserChat: Action {
  public let payload: String
}

struct LeavedUserChat: Action {
  public let payload: String
}

//Update user
struct UpdateGuest: Action {
  public let payload: CHGuest?
}

struct UpdateGuestWithLocalRead: Action {
  public let guest: CHGuest?
  public let session: CHSession?
}

struct UpdateVisibilityOfCompletedChats: Action {
  public let show: Bool? 
}

struct UpdateVisibilityOfTranslation: Action {
  public let show: Bool?
}

struct UserChatActions {
  static func openAgreement() {
    let locale = CHUtils.getLocale() ?? .korean
    let url = "https://channel.io/" + locale.rawValue +
      "/terms_user?plugin_key=" + (mainStore.state.settings?.pluginKey ?? "")
    
    guard let link = URL(string: url) else { return }
    link.open()
  }
}

