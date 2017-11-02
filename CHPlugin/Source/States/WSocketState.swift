//
//  WsSocketState.swift
//  CHPlugin
//
//  Created by Haeun Chung on 14/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

enum WebSocketState {
  case None //initial
  case Joined
  case Leaved
  case Ready
  case Connected
  case Disconnected
  case Reconnecting
}

struct WSocketState: StateType {
  var state: WebSocketState = .None
}
