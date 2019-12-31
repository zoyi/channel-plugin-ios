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
  var bot: CHBot?
  var manager: CHManager?
  var userChat: CHUserChat?
  
  var showLog: Bool = true
  var buttonTitle: String? = nil
  
  var mobileExposureType: InAppNotificationType = .banner
  
  var attachmentType: CHAttachmentType = .none
  var redirectUrl: String? = nil
}

extension CHPush : Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    message   <- map["entity"]
    manager   <- map["refers.manager"]
    bot       <- map["refers.bot"]
    user      <- map["refers.user"]
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
      lhs.mobileExposureType == rhs.mobileExposureType &&
      lhs.attachmentType == rhs.attachmentType
  }
}

