//
//  ChannelReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

func channelReducer(action: Action, channel: CHChannel?) -> CHChannel {
  switch action {
    
  case let action as BootSuccess:
    if let channel = action.payload.channel {
      PrefStore.setCurrentChannelId(channelId: channel.id)
      return channel
    }
    return CHChannel()
    
  case _ as ShutdownSuccess:
    PrefStore.clearAllLocalData()
    RestRouter.channelId = ""
    return CHChannel()
    
  case let action as UpdateLoungeInfo:
    return action.channel
    
  case let action as UpdateChannel:
    return action.payload
    
  default:
    return channel ?? CHChannel()
  }
}
