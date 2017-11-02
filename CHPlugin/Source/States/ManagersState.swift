//
//  ManagerState.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

struct ManagersState: StateType {
  var managerDictionary: [String: CHManager] = [:]

  func findBy(id: String) -> CHManager? {
    return self.managerDictionary[id]
  }

  func findBy(ids: [String]) -> [CHManager] {
    return self.managerDictionary.filter({ ids.index(of: $0.key) != nil }).map({ $1 })
  }
  
  mutating func upsert(managers: [CHManager]) -> ManagersState {
    managers.forEach({ self.managerDictionary[$0.id] = $0 })
    return self
  }
  
  mutating func remove(managerId: String) -> ManagersState {
    self.managerDictionary.removeValue(forKey: managerId)
    return self
  }
  
}
