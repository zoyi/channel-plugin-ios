//
//  ChatNotificationViewModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 2..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

protocol InAppNotificationViewModelType {
  var message: NSAttributedString? { get }
  var name: String? { get }
  var timestamp: String? { get }
  var avatar: CHEntity? { get }
  var files: [CHFile] { get set }
  var webPage: CHWebPage? { get set }
  var mobileExposureType: InAppNotificationType { get set }
  var hasMedia: Bool { get set }
}

struct InAppNotificationViewModel: InAppNotificationViewModelType {
  var message: NSAttributedString?
  var name: String?
  var timestamp: String?
  var avatar: CHEntity?
  var files: [CHFile] = []
  var webPage: CHWebPage?
  var mobileExposureType: InAppNotificationType = .banner
  var hasMedia: Bool = false
  
  init(push: CHPush) {
    if let managerName = push.manager?.name {
      self.name = managerName
      self.avatar = push.manager
    } else if let botName = push.bot?.name {
      self.name = botName
      self.avatar = push.bot
    }
    
    self.files = push.message?.sortedFiles ?? []
    self.webPage = push.message?.webPage
    self.timestamp = push.message?.readableCreatedAt
    
    self.mobileExposureType = push.mobileExposureType
    
    let mediaFileCount = push.message?.sortedFiles
      .filter { $0.type == .video || $0.type == .image }
      .count ?? 0
    self.hasMedia = mediaFileCount > 0 ||
      push.message?.webPage?.thumbUrl != nil ||
      push.message?.webPage?.youtubeId != nil
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    paragraphStyle.minimumLineHeight = 18
    
    if let logMessage = push.message?.logMessage, push.showLog {
      let attributedText = NSMutableAttributedString(string: logMessage)
      attributedText.addAttributes(
        [.font: UIFont.systemFont(ofSize: 13),
         .foregroundColor: UIColor.grey900,
         .paragraphStyle: paragraphStyle
        ],
        range: NSRange(location: 0, length: logMessage.count))
      self.message = attributedText
    }
//    else if let message = push.message?.messageV2 {
//      let fontSize = self.mobileExposureType == .fullScreen ? 14.f : 13.f
//      let newAttributedString = NSMutableAttributedString()
//      newAttributedString.append(message)
//      newAttributedString.enumerateAttribute(
//        .font,
//        in: NSMakeRange(0, newAttributedString.length),
//        options: []
//      ) {
//        value, range, stop in
//        guard let currentFont = value as? UIFont else { return }
//        let newFont = currentFont.isBold ?
//          UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//        newAttributedString.addAttributes([.font: newFont], range: range)
//      }
//
//      newAttributedString.addAttributes(
//        [.foregroundColor: UIColor.grey900,
//         .paragraphStyle: paragraphStyle
//        ],
//        range: NSRange(location: 0, length: message.string.count))
//      self.message = newAttributedString
//    }
  }
  
  init(message: CHMessage) {
    let person = message.getWriter()
    
    if let manager = person as? CHManager {
      self.name = manager.name
      self.avatar = manager
    } else if let bot = person as? CHBot {
      self.name = bot.name
      self.avatar = bot
    }
    
    self.files = message.sortedFiles
    self.webPage = message.webPage
    self.timestamp = message.readableCreatedAt
    
//    self.mobileExposureType = message.mobileExposureType
    
    let mediaFileCount = message.sortedFiles
      .filter { $0.type == .video || $0.type == .image }
      .count
    self.hasMedia = mediaFileCount > 0 ||
      message.webPage?.thumbUrl != nil ||
      message.webPage?.youtubeId != nil

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left
    paragraphStyle.minimumLineHeight = 18
    
//    if let message = message.messageV2 {
//      let fontSize = self.mobileExposureType == .fullScreen ? 14.f : 13.f
//      let newAttributedString = NSMutableAttributedString()
//      newAttributedString.append(message)
//      newAttributedString.enumerateAttribute(
//        .font,
//        in: NSMakeRange(0, newAttributedString.length),
//        options: []
//      ) {
//        value, range, stop in
//        guard let currentFont = value as? UIFont else { return }
//        let newFont = currentFont.isBold ?
//          UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
//        newAttributedString.addAttributes([.font: newFont], range: range)
//      }
//
//      newAttributedString.addAttributes(
//        [.foregroundColor: UIColor.grey900,
//         .paragraphStyle: paragraphStyle
//        ],
//        range: NSRange(location: 0, length: message.string.count))
//      self.message = newAttributedString
//    }
  }
}
