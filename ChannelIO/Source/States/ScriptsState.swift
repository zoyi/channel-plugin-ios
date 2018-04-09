//
//  ScriptsState.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 23..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

struct ScriptsState: StateType {
  var scripts: [String:CHScript] = [:]

  func getWelcomeMessage(guest: CHGuest) -> String {
    if !guest.ghost {
      let defaultMessage = CHAssets.localized("ch.scripts.welcome_user.default")
      let msg = self.findBy(key: "welcome")?.getTranslatedMessage() ?? defaultMessage
      return msg.replace("${name}", withString: guest.name)
    } else {
      let defaultMessage = CHAssets.localized("ch.scripts.welcome_veil.default")
      return self.findBy(key: "welcome_ghost")?.getTranslatedMessage() ?? defaultMessage
    }
  }

  func getOutOfWorkMessage() -> String {
    let defaultMessage = CHAssets.localized("ch.scripts.out_of_work.default")
    return self.findBy(key: "out_of_work")?.getTranslatedMessage() ?? defaultMessage
  }

  private func findBy(key: String) -> CHScript? {
    return self.scripts.filter({ $1.key == key }).first?.value
  }

  mutating func upsert(scripts: [CHScript]) -> ScriptsState {
    scripts.forEach({ self.scripts[$0.id] = $0 })
    return self
  }
}
