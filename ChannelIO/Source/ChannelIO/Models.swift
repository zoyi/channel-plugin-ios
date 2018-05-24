//
//  Models.swift
//  ChannelIO
//
//  Created by R3alFr3e on 5/23/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

@objc
public class PushEvent: NSObject {
  @objc public let chatId: String
  @objc public let message: String
  @objc public let senderName: String
  @objc public let senderAvatarUrl: String
  
  init(with pushData: CHPush?) {
    self.chatId = pushData?.userChat?.id ?? ""
    self.message = pushData?.message?.message ?? ""
    self.senderName = pushData?.manager?.name ?? ""
    self.senderAvatarUrl = pushData?.manager?.avatarUrl ?? ""
  }
}

@objc
public class Guest: NSObject {
  @objc public let id: String
  @objc public let name: String
  @objc public let avatarUrl: String?
  @objc public let profile: [String : Any]?
  @objc public let alert: Int
  
  init(with guest: CHGuest) {
    self.id = guest.id
    self.name = guest.name
    self.avatarUrl = guest.avatarUrl
    self.profile = guest.profile
    self.alert = guest.alert
  }
}
