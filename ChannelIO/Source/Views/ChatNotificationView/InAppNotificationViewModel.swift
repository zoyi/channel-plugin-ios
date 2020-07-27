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
  var hasText: Bool { get set }
  var mkInfo: MarketingInfo? { get set }
  var buttons: [CHLinkButton] { get set }
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
  var hasText: Bool = false
  var mkInfo: MarketingInfo?
  var buttons: [CHLinkButton] = []
  
  init(push: CHPushDisplayable) {
    let writer = push.writer
      ?? defaultBotSelector(state: mainStore.state)
      ?? mainStore.state.channel
    self.name = writer.name
    self.avatar = writer
    self.files = push.sortedFiles
    self.webPage = push.webPage
    self.buttons = push.buttons
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
      let font = UIFont.systemFont(ofSize: 15)
      attributedText.addAttributes(
        [.font: font,
         .foregroundColor: UIColor.grey900,
         .kern: -0.1,
         .paragraphStyle: UIFactory.pushParagraphStyle,
         .baselineOffset: (UIFactory.pushParagraphStyle.minimumLineHeight - font.lineHeight) / 4
        ],
        range: NSRange(location: 0, length: logMessage.count))
      self.message = attributedText
    } else if push.blocks.count != 0 {
      let config = CHMessageParserConfig(
        font: UIFont.systemFont(ofSize: 15.f),
        style: UIFactory.pushParagraphStyle,
        letterSpacing: -0.1
      )
      let transformer = CustomBlockTransform(config: config, isInappPush: true)
      let result = transformer.parser.parse(blocks: push.blocks)
      self.message = result
    } else if let webPage = push.webPage {
      let text = webPage.title ?? webPage.url?.absoluteString ?? ""
      let attributedText = NSMutableAttributedString(string: text)
      let font = UIFont.systemFont(ofSize: 15.f)
      attributedText.addAttributes(
        [.font: font,
         .kern: -0.1,
         .paragraphStyle: UIFactory.pushParagraphStyle,
         .baselineOffset: (UIFactory.pushParagraphStyle.minimumLineHeight - font.lineHeight) / 4
        ],
        range: NSRange(location: 0, length: text.count)
      )
      self.message = attributedText
    }
    
    self.hasText = self.message != nil && self.message?.string != ""
    self.mkInfo = push.mkInfo
  }
}
