//
//  MessageActions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

struct CreateMessage: ReSwift_Action {
  let payload: CHMessage?
}

struct UpdateMessage: ReSwift_Action {
  let payload: CHMessage
}

struct DeleteMessage: ReSwift_Action {
  let payload: CHMessage
}

// local message action

struct InsertWelcome : ReSwift_Action {}
struct InsertSupportBotEntry: ReSwift_Action {}
