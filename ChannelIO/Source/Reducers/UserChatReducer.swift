//
//  UserChatReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

func userChatsReducer(action: ReSwift_Action, state: UserChatsState?) -> UserChatsState {
  var state = state
  switch action {
  case let action as GetUserChats:
    state?.nextSeq = action.payload.next
    return state?.upsert(userChats: action.payload.userChats ?? []) ?? UserChatsState()
  
  case let action as GetUserChat:
    let userChat = action.payload.userChat
    return state?.upsert(userChat: userChat) ?? UserChatsState()
  
  case let action as CreateUserChat:
    return state?.upsert(userChats: [action.payload]) ?? UserChatsState()
  
  case let action as UpdateUserChat:
    return state?.upsert(userChats: [action.payload]) ?? UserChatsState()
    
  case let action as UpdateLoungeInfo:
    state?.nextSeq = action.userChats.next
    return state?.upsert(userChats: action.userChats.userChats ?? []) ?? UserChatsState()
  
  case let action as DeleteUserChat:
    return state?.remove(userChatId: action.payload.id) ?? UserChatsState()
  
  case let action as DeleteUserChats:
    return state?.remove(userChatIds: action.payload.map { $0.id }) ?? UserChatsState()
  
  case _ as DeleteUserChatsAll:
    return state?.clear() ?? UserChatsState()
  
  case let action as JoinedUserChat:
    state?.currentUserChatId = action.payload
    return state ?? UserChatsState()
  
  case let action as LeavedUserChat:
    state?.currentUserChatId = ""
    return state?.remove(userChatId: action.payload) ?? UserChatsState()
  
  case let action as GetPopup:
    if let popup = action.payload as? CHPopup {
      return state?.upsert(userChat: popup.userChat) ?? UserChatsState()
    }
    return state ?? UserChatsState()
  
  case let action as UpdateVisibilityOfCompletedChats:
    if let show = action.show {
      state?.showCompletedChats = show
      PrefStore.setVisibilityOfClosedUserChat(on: show)
    }
    return state ?? UserChatsState()
  
  case let action as UpdateVisibilityOfTranslation:
    if let show = action.show {
      state?.showTranslation = show
      PrefStore.setVisibilityOfTranslation(on: show)
    }
    return state ?? UserChatsState()
  
  case _ as ShutdownSuccess:
    return state?.clear() ?? UserChatsState()
  
  default:
    return state ?? UserChatsState()
  }
}
