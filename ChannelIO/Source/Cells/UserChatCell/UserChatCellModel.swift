//
//  UserChatCellModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

protocol UserChatCellModelType {
  var chatId: String? { get set }
  var title: String { get set }
  var lastMessage: String? { get set }
  var timestamp: String { get set }
  var avatar: CHEntity? { get set }
  var badgeCount: Int { get set }
  var isBadgeHidden: Bool { get set }
  var isClosed: Bool { get set }
  var files: [CHFile] { get set }
}

struct UserChatCellModel: UserChatCellModelType {
  var chatId: String?
  var title: String = ""
  var lastMessage: String?

  var timestamp: String = ""
  var avatar: CHEntity?
  var badgeCount: Int = 0
  var isBadgeHidden: Bool = false
  var isClosed: Bool = false
  var files: [CHFile] = []
  
  init() {}
  
  init(userChat: CHUserChat) {
    self.chatId = userChat.id
    
    if userChat.lastMessage?.removed == true {
      self.lastMessage = MessageFactory.deleted().string
    } else if userChat.state == .closed && userChat.review != "" {
      self.lastMessage = CHAssets.localized("ch.review.complete.preview")
    } else if let logMessage = userChat.lastMessage?.logMessage {
      self.lastMessage = logMessage
    } else if let msg = userChat.lastMessage?.attributedText?.string {
      self.lastMessage = msg
    } else if let plainText = userChat.lastMessage?.plainText {
      self.lastMessage = plainText
    } else if let buttons = userChat.lastMessage?.buttons, buttons.count != 0 {
      self.lastMessage = buttons.reduce(into: "") {
        $0 += $0 == "" ? "[\($1.title)]" : ", [\($1.title)]"
      }
    } else if let displayText = userChat.lastMessage?.action?.displayText {
      self.lastMessage = displayText
    } else if let url = userChat.lastMessage?.webPage?.url?.absoluteString {
      self.lastMessage = url
    }
    
    if let files = userChat.lastMessage?.sortedFiles {
      self.files = files
    }
    
    var avatar: CHEntity?
    if let writer = personSelector(
      state: mainStore.state,
      personType: userChat.lastMessage?.personType,
      personId: userChat.lastMessage?.personId),
      writer is CHBot {
      avatar = writer
    } else if let defaultBot = defaultBotSelector(state: mainStore.state) {
      avatar = defaultBot
    } else {
      avatar = mainStore.state.channel
    }
    
    let title = avatar?.name ?? CHAssets.localized("ch.unknown")
    
    self.title = userChat.assignee?.name ?? title
    self.timestamp = userChat.readableUpdatedAt
    self.avatar = userChat.assignee ?? avatar
    self.badgeCount = userChat.session?.alert ?? 0
    self.isBadgeHidden = self.badgeCount == 0
    self.isClosed = userChat.isClosed
  }
  
  static func getWelcomeModel(
    with plugin: CHPlugin,
    user: CHUser,
    supportBotMessage: CHMessage? = nil) -> UserChatCellModel {
    var model = UserChatCellModel()
    let bot = botSelector(state: mainStore.state, botName: plugin.botName)
    model.avatar = bot ?? mainStore.state.channel
    model.title = bot?.name ?? mainStore.state.channel.name
    model.lastMessage = supportBotMessage?.attributedText?.string
      ?? user.getWelcome()?.string
    model.isBadgeHidden = true
    model.badgeCount = 0
    return model
  }
}
