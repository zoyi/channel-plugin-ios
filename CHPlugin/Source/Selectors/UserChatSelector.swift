//
//  UserChatSelector.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 8..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ReSwift

func userChatsSelector(state: AppState, showCompleted:Bool = false) -> [CHUserChat] {
  var userChats = state.userChatsState.userChats.values.sorted { (c1, c2) -> Bool in
    if let m1Last = c1.lastMessage, let m2Last = c2.lastMessage {
      return m1Last.createdAt > m2Last.createdAt
    }
    return c1.updatedAt! > c2.updatedAt!
  }.filter ({ $0.state != "removed" })
  
  if !showCompleted {
    userChats = userChats.filter({ (userChat) in
      return !userChat.isClosed()
    })
  }
  
  return userChats.map({
    return CHUserChat(
      id: $0.id,
      personType: $0.personType,
      personId: $0.personId,
      channelId: $0.channelId,
      bindFromId: $0.bindFromId,
      state: $0.state,
      review: $0.review,
      createdAt: $0.createdAt,
      openedAt: $0.openedAt,
      updatedAt: $0.updatedAt,
      followedAt: $0.followedAt,
      resolvedAt: $0.resolvedAt,
      followedBy: $0.followedBy,
      lastMessageId: $0.lastMessageId,
      talkedManagerIds: $0.talkedManagerIds,
      resolutionTime: $0.resolutionTime,
      lastMessage: state.messagesState.findBy(id: $0.lastMessageId),
      session: state.sessionsState.findBy(userChatId: $0.id),
      managers: state.managersState.findBy(ids: $0.talkedManagerIds),
      channel: state.channel
    )
  })
}

func userChatSelector(state: AppState, userChatId: String?) -> CHUserChat? {
  guard let userChat = state.userChatsState.findBy(id: userChatId) else {
    return nil
  }
  
  return CHUserChat(
    id: userChat.id,
    personType: userChat.personType,
    personId: userChat.personId,
    channelId: userChat.channelId,
    bindFromId: userChat.bindFromId,
    state: userChat.state,
    review: userChat.review,
    createdAt: userChat.createdAt,
    openedAt: userChat.openedAt,
    updatedAt: userChat.updatedAt,
    followedAt: userChat.followedAt,
    resolvedAt: userChat.resolvedAt,
    followedBy: userChat.followedBy,
    lastMessageId: userChat.lastMessageId,
    talkedManagerIds: userChat.talkedManagerIds,
    resolutionTime: userChat.resolutionTime,
    lastMessage: state.messagesState.findBy(id: userChat.lastMessageId),
    session: state.sessionsState.findBy(userChatId: userChat.id),
    managers: state.managersState.findBy(ids: userChat.talkedManagerIds),
    channel: state.channel
  )
}
