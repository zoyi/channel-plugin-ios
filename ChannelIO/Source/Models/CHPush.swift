//
//  Push.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

protocol CHPushDisplayable { }

struct CHPush: CHPushDisplayable {
  var type = ""
  
  var message: CHMessage?
  
  var user: CHUser?
  var veil: CHVeil?
  var bot: CHBot?
  var manager: CHManager?
  var userChat: CHUserChat?
  
  var showLog: Bool = true
  var buttonTitle: String? = nil
  
  var attachmentType: CHAttachmentType = .none
  var redirectUrl: String? = nil
  
  var isNudgePush: Bool = false
}

extension CHPush : Mappable {
  init?(map: Map) { }
  
  init(chat: CHUserChat, message: CHMessage, response: NudgeReachResponse) {
    self.bot = response.bot
    self.message = message
    self.userChat = chat
    self.attachmentType = response.variant?.attachment ?? .none
    self.buttonTitle = response.variant?.buttonTitle
    self.showLog = false
    self.isNudgePush = true
    
    if self.attachmentType == .image, let url = response.variant?.imageRedirectUrl {
      self.redirectUrl = url
    } else if self.attachmentType == .button, let url = response.variant?.buttonRedirectUrl {
      self.redirectUrl = url
    }
  }
  
  mutating func mapping(map: Map) {
    message   <- map["entity"]
    manager   <- map["refers.manager"]
    bot       <- map["refers.bot"]
    user      <- map["refers.user"]
    veil      <- map["refers.veil"]
    userChat  <- map["refers.userChat"]
    type      <- map["type"]
  }
}

extension CHPush: Equatable {
  static func == (lhs:CHPush, rhs:CHPush) -> Bool {
    return lhs.type == rhs.type &&
      lhs.message == rhs.message &&
      lhs.bot == rhs.bot &&
      lhs.manager == rhs.manager &&
      lhs.attachmentType == rhs.attachmentType &&
      lhs.isNudgePush == rhs.isNudgePush
  }
}

