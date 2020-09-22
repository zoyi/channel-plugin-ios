//
//  ShowCompletedChatsSelector.swift
//  ChannelIO
//
//  Created by Jam on 17/09/2019.
//

import Foundation

func showCompletedChatsSelector(state: AppState) -> Bool {
  return state.userChatsState.showCompletedChats
}
