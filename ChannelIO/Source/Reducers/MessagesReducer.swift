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
    return state?.upsert(messages: action.payload.messages ?? []) ?? MessagesState()
    
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
    if let entry = action.supportBotEntryInfo,
      let step = entry.step,
      let message = step.message {
      let msg = CHMessage(
        chatId: "support_bot_message_dummy",
        blocks: message.blocks,
        files: message.files,
        webPage: message.webPage,
        type: message.contextType(),
        entity: action.bot,
        buttons: message.buttons,
        action: CHAction.create(botEntry: entry),
        createdAt: Date(),
        id: "support_bot_message_dummy")
        state?.supportBotEntry = msg
      } else {
        state?.supportBotEntry = nil
      }
    
    if let messages = action.userChats.messages {
      _ = state?.upsert(messages: messages)
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
    
  case let action as GetPopup:
    if let popup = action.payload as? CHPopup {
      return state?.insert(message: popup.message) ?? MessagesState()
    }
    return state ?? MessagesState()
    
  case _ as InsertSupportBotEntry:
    let message = state?.supportBotEntry
    return state?.insert(message: message) ?? MessagesState()
    
  case _ as ShutdownSuccess:
    return state?.clear() ?? MessagesState()
    
  default:
    return state ?? MessagesState()
  }
}
