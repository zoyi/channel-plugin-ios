//
//  LocalMessageFactory.swift
//  CHPlugin
//
//  Created by Haeun Chung on 23/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit

struct LocalMessageFactory {
  static func generate(
    type: MessageType,
    messages: [CHMessage] = [],
    userChat: CHUserChat? = nil,
    text: String? = nil) -> [CHMessage] {
    
    switch type {
    case .DateDivider:
      let msgs = insertDateDividers(messages: messages)
      return msgs
    case .NewAlertMessage:
      let msgs = insertNewMessage(messages: messages, userChat: userChat!)
      return msgs
    case .UserMessage:
      let msg = getUserMessage(msg: text ?? "", userChat: userChat)
      return messages + [msg]
    case .WelcomeMessage:
      if let msg = getWelcomeMessage() {
        return [msg] + messages
      }
      return messages
    default:
      return messages
    }
    
  }
  
  private static func insertDateDividers(messages: [CHMessage]) -> [CHMessage] {
    var indexes: [(Int, String)] = []
    var newMessages = messages
    var lastDateMsg: CHMessage? = nil
    var chatId = ""
    
    for index in (0..<messages.count).reversed() {
      let msg = messages[index]
      if index == messages.count - 1 {
        indexes.append((index, msg.readableDate))
        lastDateMsg = msg
        chatId = msg.chatId
      } else if lastDateMsg?.isSameDate(other: msg) == false {
        indexes.append((index, msg.readableDate))
        lastDateMsg = msg
      }
    }

    for element in indexes {
      let createdAt = messages[element.0].createdAt
      let date = Calendar.current.date(byAdding: .nanosecond, value: -100, to: createdAt)
      
      let msg = CHMessage(
        chatId:chatId,
        message:element.1,
        type: .DateDivider,
        createdAt: date,
        id: element.1)
      newMessages.insert(msg, at: element.0 + 1)
    }
    
    return newMessages
  }
  
  private static func getWelcomeMessage() -> CHMessage? {
    let user = mainStore.state.user
    guard var block = user.getWelcomeBlock() else {
      return nil
    }
    
    block.displayText = user.getWelcome(
      with: CHMessageParserConfig(font: UIFont.systemFont(ofSize: 15))
    )
    
    return CHMessage(
      chatId: "welcome_dummy",
      blocks: [block],
      type: .WelcomeMessage,
      entity: botSelector(state: mainStore.state) ?? mainStore.state.channel,
      id: "welcome_dummy"
    )
  }
  
  //insert new message model into proper position
  private static func insertNewMessage(
    messages: [CHMessage],
    userChat: CHUserChat) -> [CHMessage] {
    guard let session = userChat.session else { return messages }
    guard let lastReadAt = session.readAt else { return messages }
    
    var newMessages = messages
    
    var position = -1
    for (index, message) in messages.enumerated() {
      if Int(message.createdAt.timeIntervalSince1970) <= Int(lastReadAt.timeIntervalSince1970) {
        break
      }
      
      position = index
    }
    
    if position >= 0 {
      let createdAt = messages[position].createdAt
      let date = Calendar.current.date(byAdding: .nanosecond, value: -100, to: createdAt)
      
      let msg = CHMessage(chatId: userChat.id,
        message: CHAssets.localized("ch.unread_divider"),
        type: .NewAlertMessage,
        createdAt: date,
        id: "new_dummy")
      newMessages.insert(msg, at: position)
    }

    return newMessages
  }

  private static func getUserMessage(msg: String, userChat: CHUserChat?) -> CHMessage {
    return CHMessage(chatId:userChat?.id ?? "dummy", message:msg, type: .UserMessage)
  }
}

