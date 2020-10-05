//
//  Push.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

protocol CHPopupDisplayable {
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
  var buttons: [CHLinkButton] { get }
}

extension CHPopupDisplayable {
  func isEqual(to other: CHPopupDisplayable?) -> Bool {
    let isSameWriter = self.writer != nil ?
      writer!.isEqual(to: other?.writer) : other?.writer == nil
    return isSameWriter &&
      self.sortedFiles == other?.sortedFiles &&
      self.webPage == other?.webPage &&
      self.readableCreatedAt == other?.readableCreatedAt &&
      self.mobileExposureType == other?.mobileExposureType &&
      self.logMessage == other?.logMessage &&
      self.sortedFiles == other?.sortedFiles &&
      self.blocks == other?.blocks &&
      self.chatId == other?.chatId &&
      self.removed == other?.removed &&
      self.mkInfo?.type == other?.mkInfo?.type &&
      self.mkInfo?.id == other?.mkInfo?.id
  }
}

struct CHPopup: CHPopupDisplayable {
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
  
  var buttons: [CHLinkButton] {
    return self.message?.buttons ?? []
  }
}

extension CHPopup : ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    message   <- map["entity"]
    manager   <- map["refers.manager"]
    bot       <- map["refers.bot"]
    user      <- map["refers.user"]
    userChat  <- map["refers.userChat"]
    type      <- map["type"]
  }
}

extension CHPopup: Equatable {
  static func == (lhs:CHPopup, rhs:CHPopup) -> Bool {
    return lhs.type == rhs.type &&
      lhs.message == rhs.message &&
      lhs.bot == rhs.bot &&
      lhs.manager == rhs.manager
  }
}

