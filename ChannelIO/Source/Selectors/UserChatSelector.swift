//
//  UserChatSelector.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

func userChatsSelector(state: AppState, showCompleted:Bool = false, limit: Int? = nil) -> [CHUserChat] {
  var userChats = state.userChatsState.userChats.values.sorted { (c1, c2) -> Bool in
    if let m1Last = c1.lastMessage, let m2Last = c2.lastMessage {
      return m1Last.createdAt > m2Last.createdAt
    }
    return c1.updatedAt! > c2.updatedAt!
  }.filter { $0.state != .trash && $0.frontMessageId != nil && !$0.hasRemoved }
  
  if let limit = limit, userChats.count > limit {
    userChats = Array(userChats[0..<limit])
  }
  
  if !showCompleted {
    userChats = userChats.filter { (userChat) in
      return !userChat.isClosed
    }
  }
  
  return userChats.compactMap { userChatSelector(state: state, userChatId: $0.id) }
}

func userChatSelector(state: AppState, userChatId: String?) -> CHUserChat? {
  guard let userChat = state.userChatsState.findBy(id: userChatId) else {
    return nil
  }
  
  return CHUserChat(
    id: userChat.id,
    userId: userChat.userId,
    channelId: userChat.channelId,
    state: userChat.state,
    review: userChat.review,
    createdAt: userChat.createdAt,
    openedAt: userChat.openedAt,
    updatedAt: userChat.updatedAt,
    followedAt: userChat.followedAt,
    resolvedAt: userChat.resolvedAt,
    closedAt: userChat.closedAt,
    assigneeId: userChat.assigneeId,
    managerIds: userChat.managerIds,
    handling: userChat.handling,
    frontMessageId: userChat.frontMessageId,
    resolutionTime: userChat.resolutionTime,
    lastMessage: state.messagesState.findBy(id: userChat.frontMessageId),
    session: state.sessionsState.findBy(userChatId: userChat.id),
    channel: state.channel,
    hasRemoved: userChat.hasRemoved
  )
}
