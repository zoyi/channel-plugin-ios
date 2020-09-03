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
    return state?.upsert(bots: action.payload.bots ?? []) ?? BotsState()
    
  case let action as GetUserChat:
    return state?.upsert(bot: action.payload.bot) ?? BotsState()
    
  case let action as GetPopup:
    if let popup = action.payload as? CHPopup {
      return state?.upsert(bot: popup.bot) ?? BotsState()
    }
    return state ?? BotsState()
    
  case let action as GetPlugin:
    if var bot = action.bot {
      bot.isDefaultBot = true
      return state?.upsert(bot: bot) ?? BotsState()
    }
    return state ?? BotsState()
    
  case let action as UpdateLoungeInfo:
    if let bot = action.supportBotEntryInfo?.supportBot {
      _ = state?.upsertSupportBot(with: bot)
    }
    
    if let bots = action.userChats.bots {
      _ = state?.upsert(bots: bots)
    }
    
    if let bot = action.bot {
      _ = state?.upsert(bot: bot)
    }
    
    return state ?? BotsState()
    
  case _ as ShutdownSuccess:
    return state?.clear() ?? BotsState()
    
  default:
    return state ?? BotsState()
  }
}
