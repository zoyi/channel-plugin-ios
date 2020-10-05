//
//  SessionActions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 2/11/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

struct CreateSession: ReSwift_Action {
  let payload: CHSession?
}

struct UpdateSession: ReSwift_Action {
  let payload: CHSession?
}

struct DeleteSession: ReSwift_Action {
  let payload: CHSession?
}

struct UpdateManager: ReSwift_Action {
  let payload: CHManager
}

struct UpdateFollowingManagers: ReSwift_Action {
  let payload: [CHManager]
}

struct ReadSession: ReSwift_Action {
  let payload: CHSession?
}
