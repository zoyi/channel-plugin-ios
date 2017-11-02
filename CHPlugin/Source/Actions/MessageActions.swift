//
//  MessageActions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

struct CreateMessage: Action {
  public let payload: CHMessage
}

struct UpdateMessage: Action {
  public let payload: CHMessage
}

struct DeleteMessage: Action {
  public let payload: CHMessage
}

// local message action
struct CreateUserInfoGuide: Action {
  public let payload: [String: Any]
}

struct UpdateUserInfoGuide: Action {
  public let payload: DialogType
}

struct CompleteUserInfoGuide: Action {}

struct CreateChannelClosed: Action {}

struct ClickBusinessHour: Action {
  public let payload: CHUserChat?
}

struct AnswerBusinessHour: Action {
  public let payload: CHUserChat?
}

struct InsertWelcome : Action {}

struct CreateFeedback: Action {}
struct CreateCompletedFeedback: Action {}
