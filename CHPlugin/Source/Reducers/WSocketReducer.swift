//
//  WsSocketReducer.swift
//  CHPlugin
//
//  Created by Haeun Chung on 14/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

func socketReducer(action: Action, state: WSocketState?) -> WSocketState {
  var state = state
  switch action {
  case _ as SocketConnected:
    state?.state = .Connected
    return state ?? WSocketState()
  case _ as SocketReady:
    state?.state = .Ready
    return state ?? WSocketState()
  case _ as SocketDisconnected:
    state?.state = .Disconnected
    return state ?? WSocketState()
  case _ as SocketReconnecting:
    state?.state = .Reconnecting
    return state ?? WSocketState()
  case _ as JoinedUserChat:
    state?.state = .Joined
    return state ?? WSocketState()
  case _ as LeavedUserChat:
    state?.state = .Leaved
    return state ?? WSocketState()
  default:
    return state ?? WSocketState()
  }
}
