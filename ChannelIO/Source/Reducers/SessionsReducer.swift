//
//  SessionsReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

func sessionsReducer(action: ReSwift_Action, state: SessionsState?) -> SessionsState {
  var state = state
  switch action {
  case let action as GetUserChats:
    return state?.upsert(sessions: action.payload.sessions ?? []) ?? SessionsState()
    
  case let action as GetUserChat:
    return state?.upsert(session: action.payload.session) ?? SessionsState()
  
  case let action as CreateSession:
    return state?.upsert(session: action.payload) ?? SessionsState()
  
  case let action as UpdateSession:
    return state?.upsert(session: action.payload) ?? SessionsState()
  
  case let action as DeleteSession:
    return state?.remove(session: action.payload) ?? SessionsState()
  
  case let action as ReadSession:
    var session = action.payload
    session?.alert = 0
    session?.unread = 0
    return state?.upsert(session: session) ?? SessionsState()
    
  case let action as UpdateLoungeInfo:
    return state?.upsert(sessions: action.userChats.sessions ?? []) ?? SessionsState()

  case let action as DeleteUserChats:
    return state?.remove(userChatIds: action.payload.map { $0.id }) ?? SessionsState()
    
  case _ as ShutdownSuccess:
    return state?.clear() ?? SessionsState()
  
  default:
    return state ?? SessionsState()
  }
}
