//
//  UserChatActions.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

struct FetchedUserChatPrep: ReSwift_Action {
  let followers: [CHManager]
  let plugin: CHPlugin
  let bot: CHBot?
  let supportBotEntry: CHSupportBotEntryInfo
}

struct GetUserChats: ReSwift_Action {
  let payload: UserChatsResponse
}

struct FailedGetUserChats: ReSwift_Action {
  let error: Error
}

struct GetMessages: ReSwift_Action {
  let payload: [String: Any]
}

//struct FailedGetMessages: Action {
//  let error: Error
//}

struct RemoveMessages: ReSwift_Action {
  let payload: String?
}

struct GetUserChat: ReSwift_Action {
  let payload: ChatResponse
}

struct CreateUserChat: ReSwift_Action {
  let payload: CHUserChat
}

struct UpdateUserChat: ReSwift_Action {
  let payload: CHUserChat
}

struct DeleteUserChat: ReSwift_Action {
  let payload: CHUserChat
}

struct DeleteUserChats: ReSwift_Action {
  let payload: [CHUserChat]
}

struct DeleteUserChatsAll: ReSwift_Action {}

struct JoinedUserChat: ReSwift_Action {
  let payload: String
}

struct LeavedUserChat: ReSwift_Action {
  let payload: String
}

//Update user
struct UpdateUser: ReSwift_Action {
  let payload: CHUser?
}

struct UpdateVisibilityOfCompletedChats: ReSwift_Action {
  let show: Bool?
}

struct UpdateVisibilityOfTranslation: ReSwift_Action {
  let show: Bool?
}

struct UserChatActions {
  static func openAgreement() {
    let locale = CHUtils.getLocale() ?? .korean
    let url = "https://channel.io/"
      + locale.rawValue
      + "/terms_user?plugin_key="
      + (ChannelIO.bootConfig?.pluginKey ?? "")
    
    guard let link = URL(string: url) else { return }
    link.open()
  }
}

