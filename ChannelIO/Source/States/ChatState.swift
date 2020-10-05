//
//  ChatState.swift
//  ChannelIO
//
//  Created by Jam on 12/11/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

struct ChatState: ReSwift_StateType {
  var userChat: CHUserChat?
  var messageDictionary: [String:CHMessage] = [:]
  var actionQueue: [String:CHMessage] = [:]
  var botDictionary: [String: CHBot] = [:]
  var lastMessage: String = ""
  var sessions: [String:CHSession] = [:]
  var managerDictionary: [String: CHManager] = [:]
  
  mutating func clear() -> ChatState {
    userChat = nil
    messageDictionary = [:]
    actionQueue = [:]
    botDictionary = [:]
    lastMessage = ""
    sessions = [:]
    managerDictionary = [:]
    return self
  }
  
  mutating func replace(message: CHMessage?) -> ChatState {
    guard let message = message else { return self }
    
    if message.requestId != nil {
      self.messageDictionary[message.requestId!] = nil
    }
    
//    for (key, message) in self.actionQueue {
//      var updated = message
//      updated.messageType = message.contextType()
//      self.messageDictionary[key] = updated
//    }
    
    self.messageDictionary[message.id] = message
    if message.action != nil {
      self.actionQueue[message.id] = message
    }
    
    return self
  }
  
  mutating func replace(userChat: CHUserChat?) -> ChatState {
    guard let userChat = userChat else { return self }
    self.userChat = userChat
    if let lastId = userChat.frontMessageId {
      self.lastMessage = lastId
    }
    
    return self
  }
  
  mutating func upsert(messages: [CHMessage]) -> ChatState {
    for message in messages {
      _ = self.insert(message: message)
    }
    return self
  }
  
  mutating func upsert(bots: [CHBot]) -> ChatState {
    bots.forEach { _ = self.upsert(bot: $0) }
    return self
  }
  
  mutating func upsert(bot: CHBot?) -> ChatState {
    guard let bot = bot else { return self }
    self.botDictionary[bot.id] = bot
    return self
  }
  
  mutating func upsert(userChat: CHUserChat?) -> ChatState {
    guard let userChat = userChat else { return self }
    self.userChat = userChat
    if let lastId = userChat.frontMessageId {
      self.lastMessage = lastId
    }
    
    return self
  }
  
  mutating func upsert(manager: CHManager?) -> ChatState {
    guard let manager = manager else { return self }
    self.managerDictionary[manager.id] = manager
    return self
  }
  
  mutating func upsert(managers: [CHManager]) -> ChatState {
    managers.forEach { _ = self.upsert(manager: $0) }
    return self
  }
  
  mutating func upsert(session: CHSession?) -> ChatState {
    guard let session = session else { return self }
    self.sessions[session.id] = session
    return self
  }
  
  mutating func upsert(sessions: [CHSession]) -> ChatState {
    sessions.forEach { _ = self.upsert(session: $0) }
    return self
  }
  
  mutating func insert(message: CHMessage?) -> ChatState {
    guard let message = message else { return self }
    if message.requestId != nil {
      self.messageDictionary[message.requestId!] = nil
    }
    
    self.messageDictionary[message.id] = message
    
    if message.action != nil {
      self.actionQueue[message.id] = message
    }
    return self
  }
  
  mutating func remove(message: CHMessage) -> ChatState {
    self.messageDictionary.removeValue(forKey: message.id)
    return self
  }
  
  mutating func remove(session: CHSession?) -> ChatState {
    guard let session = session else { return self }
    self.sessions.removeValue(forKey: session.id)
    return self
  }
  
  mutating func remove(userChatId: String) -> ChatState {
    guard userChatId != "" else { return self }
    let lastIds = mainStore.state.userChatsState.lastMessages
    
    self.messageDictionary.forEach { (k, v) in
      if (v.chatId == userChatId && lastIds[v.id] == nil) &&
        v.state != .networkError {
        self.messageDictionary.removeValue(forKey: k)
      }
    }
    return self
  }
  
  mutating func removeLocalMessages() -> ChatState {
    for (k,v) in self.messageDictionary {
      if v.chatId.contains("dummy") || v.id.contains("dummy") {
        self.messageDictionary.removeValue(forKey: k)
      }
    }
    self.actionQueue = [:]
    return self
  }
}
