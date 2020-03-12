//
//  BotsState.swift
//  CHPlugin
//
//  Created by Haeun Chung on 05/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

struct BotsState: StateType {
  var botDictionary: [String: CHBot] = [:]
  var supportBots: [CHSupportBot] = []
  
  func getDefaultBot() -> CHBot? {
    return self.findBy(name: mainStore.state.plugin.botName)
  }
  
  func findBy(name: String?) -> CHBot? {
    guard let name = name else { return nil }
    return self.botDictionary.filter({ (key, bot) in
      return bot.name == name
    }).map({ $1 }).first
  }
  
  func findBy(id: String?) -> CHBot? {
    guard let id = id else { return nil }
    return self.botDictionary[id]
  }
  
  func findBy(ids: [String]) -> [CHBot] {
    return self.botDictionary.filter({ ids.firstIndex(of: $0.key) != nil }).map({ $1 })
  }
  
  func findDefaultBot() -> CHBot? {
    return self.botDictionary.filter { $1.isDefaultBot }.map { $1 }.first
  }
  
  func findSupportBot() -> CHSupportBot? {
    return self.supportBots.first
  }
  
  mutating func upsert(bots: [CHBot]) -> BotsState {
    bots.forEach({ _ = self.upsert(bot: $0) })
    return self
  }
  
  mutating func upsert(bot: CHBot?) -> BotsState {
    guard let bot = bot else { return self }
    self.botDictionary[bot.id] = bot
    return self
  }
  
  mutating func upsertSupportBots(bots: [CHSupportBot]) -> BotsState {
    bots.forEach { (bot) in
      if let index = self.supportBots.firstIndex(where: { $0.id == bot.id }) {
        self.supportBots[index] = bot
      } else {
        self.supportBots.insert(bot, at: 0)
      }
    }
    return self
  }
  
  mutating func clear() -> BotsState {
    self.botDictionary.removeAll()
    self.supportBots.removeAll()
    return self
  }
}
