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
  var mobileExposureType: InAppNotificationType
  var hasMedia: Bool = false
  
  init(push: CHPushDisplayable) {
    self.name = push.writer?.name ?? ""
    self.avatar = push.writer
    self.files = push.sortedFiles
    self.webPage = push.webPage
    self.timestamp = push.readableCreatedAt
    
    self.mobileExposureType = push.mobileExposureType ?? .banner
    
    let mediaFileCount = push.sortedFiles
      .filter { $0.type == .video || $0.type == .image }
      .count
    self.hasMedia = mediaFileCount > 0 ||
      push.webPage?.thumbUrl != nil ||
      push.webPage?.youtubeId != nil

    if let logMessage = push.logMessage {
      let attributedText = NSMutableAttributedString(string: logMessage)
      attributedText.addAttributes(
        [.font: UIFont.systemFont(ofSize: 13),
         .foregroundColor: UIColor.grey900,
         .paragraphStyle: UIFactory.pushParagraphStyle
        ],
        range: NSRange(location: 0, length: logMessage.count))
      self.message = attributedText
    } else if push.blocks.count != 0 {
      let fontSize = self.mobileExposureType == .fullScreen ? 14.f : 13.f
      let config = CHMessageParserConfig(
        font: UIFont.systemFont(ofSize: fontSize),
        style: UIFactory.pushParagraphStyle
      )
      let transformer = CustomBlockTransform(config: config)
      let result = transformer.parser.parse(blocks: push.blocks)
      self.message = result
    }
  }
}
