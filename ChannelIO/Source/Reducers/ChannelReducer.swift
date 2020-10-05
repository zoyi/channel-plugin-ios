//
//  ChannelReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

func channelReducer(action: ReSwift_Action, channel: CHChannel?) -> CHChannel {
  switch action {
    
  case let action as BootSuccess:
    if let channel = action.payload.channel {
      PrefStore.setCurrentChannelId(channelId: channel.id)
      return channel
    }
    return CHChannel()
    
  case let action as ShutdownSuccess:
    PrefStore.clearAllLocalData(isSleeping: action.isSleeping)
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
