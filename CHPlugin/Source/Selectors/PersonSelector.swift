//
//  PersonSelector.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ReSwift

func personSelector(state: AppState, personType: String, personId: String) -> CHEntity? {
  if personType == "Manager" {
    return state.managersState.findBy(id: personId)
  } else if personType == "User" || personType == "Veil" {
    return state.guest
  }
  return state.channel
}
