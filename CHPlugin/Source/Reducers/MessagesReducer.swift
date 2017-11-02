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
  case let action as CreateUserChat:
    if var msg = state?.findBy(type: .WelcomeMessage)?.first {
      msg.chatId = action.payload.id
      return state?.replace(message: msg) ?? MessagesState()
    }
    return state ?? MessagesState()
  case let action as GetUserChat:
    let message = action.payload.message
    return state?.insert(message: message) ?? MessagesState()
  case let action as GetMessages:
    var messages = (action.payload["messages"] as? [CHMessage]) ?? []
    let userChatId = messages.first?.chatId ?? ""
    if let userChat = userChatSelector(state: mainStore.state, userChatId: userChatId) {
      messages = LocalMessageFactory.generate(type: .NewAlertMessage,
                                              messages: messages,
                                              userChat: userChat)
    }
    
    return state?.upsert(messages: messages) ?? MessagesState()
  //case let action as FailedGetMessages:
  //  state?.error = action.error
  //  return state ?? MessagesState()
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
    return state?.remove(userChatId: action.payload) ?? MessagesState()
  
  case let action as CreateUserInfoGuide:
    //create message
    let userChat = action.payload["userChat"] as! CHUserChat
    let msg = LocalMessageFactory.generate(
      type: .UserInfoDialog,
      messages: [],
      userChat: userChat
    )
    return state?.insert(message: msg.first!) ?? MessagesState()
  case let action as UpdateUserInfoGuide:
    let dialogType = action.payload
    guard var msg = state?.findBy(type: .UserInfoDialog)?.first else {
      return state ?? MessagesState()
    }
    
    if dialogType == .None {
      return state?.remove(message: msg) ?? MessagesState()
    }
    
    msg.userGuideDialogType = dialogType
    return state?.upsert(messages: [msg]) ?? MessagesState()
  case _ as CompleteUserInfoGuide:
    if var msg = state?.findBy(type: .UserInfoDialog)?.first {
      msg.userGuideDialogType = .Completed
      return state?.upsert(messages: [msg]) ?? MessagesState()
    } else {
      return state ?? MessagesState()
    }
  case _ as CreateChannelClosed:
    let msg = LocalMessageFactory.generate(
      type: .ChannelClosed
    )
    return state?.insert(message: msg.first!) ?? MessagesState()
  case let action as ClickBusinessHour:
    let prvmsgs = state?.findBy(type: .ChannelClosed) ?? []
    if prvmsgs.count == 1 {
      var prv = prvmsgs.first!
      prv.messageType = .UserMessage
      _ = state?.upsert(messages: [prv])
    }
    
    let msg = LocalMessageFactory.generate(
      type: .BusinessHourQuestion,
      messages: [],
      userChat: action.payload
    )
    return state?.insert(message: msg.first!) ?? MessagesState()
  case let action as AnswerBusinessHour:
    let msg = LocalMessageFactory.generate(
      type: .BusinessHourAnswer,
      messages: [],
      userChat: action.payload
    )
    return state?.insert(message: msg.first!) ?? MessagesState()
  case _ as InsertWelcome:
    let msg = LocalMessageFactory.generate(
      type: .WelcomeMessage,
      messages: [],
      userChat: nil
    )
    return state?.upsert(messages: [msg.first!]) ?? MessagesState()
  case _ as CreateFeedback:
    let msg = LocalMessageFactory.generate(type: .SatisfactionFeedback)
    return state?.upsert(messages: msg) ?? MessagesState()
  case _ as CreateCompletedFeedback:
    let msg = LocalMessageFactory.generate(type: .SatisfactionCompleted)
    _ = state?.remove(userChatId: "feedback_dummy")
    return state?.upsert(messages: msg) ?? MessagesState()
  case let action as GetPush:
    guard let msg = action.payload.message else {
      return state ?? MessagesState()
    }
    return state?.upsert(messages: [msg]) ?? MessagesState()
  case _ as CheckOutSuccess:
    return MessagesState()
  default:
    return state ?? MessagesState()
  }
}
