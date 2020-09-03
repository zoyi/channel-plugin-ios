//
//  PushReducer.swift
//  CHPlugin
//
//  Created by Haeun Chung on 13/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

func pushReducer(action:Action, popup: CHPopupDisplayable?) -> CHPopupDisplayable? {
  switch action {
  case let action as GetPopup:
    //return push only if messenger is not visible
    return action.payload
    
  case _ as RemovePopup:
    return nil
    
  case _ as ShutdownSuccess:
    return nil
    
  default:
    return popup ?? nil
  }
}
