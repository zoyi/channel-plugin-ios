//
//  PersonSelector.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ReSwift

func personSelector(state: AppState, personType: PersonType?, personId: String?) -> CHEntity? {
  guard let personType = personType, let personId = personId else { return nil }
  
  switch personType {
  case .manager:
    return state.managersState.findBy(id: personId)
  case .user:
    return state.user
  case .bot:
    return state.botsState.findBy(id: personId)
  }
}

func userSelector(state: AppState) -> CHUser {
  return state.user
}

func defaultBotSelector(state: AppState) -> CHBot? {
  return state.botsState.findBy(name: state.plugin.botName).map({ (bot) in
    return CHBot(
      id: bot.id,
      channelId: bot.channelId,
      name: bot.name,
      avatarUrl: bot.avatarUrl,
      initial: bot.initial,
      color: bot.color,
      createdAt: bot.createdAt,
      isDefaultBot: bot.isDefaultBot
    )
  })
}

func botSelector(state: AppState, botName: String?) -> CHBot? {
  return state.botsState.findBy(name: botName).map({ (bot) in
    return CHBot(
      id: bot.id,
      channelId: bot.channelId,
      name: bot.name,
      avatarUrl: bot.avatarUrl,
      initial: bot.initial,
      color: bot.color,
      createdAt: bot.createdAt,
      isDefaultBot: bot.isDefaultBot
    )
  })
}

func botSelector(state: AppState, botId: String?) -> CHBot? {
  return state.botsState.findBy(id: botId).map({ (bot) in
    return CHBot(
      id: bot.id,
      channelId: bot.channelId,
      name: bot.name,
      avatarUrl: bot.avatarUrl,
      initial: bot.initial,
      color: bot.color,
      createdAt: bot.createdAt,
      isDefaultBot: bot.isDefaultBot
    )
  })
}

func botSelector(state: AppState) -> CHBot? {
  return state.botsState.getDefaultBot()
}
