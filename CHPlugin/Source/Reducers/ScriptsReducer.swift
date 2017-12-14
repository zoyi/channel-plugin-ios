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
    return state?.upsert(scripts: [action.payload]) ?? ScriptsState()
  case let action as GetScripts:
    return state?.upsert(scripts: action.payload) ?? ScriptsState()
  default:
    return state ?? ScriptsState()
  }
}
