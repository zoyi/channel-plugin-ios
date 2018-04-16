//
//  ProfileCellModel.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit

protocol ProfileCellModelType: MessageCellModelType {
  var profileItems: [CHProfileItem] { get set }
  var currentIndex: Int { get set }
  var totalCount: Int { get set }
}

class ProfileCellModel: ProfileCellModelType {
  var profileItems: [CHProfileItem]
  var currentIndex: Int
  var totalCount: Int
  
  let name: String
  let timestamp: String
  let timestampIsHidden: Bool
  let message: CHMessage
  let avatarEntity: CHEntity
  let avatarIsHidden: Bool
  let bubbleBackgroundColor: UIColor
  let textColor: UIColor
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
  
  init(message: CHMessage, previous: CHMessage?) {
    let channel = mainStore.state.channel
    let plugin = mainStore.state.plugin
    let isContinuous = message.isContinue(previous: previous)
    let clipType = MessageCellModel.getClipType(message: message)
    let createdByMe = false
    
    self.name = message.entity?.name ?? ""
    self.timestamp = message.readableCreatedAt
    self.timestampIsHidden = isContinuous
    self.message = message
    self.avatarEntity = message.entity ?? channel
    self.avatarIsHidden = isContinuous
    self.bubbleBackgroundColor = CHColors.lightGray
    self.textColor = plugin.textColor == "white" ? CHColors.white : CHColors.black
    self.usernameIsHidden = isContinuous
    self.imageIsHidden = (clipType != ClipType.Image)
    self.fileIsHidden = (clipType != ClipType.File)
    self.webpageIsHidden = (clipType != ClipType.Webpage)
    self.webpage = message.webPage
    self.file = message.file
    self.createdByMe = createdByMe
    self.isContinuous = isContinuous
    
    self.messageType = message.messageType
    self.progress = message.progress
    self.isFailed = message.state == .Failed
    
    //profile cell infomation
    self.profileItems = message.profileBot ?? []
    if let index = self.profileItems.index(where: { (profileItem) -> Bool in
      return profileItem.value == nil
    }) {
      self.currentIndex = index
    } else {
      self.currentIndex = self.profileItems.count - 1
    }
    //calculated need to fill index 
    self.totalCount = self.profileItems.count //max 4
  }
}
