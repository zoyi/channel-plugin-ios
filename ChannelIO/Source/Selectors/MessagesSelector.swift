//
//  MessagesSelector.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ReSwift

func messagesSelector(state: AppState, userChatId: String?) -> [CHMessage] {
  let messages: [CHMessage] = state.messagesState
    .findBy(userChatId: userChatId)
    .map({
      return CHMessage(
        id: $0.id,
        chatType: $0.chatType,
        chatId: $0.chatId,
        personType: $0.personType,
        personId: $0.personId,
        message: $0.message,
        messageV2: $0.messageV2,
        requestId: $0.requestId,
        botOption: $0.botOption,
        profileBot: $0.profileBot,
        form: $0.form,
        createdAt: $0.createdAt,
        file: $0.file,
        webPage: $0.webPage,
        log: $0.log,
        entity: personSelector(state: state, personType: $0.personType, personId: $0.personId),
        state: $0.state,
        messageType: $0.messageType,
        progress: $0.progress
      )
    }).sorted(by: { (m1, m2) -> Bool in
      return m1.createdAt > m2.createdAt
    })

  return LocalMessageFactory.generate(
    type: .DateDivider,
    messages: messages,
    userChat: nil)
}

func messageSelector(state: AppState, id: String) -> CHMessage? {
  let message: CHMessage! = state.messagesState
    .findBy(id: id)
    .map({
      return CHMessage(
        id: $0.id,
        chatType: $0.chatType,
        chatId: $0.chatId,
        personType: $0.personType,
        personId: $0.personId,
        message: $0.message,
        messageV2: $0.messageV2,
        requestId: $0.requestId,
        botOption: $0.botOption,
        profileBot: $0.profileBot,
        form: $0.form,
        createdAt: $0.createdAt,
        file: $0.file,
        webPage: $0.webPage,
        log: $0.log,
        entity: personSelector(state: state, personType: $0.personType, personId: $0.personId),
        state: $0.state,
        messageType: $0.messageType,
        progress: $0.progress
      )
    })
  
  return message
}
