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
  
  init(popup: CHPopupDisplayable) {
    let writer = popup.writer
      ?? defaultBotSelector(state: mainStore.state)
      ?? mainStore.state.channel
    self.name = writer.name
    self.avatar = writer
    self.files = popup.sortedFiles
    self.webPage = popup.webPage
    self.buttons = popup.buttons
    self.timestamp = popup.readableCreatedAt
    self.mobileExposureType = popup.mobileExposureType ?? .banner
    
    let mediaFileCount = popup.sortedFiles
      .filter { $0.type == .video || $0.type == .image }
      .count
    self.hasMedia = mediaFileCount > 0 ||
      popup.webPage?.thumbUrl != nil ||
      popup.webPage?.youtubeId != nil

    if let logMessage = popup.logMessage {
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
    } else if popup.blocks.count != 0 {
      let config = CHMessageParserConfig(
        font: UIFont.systemFont(ofSize: 15.f),
        style: UIFactory.pushParagraphStyle,
        letterSpacing: -0.1
      )
      let transformer = CustomBlockTransform(config: config, isInappPush: true)
      let result = transformer.parser.parse(blocks: popup.blocks)
      self.message = result
    } else if let webPage = popup.webPage {
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
    self.mkInfo = popup.mkInfo
  }
}
