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
  case let action as CheckInSuccess:
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
      let count = mainStore.state.sessionsState.localSessions
        .reduce(0) { count, session in count + session.alert }
      user.alert = alert + count
      return user
    }
    return user ?? CHUser()
    
  case let action as CreateLocalUserChat:
    if var user = user, let session = action.session, let alert = user.alert {
      user.alert = alert + session.alert
      return user
    }
    return user ?? CHUser()
    
  case let action as UpdateUserWithLocalRead:
    let count = action.session?.alert ?? 0
    if var user = user, let alert = user.alert {
      let adjustCount = alert - count
      user.alert = adjustCount > 0 ? adjustCount : 0
      return user
    }
    return user ?? CHUser()
    
  case let action as DeleteUserChat:
    if let session = action.payload.session,
      var user = user, let alert = user.alert {
      let adjustcount = alert - session.alert
      user.alert = adjustcount
      return user
    }
    return user ?? CHUser()
  
  case _ as CheckOutSuccess:
    return CHUser()
    
  default:
    return user ?? CHUser()
  }
}

