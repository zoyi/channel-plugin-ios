//
//  PluginReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

func pluginReducer(action: Action, plugin: CHPlugin?) -> CHPlugin {
  switch action {
  case let action as GetPlugin:
    PrefStore.setCurrentPluginId(pluginId: action.plugin.id)
    return action.plugin
    
  case let action as GetTouchSuccess:
    let plugin = action.payload.plugin ?? CHPlugin()
    PrefStore.setCurrentPluginId(pluginId: plugin.id)
    return plugin

  case let action as BootSuccess:
    let plugin = action.payload.plugin ?? CHPlugin()
    PrefStore.setCurrentPluginId(pluginId: plugin.id)
    return plugin
    
  case let action as UpdateLoungeInfo:
    PrefStore.setCurrentPluginId(pluginId: action.plugin.id)
    return action.plugin
    
  case let action as ShutdownSuccess:
    if !action.isSleeping {
      PrefStore.clearCurrentPluginId()
    }
    return CHPlugin()
    
    
  default:
    return plugin ?? CHPlugin()
  }
}
