//
//  MessageCellModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit

protocol MessageCellModelType {
  var id: String { get }
  var name: String { get }
  var timestamp: String { get }
  var timestampIsHidden: Bool { get }
  var message: CHMessage { get }
  var text: NSAttributedString? { get }
  var avatarEntity: CHEntity { get }
  var avatarIsHidden: Bool { get }
  var bubbleBackgroundColor: UIColor { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var linkColor: UIColor { get }
  var usernameIsHidden: Bool { get }
  var webpage: CHWebPage? { get }
  var files: [CHFile] { get }
  var action: CHAction? { get }
  var createdByMe: Bool { get }
  var isContinuous: Bool { get }
  var messageType: MessageType { get }
  var progress: CGFloat { get }
  var isFailed: Bool { get }
  var profileItems: [CHProfileItem] { get set }
  var currentIndex: Int { get set }
  var totalCount: Int { get set }
  var pluginColor: UIColor { get }
  var shouldDisplayForm: Bool { get set }
  var translateState: CHMessageTranslateState { get set }
  var showTranslation: Bool { get }
  var isDeleted: Bool { get }
  var canTranslate: Bool { get }
}

struct MessageCellModel: MessageCellModelType {
  let id: String
  let name: String
  let timestamp: String
  let timestampIsHidden: Bool
  let message: CHMessage
  let text: NSAttributedString?
  let avatarEntity: CHEntity
  let avatarIsHidden: Bool
  let bubbleBackgroundColor: UIColor
  let textColor: UIColor
  let selectedTextColor: UIColor
  let linkColor: UIColor
  let usernameIsHidden: Bool
  let webpage: CHWebPage?
  let files: [CHFile]
  let action: CHAction?
  let createdByMe: Bool
  let isContinuous: Bool
  let messageType: MessageType
  let progress: CGFloat
  let isFailed: Bool
  let pluginColor: UIColor
  
  var profileItems: [CHProfileItem]
  var currentIndex: Int
  var totalCount: Int
  
  var shouldDisplayForm: Bool
  
  var showTranslation: Bool = false
  var translateState: CHMessageTranslateState = .original
  var isDeleted: Bool
  let canTranslate: Bool
  
  init(message: CHMessage, previous: CHMessage?, row: Int? = nil) {
    let channel = mainStore.state.channel
    let plugin = mainStore.state.plugin
    let isContinuous = message.isContinue(other: previous) &&
      previous?.action == nil && previous?.profileBot?.count == 0
    
    let pluginColor = UIColor(plugin.color) ?? UIColor.white
    let createdByMe = message.entity is CHUser

    self.id = message.id
    //TODO: remove DTO dependency from view model later
    self.message = message
    self.action = message.action
    self.name = message.entity?.name ?? ""
    self.timestamp = message.readableCreatedAt
    self.timestampIsHidden = isContinuous
  
    if message.removed {
      self.text = MessageFactory.deleted()
    } else {
      self.text = message.attributedText
    }
    
    if message.removed {
      self.textColor = .grey500
      self.bubbleBackgroundColor = .grey200
    } else if createdByMe {
      self.textColor = plugin.textUIColor
      self.bubbleBackgroundColor = pluginColor
    } else {
      self.textColor = .grey900
      self.bubbleBackgroundColor = .grey200
    }

    self.avatarEntity = message.entity ?? channel
    self.avatarIsHidden = createdByMe || isContinuous
    self.selectedTextColor = plugin.textUIColor
    self.linkColor = createdByMe ? plugin.textUIColor : UIColor.cobalt400
    self.usernameIsHidden = createdByMe || isContinuous
    self.webpage = message.webPage
    self.files = message.files
    self.createdByMe = createdByMe
    self.isContinuous = isContinuous
    self.pluginColor = pluginColor
    self.messageType = message.messageType
    self.progress = message.progress
    self.isFailed = message.state == .networkError
    
    //profileBot
    self.profileItems = message.profileBot ?? []
    if let index = self.profileItems.firstIndex(where: { (profileItem) -> Bool in
      return profileItem.value == nil
    }) {
      self.currentIndex = index
    } else {
      self.currentIndex = self.profileItems.count - 1
    }
    self.totalCount = self.profileItems.count //max 4
    
    //form : select
    self.shouldDisplayForm = message.action != nil && row == 0 && message.action?.closed == false
    
    self.canTranslate = message.language != "" &&
      message.language != CHUtils.deviceLanguage() &&
      message.log == nil
    self.showTranslation = self.canTranslate &&
      mainStore.state.userChatsState.showTranslation &&
      !createdByMe
    self.translateState = message.translateState

    self.isDeleted = message.removed
  }
}
