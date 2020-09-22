//
//  MarketingHook.swift
//  ChannelIO
//
//  Created by intoxicated on 17/02/2020.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import RxSwift

func marketingStatHook() -> Middleware {
  return { marketingStat(action: $0, context: $1) }
}

func marketingStat(action: ReSwift_Action, context: MiddlewareContext<AppState>) -> ReSwift_Action? {
  if let action = action as? ViewMarketing {
    AppManager.shared.sendViewMarketing(type: action.type, id: action.id)
  } else if let action = action as? ClickMarketing {
    AppManager.shared.sendClickMarketing(
      type: action.type,
      id: action.id,
      userId: PrefStore.getCurrentUserId()
    )
  }
  return action
}
