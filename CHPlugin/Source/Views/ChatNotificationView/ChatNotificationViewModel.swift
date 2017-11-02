//
//  ChatNotificationViewModel.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 2..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

protocol ChatNotificationViewModelType {
  var message: String? { get }
  var name: String? { get }
  var timestamp: String? { get }
  var avatar: CHEntity { get }
}

struct ChatNotificationViewModel: ChatNotificationViewModelType {
  var message: String?
  var name: String?
  var timestamp: String?
  var avatar: CHEntity

  init(push: CHPush) {
    self.message = push.message?.lastMessage ?? ""
    self.name = push.isReviewLog ? CHAssets.localized("ch.review.require.title") : push.manager?.name
    self.timestamp = push.message?.readableCreatedAt
    self.avatar = push.isReviewLog ? ReviewAvatar() : push.manager ?? CHManager()
  }
}
