//
//  BotReducer.swift
//  CHPlugin
//
//  Created by Haeun Chung on 05/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

func botsReducer(action: Action, state: BotsState?) -> BotsState {
  var state = state
  switch action {
  case let action as GetBot:
    return state?.upsert(bot: action.payload) ?? BotsState()
    
  case let action as GetMessages:
    let bots = (action.payload["bots"] as? [CHBot]) ?? []
    return state?.upsert(bots: bots) ?? BotsState()

  case let action as GetUserChats:
    let bots = (action.payload["bots"] as? [CHBot]) ?? []
    return state?.upsert(bots: bots) ?? BotsState()
    
  case let action as GetPush:
    return state?.upsert(bot: action.payload.bot) ?? BotsState()
    
  case let action as GetPlugin:
    return state?.upsert(bot: action.bot) ?? BotsState()
    
  case let action as GetSupportBotEntry:
    if let bot = action.entry.supportBot {
      return state?.upsertSupportBots(bots: [bot]) ?? BotsState()
    }
    return state ?? BotsState()
    
  case let action as CreateLocalUserChat:
    if let bot = action.writer as? CHBot {
      return state?.upsert(bots: [bot]) ?? BotsState()
    }
    return state ?? BotsState()
    
  case _ as CheckOutSuccess:
    return state?.clear() ?? BotsState()
    
  default:
    return state ?? BotsState()
  }
}
