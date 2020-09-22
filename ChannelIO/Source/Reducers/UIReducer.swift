//
//  UIReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 13..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

func uiReducer(action: ReSwift_Action, state: UIState?) -> UIState {
  var state = state
  switch action {
  case _ as ShowProfile:
    state?.profileIsHidden = false
    return state ?? UIState()
  
  case _ as HideProfile:
    state?.profileIsHidden = true
    return state ?? UIState()
  
  case _ as ChatListIsVisible:
    state?.isChannelVisible = true
    return state ?? UIState()
  
  case _ as ChatListIsHidden:
    state?.isChannelVisible = false
    return state ?? UIState()
  
  default:
    return state ?? UIState()
  }
}

func bootReducer(action: ReSwift_Action, state: BootState?) -> BootState {
  var state = state
  switch action {
  case let action as UpdateBootState:
    state?.status = action.payload
    return state ?? BootState()
  
  case _ as ReadyToShow:
    state?.status = .success
    return state ?? BootState()
    
  case _ as ShutdownSuccess:
    return BootState()
  
  default:
    return state ?? BootState()
  }
}
