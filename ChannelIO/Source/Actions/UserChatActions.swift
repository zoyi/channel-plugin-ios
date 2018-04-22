//
//  UserChatActions.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

struct GetUserChats: Action {
  public let payload: [String: Any?]
}

//struct FailedGetUserChats: Action {
//  public let error: Error
//}

struct GetMessages: Action {
  public let payload: [String: Any]
}

//struct FailedGetMessages: Action {
//  public let error: Error
//}

struct RemoveMessages: Action {
  public let payload: String?
}

struct GetUserChat: Action {
  public let payload: ChatResponse
}

struct CreateUserChat: Action {
  public let payload: CHUserChat
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

struct UpdateVisibilityOfCompletedChats: Action {
  public let show: Bool? 
}

