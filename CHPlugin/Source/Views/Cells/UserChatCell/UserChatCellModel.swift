//
//  UserChatCellModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

protocol UserChatCellModelType {
  var title: String { get }
  var lastMessage: String? { get }
  var timestamp: String { get }
  var avatars: [CHEntity] { get }
  var badgeCount: Int { get }
  var isBadgeHidden: Bool { get }
  var isClosed: Bool { get }
}

struct UserChatCellModel: UserChatCellModelType {

  let title: String
  let lastMessage: String?
  let timestamp: String
  let avatars: [CHEntity]
  let badgeCount: Int
  let isBadgeHidden: Bool
  let isClosed: Bool
  init(userChat: CHUserChat) {
    self.title = userChat.name
    if userChat.state == "resolved" {
      self.lastMessage = CHAssets.localized("ch.review.require.preview")
    } else if userChat.state == "closed" {
      self.lastMessage = CHAssets.localized("ch.review.complete.preview")
    } else {
      self.lastMessage = userChat.lastMessage?.lastMessage
    }

    self.timestamp = userChat.state == "resolved" ?
      (userChat.resolvedAt?.readableTimestamp() ?? "") :
      userChat.readableUpdatedAt
    self.avatars = userChat.managers
    self.badgeCount = userChat.session?.alert ?? 0
    self.isBadgeHidden = self.badgeCount == 0
    self.isClosed = userChat.isClosed()
  }
  
}
