//
//  MessageCellModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 9..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit

enum ClipType {
  case None
  case File
  case Image
  case Webpage
}

protocol MessageCellModelType {
  var name: String { get }
  var timestamp: String { get }
  var timestampIsHidden: Bool { get }
  var message: CHMessage { get }
  var avatarEntity: CHEntity { get }
  var avatarIsHidden: Bool { get }
  var bubbleBackgroundColor: UIColor { get }
  var textColor: UIColor { get }
  var selectedTextColor: UIColor { get }
  var linkColor: UIColor { get }
  var usernameIsHidden: Bool { get }
  var imageIsHidden: Bool { get }
  var fileIsHidden: Bool { get }
  var webpageIsHidden: Bool { get }
  var webpage: CHWebPage? { get }
  var file: CHFile? { get }
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
  var clipType: ClipType { get }
  var buttons: [CHLink] { get }
  var isDeleted: Bool { get }
}

struct MessageCellModel: MessageCellModelType {
  let name: String
  let timestamp: String
  let timestampIsHidden: Bool
  let message: CHMessage
  let avatarEntity: CHEntity
  let avatarIsHidden: Bool
  let bubbleBackgroundColor: UIColor
  let textColor: UIColor
  let selectedTextColor: UIColor
  let linkColor: UIColor
  let usernameIsHidden: Bool
  let imageIsHidden: Bool
  let fileIsHidden: Bool
  let webpageIsHidden: Bool
  let webpage: CHWebPage?
  let file: CHFile?
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
  var clipType: ClipType = .None
  var buttons: [CHLink]
  var isDeleted: Bool
  
  init(message: CHMessage, previous: CHMessage?, indexPath: IndexPath? = nil) {
    let channel = mainStore.state.channel
    let plugin = mainStore.state.plugin
    let isContinuous = message.isContinue(other: previous) &&
      previous?.action == nil && previous?.profileBot?.count == 0
    
    let pluginColor = UIColor(plugin.color) ?? UIColor.white
    let cType = MessageCellModel.getClipType(message: message)
    let createdByMe = message.entity is CHUser || message.entity is CHVeil

    self.clipType = cType
    self.name = message.entity?.name ?? ""
    self.timestamp = message.readableCreatedAt
    self.timestampIsHidden = isContinuous
    self.message = message
    self.avatarEntity = message.entity ?? channel
    self.avatarIsHidden = createdByMe || isContinuous
    self.bubbleBackgroundColor = message.onlyEmoji ?
      .clear : (createdByMe ? pluginColor : CHColors.lightGray)
    self.textColor = createdByMe ? plugin.textUIColor : UIColor.grey900
    self.selectedTextColor = plugin.textUIColor
    self.linkColor = createdByMe ? plugin.textUIColor : UIColor.cobalt400
    self.usernameIsHidden = createdByMe || isContinuous
    self.imageIsHidden = (cType != ClipType.Image)
    self.fileIsHidden = (cType != ClipType.File)
    self.webpageIsHidden = (cType != ClipType.Webpage)
    self.webpage = message.webPage
    self.file = message.file
    self.createdByMe = createdByMe
    self.isContinuous = isContinuous
    self.pluginColor = pluginColor
    
    self.messageType = message.messageType
    self.progress = message.progress
    self.isFailed = message.state == .Failed
    
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
    self.shouldDisplayForm = message.action != nil && indexPath?.row == 0 && message.action?.closed == false
    
    self.showTranslation =
      message.language != "" &&
      message.language != CHUtils.getLocale()?.rawValue &&
      mainStore.state.userChatsState.showTranslation &&
      !createdByMe
    self.translateState = message.translateState
    
    //buttons
    self.buttons = message.buttons ?? []
    self.isDeleted = message.isDeleted
  }

  static func getClipType(message: CHMessage) -> ClipType {
    if message.file?.isPreviewable == true ||
      message.file?.mimeType == .image || message.file?.mimeType == .gif ||
      message.file?.imageData != nil {
      return .Image
    } else if message.file != nil {
      return .File
    } else if message.webPage != nil {
      return .Webpage
    } else {
      return .None
    }
  }

}
