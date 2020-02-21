//
//  UserReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

func userReducer(action: Action, user: CHUser?) -> CHUser {
  switch action {
  case let action as BootSuccess:
    if let jwt = action.payload.sessionJWT {
      PrefStore.setSessionJWT(jwt)
    }
    if let veilId = action.payload.veilId {
      PrefStore.setVeilId(veilId)
    }
    if let user = action.payload.user {
      PrefStore.setCurrentUserId(user.id)
      return user
    }
    return user ?? CHUser()
    
  case let action as GetTouchSuccess:
    if let jwt = action.payload.sessionJWT {
      PrefStore.setSessionJWT(jwt)
    }
    if let veilId = action.payload.veilId {
      PrefStore.setVeilId(veilId)
    }
    if let user = action.payload.user {
      PrefStore.setCurrentUserId(user.id)
      return user
    }
    return user ?? CHUser()
    
  case let action as UpdateUser:
    if var user = action.payload, let alert = user.alert {
      user.alert = alert
      return user
    }
    return user ?? CHUser()
  
  case _ as ShutdownSuccess:
    return CHUser()
    
  default:
    return user ?? CHUser()
  }
}

