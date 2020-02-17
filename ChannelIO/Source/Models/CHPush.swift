//
//  Push.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

protocol CHPushDisplayable {
  var writer: CHEntity? { get }
  var sortedFiles: [CHFile] { get }
  var webPage: CHWebPage? { get }
  var readableCreatedAt: String { get }
  var mobileExposureType: InAppNotificationType? { get }
  var logMessage: String? { get }
  var blocks: [CHMessageBlock] { get }
  var chatId: String { get }
  var removed: Bool { get }
  var mkInfo: MarketingInfo? { get }
}

struct CHPush: CHPushDisplayable {
  var type = ""
  var message: CHMessage?
  var user: CHUser?
  var bot: CHBot?
  var manager: CHManager?
  var userChat: CHUserChat?
  
  var writer: CHEntity? {
    return self.manager ?? self.bot
  }
  
  var sortedFiles: [CHFile] {
    return self.message?.sortedFiles ?? []
  }
  
  var webPage: CHWebPage? {
    return self.message?.webPage
  }
  
  var readableCreatedAt: String {
    return self.message?.readableCreatedAt ?? ""
  }
  
  var mobileExposureType: InAppNotificationType? {
    return self.message?.marketing?.exposureType ?? .banner
  }
  
  var logMessage: String? {
    return self.message?.logMessage
  }
  
  var blocks: [CHMessageBlock] {
    return self.message?.blocks ?? []
  }
  
  var chatId: String {
    return self.userChat?.id ?? ""
  }
  
  var removed: Bool {
    return self.message?.removed ?? false
  }
  
  var mkInfo: MarketingInfo? {
    guard let marketing = self.message?.marketing else { return nil }
    return (marketing.type, marketing.id)
  }
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
      lhs.manager == rhs.manager
  }
}

