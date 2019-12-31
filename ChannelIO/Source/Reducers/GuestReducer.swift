//
//  GuestReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

func guestReducer(action: Action, guest: CHGuest?) -> CHGuest {
  switch action {
  case let action as BootSuccess:
    if let key = action.payload.guestKey as? String {
      PrefStore.setCurrentGuestKey(key)
    }
    if let user = action.payload.user {
      PrefStore.setCurrentUserId(userId: user.id)
      return user
    } else if let veil = action.payload.veil {
      PrefStore.setCurrentVeilId(veilId: veil.id)
      return veil
    }
    return guest ?? CHVeil()
    
  case let action as UpdateGuest:
    if var guest = action.payload, let alert = guest.alert {
      let count = mainStore.state.sessionsState.localSessions
        .reduce(0) { count, session in count + session.alert }
      guest.alert = alert + count
      return guest
    }
    return guest ?? CHVeil()
    
  case let action as CreateLocalUserChat:
    if var guest = guest, let session = action.session, let alert = guest.alert {
      guest.alert = alert + session.alert
      return guest
    }
    return guest ?? CHVeil()
    
  case let action as UpdateGuestWithLocalRead:
    let count = action.session?.alert ?? 0
    if var guest = guest, let alert = guest.alert {
      let adjustCount = alert - count
      guest.alert = adjustCount > 0 ? adjustCount : 0
      return guest
    }
    return guest ?? CHVeil()
    
  case let action as DeleteUserChat:
    if action.payload.isLocal,
      let session = action.payload.session,
      var guest = guest,
      let alert = guest.alert {
      guest.alert = alert - session.alert
      return guest
    }
    return guest ?? CHVeil()
  
  case _ as ShutdownSuccess:
    return CHVeil()
    
  default:
    return guest ?? CHVeil()
  }
}

