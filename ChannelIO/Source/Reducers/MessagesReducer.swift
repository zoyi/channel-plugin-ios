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
    
  case let action as UpdateLoungeInfo:
    let lastMessages = action.userChatsResponse?.messages ?? []
    lastMessages.forEach {
      _ = state?.insert(message: $0) ?? MessagesState()
    }
    
    if let entry = action.supportBotEntryInfo,
      let step = entry.step,
      let message = step.message {
      let msg = CHMessage(
        chatId: "support_bot_message_dummy",
        blocks: message.blocks,
        type: message.contextType(),
        entity: action.bot,
        action: CHAction.create(botEntry: entry),
        createdAt: Date(),
        id: "support_bot_message_dummy")
        state?.supportBotEntry = msg
      } else {
        state?.supportBotEntry = nil
      }
    
    return state ?? MessagesState()
    
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
