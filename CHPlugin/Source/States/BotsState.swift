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
  
  func findBy(id: String?) -> CHBot? {
    guard let id = id else { return nil }
    return self.botDictionary[id]
  }
  
  func findBy(ids: [String]) -> [CHBot] {
    return self.botDictionary.filter({ ids.index(of: $0.key) != nil }).map({ $1 })
  }
  
  mutating func upsert(bots: [CHBot]) -> BotsState {
    bots.forEach({ self.botDictionary[$0.id] = $0 })
    return self
  }
}
