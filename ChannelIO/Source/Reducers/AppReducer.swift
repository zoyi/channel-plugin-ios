//
//  AppReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

func appReducer(action: ReSwift_Action, state: AppState?) -> AppState {
  return AppState(
    bootState: bootReducer(action: action, state: state?.bootState),
    plugin: pluginReducer(action: action, plugin: state?.plugin),
    channel: channelReducer(action: action, channel: state?.channel),
    user: userReducer(action: action, user: state?.user),
    userChatsState: userChatsReducer(action: action, state: state?.userChatsState),
    popup: pushReducer(action: action, popup: state?.popup),
    managersState: managersReducer(action: action, state: state?.managersState),
    botsState: botsReducer(action: action, state: state?.botsState),
    sessionsState: sessionsReducer(action: action, state: state?.sessionsState),
    messagesState: messagesReducer(action: action, state: state?.messagesState),
    uiState: uiReducer(action: action, state: state?.uiState),
    socketState: socketReducer(action: action, state: state?.socketState),
    countryCodeState: countryCodeReducer(action: action, state: state?.countryCodeState),
    chatState: ChatReducer(action: action, state: state?.chatState)
  )
}
