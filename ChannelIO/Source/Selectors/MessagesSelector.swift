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
  guard let userChatId = userChatId else { return [] }
  
  let messages: [CHMessage] = state.messagesState
    .findBy(userChatId: userChatId)
    .compactMap { messageSelector(state: state, id: $0.id) }
    .sorted { $0.createdAt > $1.createdAt }

  return LocalMessageFactory.generate(
    type: .DateDivider,
    messages: messages,
    userChat: nil)
}

func messageSelector(state: AppState, id: String?) -> CHMessage? {
  guard let id = id else { return nil }
  
  return state.messagesState
    .findBy(id: id)
    .map({
      return CHMessage(
        id: $0.id,
        channelId: $0.channelId,
        chatType: $0.chatType,
        chatId: $0.chatId,
        personType: $0.personType,
        personId: $0.personId,
        title: $0.title,
        message: $0.message,
        messageV2: $0.messageV2,
        requestId: $0.requestId,
        profileBot: $0.profileBot,
        action: $0.action,
        buttons: $0.buttons,
        submit: $0.submit,
        createdAt: $0.createdAt,
        language: $0.language,
        files: $0.files,
        webPage: $0.webPage,
        log: $0.log,
        entity: personSelector(state: state, personType: $0.personType, personId: $0.personId),
        mutable: $0.mutable,
        state: $0.state,
        messageType: $0.messageType,
        progress: $0.progress,
        onlyEmoji: $0.onlyEmoji,
        sortedFiles: $0.sortedFiles,
        translateState: $0.translateState,
        translatedText: $0.translatedText
      )
    })
}

func messageSelector(state: AppState, type: MessageType) -> CHMessage? {
  return state.messagesState.findBy(type: type)?.first.map({
    return CHMessage(
      id: $0.id,
      channelId: $0.channelId,
      chatType: $0.chatType,
      chatId: $0.chatId,
      personType: $0.personType,
      personId: $0.personId,
      title: $0.title,
      message: $0.message,
      messageV2: $0.messageV2,
      requestId: $0.requestId,
      profileBot: $0.profileBot,
      action: $0.action,
      buttons: $0.buttons,
      submit: $0.submit,
      createdAt: $0.createdAt,
      language: $0.language,
      files: $0.files,
      webPage: $0.webPage,
      log: $0.log,
      entity: personSelector(state: state, personType: $0.personType, personId: $0.personId),
      mutable: $0.mutable,
      state: $0.state,
      messageType: $0.messageType,
      progress: $0.progress,
      onlyEmoji: $0.onlyEmoji,
      sortedFiles: $0.sortedFiles,
      translateState: $0.translateState,
      translatedText: $0.translatedText
    )
  })
}

func supportBotEntrySelector(state: AppState) -> CHMessage? {
  return state.messagesState.supportBotEntry
}
