//
//  ChatReducer.swift
//  ChannelIO
//
//  Created by Jam on 12/11/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import ReSwift

func ChatReducer(action: Action, state: ChatState?) -> ChatState {
  var state = state
  switch action {
  case _ as ClearChat:
    return state?.clear() ?? ChatState()
    
  case let action as CreateMessage:
    return state?.replace(message: action.payload) ?? ChatState()
    
  case let action as UpdateMessage:
    return state?.upsert(messages: [action.payload]) ?? ChatState()
    
  case let action as GetMessages:
    var messages = (action.payload["messages"] as? [CHMessage]) ?? []
    let userChatId = messages.first?.chatId ?? ""
    if let userChat = userChatSelector(state: mainStore.state, userChatId: userChatId) {
      messages = LocalMessageFactory.generate(
        type: .NewAlertMessage,
        messages: messages,
        userChat: userChat
      )
    }
    let bots = (action.payload["bots"] as? [CHBot]) ?? []
    _ = state?.upsert(messages: messages)
    return state?.upsert(bots: bots) ?? ChatState()
    
  case let action as DeleteMessage:
    return state?.remove(message: action.payload) ?? ChatState()
    
  case let action as RemoveMessages:
    let userChatId = action.payload ?? ""
    _ = state?.removeLocalMessages()
    return state?.remove(userChatId: userChatId) ?? ChatState()
    
  case let action as CreateUserChat:
    return state?.upsert(userChat: action.payload) ?? ChatState()
    
  case let action as UpdateUserChat:
    return state?.upsert(userChat: action.payload) ?? ChatState()
    
  case let action as GetUserChat:
    let managers = action.payload.managers ?? []
    _ = state?.upsert(managers: managers)
    let message = action.payload.message
    _ = state?.removeLocalMessages()
    _ = state?.insert(message: message)
    _ = state?.upsert(session: action.payload.session)
    let userChat = action.payload.userChat
    return state?.upsert(userChat: userChat) ?? ChatState()
    
  case let action as UpdateSession:
    return state?.upsert(session: action.payload) ?? ChatState()
    
  case let action as DeleteSession:
    return state?.remove(session: action.payload) ?? ChatState()
    
  case let action as UpdateManager:
    return state?.upsert(managers: [action.payload]) ?? ChatState()
    
  case let action as GetPlugin:
    if var bot = action.bot {
      bot.isDefaultBot = true
        return state?.upsert(bot: bot) ?? ChatState()
    }
    return state ?? ChatState()
    
  case let action as ReadSession:
    var session = action.payload
    session?.alert = 0
    session?.unread = 0
    return state?.upsert(session: session) ?? ChatState()
    
  case _ as InsertWelcome:
    let msg = LocalMessageFactory.generate(
      type: .WelcomeMessage,
      messages: [],
      userChat: nil
    )
    if let message = msg.first {
      return state?.upsert(messages: [message]) ?? ChatState()
    }
    return state?.upsert(messages: []) ?? ChatState()
    
  default:
     return state ?? ChatState()
  }
}
