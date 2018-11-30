//
//  ChatNotificationViewModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 2..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

protocol ChatNotificationViewModelType {
  var message: NSAttributedString? { get }
  var name: String? { get }
  var timestamp: String? { get }
  var avatar: CHEntity? { get }
  
  var title: String? { get set }
  var imageUrl: URL? { get set }
  var imageHeight: CGFloat { get set }
  var imageWidth: CGFloat { get set }
  var imageRedirect: String? { get set }
  var buttonTitle: String? { get set }
  var buttonRedirect: String? { get set }
  var themeColor: UIColor? { get set }
}

enum CHAttachmentType: String {
  case none
  case button
  case image
}

struct ChatNotificationViewModel: ChatNotificationViewModelType {
  var message: NSAttributedString?
  var name: String?
  var timestamp: String?
  var avatar: CHEntity?
  
  var title: String? = nil
  var imageUrl: URL? = nil
  var imageHeight: CGFloat = 0.f
  var imageWidth: CGFloat = 0.f
  var imageRedirect: String? = nil
  var buttonTitle: String? = nil
  var buttonRedirect: String? = nil
  var themeColor: UIColor? = nil

  init(push: CHPush) {
    if push.isReviewLog {
      self.name = CHAssets.localized("ch.review.require.title")
      self.avatar = ReviewAvatar()
    } else if let managerName = push.manager?.name {
      self.name = managerName
      self.avatar = push.manager
    } else if let botName = push.bot?.name {
      self.name = botName
      self.avatar = push.bot
    }
    
    if let title = push.message?.title, title != "" {
      self.title = title
    }
    
    switch push.attachmentType {
    case .image:
      if let file = push.message?.file, file.image {
        self.imageUrl = URL(string: file.url)
        self.imageWidth = file.previewThumb?.width ?? 0.f
        self.imageHeight = file.previewThumb?.height ?? 0.f
      }
      self.imageRedirect = push.redirectUrl
    case .button:
      if let buttonTitle = push.buttonTitle {
        self.buttonTitle = buttonTitle
      }
      self.imageRedirect = push.redirectUrl
    default:
      break
    }
    
    self.themeColor = UIColor(hex: mainStore.state.plugin.color)
    
    if let logMessage = push.message?.logMessage, push.showLog {
      let attributedText = NSMutableAttributedString(string: logMessage)
      attributedText.addAttributes([
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: CHColors.charcoalGrey
      ],
      range: NSRange(location: 0, length: logMessage.count))
      self.message = attributedText
    } else {
      self.message = push.message?.messageV2
    }

    self.timestamp = push.message?.readableCreatedAt
  }
}
