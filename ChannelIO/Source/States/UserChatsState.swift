//
//  UserChatsState.swift
//  CHPlugin
//
//  Created by Haeun Chung on 22/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import ReSwift

struct UserChatsState: StateType {
  var userChats: [String:CHUserChat] = [:]
  var nextSeq: Int64 = 0
  var currentUserChatId = ""
  var lastMessages: [String:String] = [:]
  var showCompletedChats = PrefStore.getVisibilityOfClosedUserChat()
  var showTranslation = PrefStore.getVisibilityOfTranslation()
  
  func findBy(id: String?) -> CHUserChat? {
    guard id != nil else { return nil }
    return self.userChats[id!]
  }
  
  func findBy(ids: [String]) -> [CHUserChat] {
    return self.userChats.filter({ ids.firstIndex(of: $0.key) != nil }).map({ $1 })
  }
  
  mutating func remove(userChatId: String) -> UserChatsState {
    var userChat = self.userChats[userChatId]
    userChat?.hasRemoved = true
    self.userChats[userChatId] = userChat
    return self
  }
  
  mutating func remove(userChatIds: [String]) -> UserChatsState {
    for userChatId in userChatIds {
      _ = self.remove(userChatId: userChatId)
    }
    
    return self
  }
  
  mutating func clear() -> UserChatsState {
    self.userChats.removeAll()
    self.nextSeq = 0
    self.currentUserChatId = ""
    self.lastMessages.removeAll()
    return self
  }
  
  mutating func replace(chatId: String, userChat: CHUserChat?) -> UserChatsState {
    guard let userChat = userChat else { return self }
    self.userChats.removeValue(forKey: chatId)
    self.userChats[userChat.id] = userChat
    if let lastId = userChat.appMessageId {
      self.lastMessages[lastId] = lastId
    }
    
    return self
  }
  
  mutating func upsert(userChat: CHUserChat?) -> UserChatsState {
    guard let userChat = userChat else { return self }
    self.userChats[userChat.id] = userChat
    if let lastId = userChat.appMessageId {
      self.lastMessages[lastId] = lastId
    }
    
    return self
  }
  
  mutating func upsert(userChats: [CHUserChat]) -> UserChatsState {
    for userChat in userChats {
      _ = self.upsert(userChat: userChat)
    }
    
    return self
  }
}
