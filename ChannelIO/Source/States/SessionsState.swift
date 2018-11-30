//
//  SessionsState.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import ReSwift

struct SessionsState: StateType {
  var sessions: [String:CHSession] = [:]

  var localSessions: [CHSession] {
    return self.sessions
      .filter { $1.id.hasPrefix(CHConstants.local) || $1.chatId.hasPrefix(CHConstants.local) }
      .map { $1 }
  }
  
  func findBy(userChatId: String) -> CHSession? {
    return self.sessions.filter({ $1.chatType == "UserChat" && $1.chatId == userChatId && $1.personType != "Manager" }).first?.value
  }
  
  mutating func remove(session: CHSession?) -> SessionsState {
    guard let session = session else { return self }
    self.sessions.removeValue(forKey: session.id)
    return self
  }
  
  mutating func remove(userChatId: String?) -> SessionsState {
    guard let userChatId = userChatId else { return self }
    var removable: [String] = []
    for (k, v) in self.sessions {
      if v.chatId == userChatId {
        removable.append(k)
      }
    }
    removable.forEach { self.sessions.removeValue(forKey: $0) }
    return self
  }
  
  mutating func remove(userChatIds: [String]) -> SessionsState {
    userChatIds.forEach { _ = self.remove(userChatId: $0) }
    return self
  }
  
  mutating func upsert(session: CHSession?) -> SessionsState {
    guard let session = session else { return self }
    self.sessions[session.id] = session
    return self
  }
  
  mutating func upsert(sessions: [CHSession]) -> SessionsState {
    sessions.forEach({ _ = self.upsert(session: $0) })
    return self
  }
  
  mutating func clear() -> SessionsState {
    self.sessions.removeAll()
    return self
  }
}
