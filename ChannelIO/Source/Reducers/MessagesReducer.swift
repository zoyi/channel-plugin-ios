//
//  MessagesReducer.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

func messagesReducer(action: Action, state: MessagesState?) -> MessagesState {
  var state = state
  switch action {
  case let action as GetUserChats:
    let messages = (action.payload["messages"] as? [CHMessage]) ?? []
    return state?.upsert(messages: messages) ?? MessagesState()
    
  case let action as GetUserChat:
    let message = action.payload.message
    _ = state?.removeLocalMessages()
  
    return state?.insert(message: message) ?? MessagesState()
    //insert only if local dummy is not exist
    //if state?.findBy(id: "welcome_dummy") == nil {
//    if let message = message {
//      return state?.upsert(messages: [message]) ?? MessagesState()
//    }
//
//    return state ?? MessagesState()
  case let action as GetNudgeChat:
    let message = action.payload.message
    _ = state?.removeLocalMessages()
    return state?.insert(message: message) ?? MessagesState()
    
  case let action as GetMessages:
    var messages = (action.payload["messages"] as? [CHMessage]) ?? []
    let userChatId = messages.first?.chatId ?? ""
    if let userChat = userChatSelector(state: mainStore.state, userChatId: userChatId) {
      messages = LocalMessageFactory.generate(
        type: .NewAlertMessage,
        messages: messages,
        userChat: userChat)
    }
    return state?.upsert(messages: messages) ?? MessagesState()
    
  case let action as RemoveMessages:
    let userChatId = action.payload ?? ""
    _ = state?.removeLocalMessages()
      return state?.remove(userChatId: userChatId) ?? MessagesState()
    
  case let action as CreateMessage:
    return state?.replace(message: action.payload) ?? MessagesState()
    
  case let action as DeleteMessage:
    return state?.remove(message: action.payload) ?? MessagesState()
    
  case let action as UpdateMessage:
    return state?.upsert(messages: [action.payload]) ?? MessagesState()
    
  case let action as DeleteUserChat:
    return state?.remove(userChatId: action.payload.id) ?? MessagesState()
  
  case _ as InsertWelcome:
    let msg = LocalMessageFactory.generate(
      type: .WelcomeMessage,
      messages: [],
      userChat: nil
    )
    return state?.upsert(messages: [msg.first!]) ?? MessagesState()
    
  case let action as GetPush:
    return state?.insert(message: action.payload.message) ?? MessagesState()
    
  case let action as GetSupportBotEntry:
    if let step = action.entry.step {
      let message = CHMessage(
        chatId: "support_bot_message_dummy",
        message: step.message,
        type: .Form,
        entity: action.bot,
        form: CHForm.create(botEntry: action.entry),
        file: CHFile.create(imageable: step),
        createdAt: Date(),
        id: "support_bot_message_dummy")
      state?.supportBotEntry = message
    }
    return state ?? MessagesState()
    
  case _ as InsertSupportBotEntry:
    let message = state?.supportBotEntry
    return state?.insert(message: message) ?? MessagesState()
    
  case let action as CreateLocalUserChat:
    if let message = action.message {
      return state?.upsert(messages: [message]) ?? MessagesState()
    }
    return state ?? MessagesState()
    
  case _ as CheckOutSuccess:
    return state?.clear() ?? MessagesState()
    
  default:
    return state ?? MessagesState()
  }
}
