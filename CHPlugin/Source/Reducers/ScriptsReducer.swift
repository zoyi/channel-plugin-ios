//
//  ScriptsReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 23..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

func scriptsReducer(action: Action, state: ScriptsState?) -> ScriptsState {
  var state = state
  switch action {
  case let action as GetScript:
    if let script = action.payload {
      return state?.upsert(scripts: [script]) ?? ScriptsState()
    }
    return state ?? ScriptsState()
  case let action as GetScripts:
    return state?.upsert(scripts: action.payload) ?? ScriptsState()
  default:
    return state ?? ScriptsState()
  }
}
