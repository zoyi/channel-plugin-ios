//
//  User.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

struct CHUser: CHEntity {
  var id = ""
  var memberId = ""
  var veilId = ""
  var unifiedId: String?
  var popUpChatId: String?
  var name = ""
  var profile: [String : Any]?
  var alert: Int? = 0
  var unread: Int? = 0
  var locale: String = ""
  var country: String = ""
  var city:String = ""
  var createdAt: Date?
  var updatedAt: Date?
  var segment: String?
  var avatarUrl: String?
  var mobileNumber: String?
  var tags: [String]?
  var systemLanguage: CHLocaleString?
  var language: String?
  var unsubscribed: Bool = false
  }

extension CHUser: Mappable {
  init?(map: Map) { }

  init(id: String,
       name: String,
       avatarUrl: String?,
       mobileNumber: String?,
       profile: [String: Any]?) {
    self.id = id
    self.name = name
    self.avatarUrl = avatarUrl
    self.mobileNumber = mobileNumber
    self.profile = profile
  }
  
  mutating func mapping(map: Map) {
    id              <- map["id"]
    memberId        <- map["memberId"]
    veilId          <- map["veilId"]
    unifiedId       <- map["unifiedId"]
    name            <- map["name"]
    popUpChatId     <- map["popUpChatId"]
    profile         <- map["profile"]
    alert           <- map["alert"]
    unread          <- map["unread"]
    locale          <- map["locale"]
    city            <- map["city"]
    country         <- map["country"]
    createdAt       <- (map["createdAt"], CustomDateTransform())
    updatedAt       <- (map["updatedAt"], CustomDateTransform())
    segment         <- map["rfsegment"]
    avatarUrl       <- map["avatarUrl"]
    mobileNumber    <- map["mobileNumber"]
    tags            <- map["tags"]
    systemLanguage  <- map["systemLanguage"]
    language        <- map["language"]
    unsubscribed    <- map["unsubscribed"]
  }
}

extension CHUser: Equatable {}

func ==(lhs: CHUser, rhs: CHUser) -> Bool {
  return lhs.id == rhs.id &&
    lhs.memberId == rhs.memberId &&
    lhs.veilId == rhs.veilId &&
    lhs.unifiedId == rhs.unifiedId &&
    lhs.popUpChatId == rhs.popUpChatId &&
    lhs.name == rhs.name &&
    lhs.mobileNumber == rhs.mobileNumber &&
    lhs.avatarUrl == rhs.avatarUrl &&
    lhs.segment == rhs.segment &&
    lhs.locale == rhs.locale &&
    lhs.country == rhs.country &&
    lhs.city == rhs.city &&
    lhs.alert == rhs.alert &&
    lhs.unread == rhs.unread &&
    lhs.tags == rhs.tags &&
    lhs.systemLanguage == rhs.systemLanguage &&
    lhs.language == rhs.language &&
    lhs.createdAt == rhs.createdAt &&
    lhs.updatedAt == rhs.updatedAt &&
    lhs.unsubscribed == rhs.unsubscribed
}

extension CHUser {
  func getWelcome(with config: CHMessageParserConfig? = nil) -> NSAttributedString? {
    return mainStore.state.plugin.welcomeI18n?.getAttributedMessage(with: config)
  }
  
  func getWelcomeBlock() -> CHMessageBlock? {
    return mainStore.state.plugin.welcomeI18n?.getMessageBlock()
  }
  
  func updateProfile(key: String, value: Any?) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.updateUser(profile: [key: value])
  }
  
  static func updateLanguage(with language: String) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.updateUser(language: language)
  }
  
  static func updateUser(param: UpdateUserParam) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.updateUser(param: param)

  static func updateUnsubscribed(with unsubscribed: Bool) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.updateUser(unsubscribed: unsubscribed)
  }
  
  static func updateUser(
    profile: [String: Any?]? = nil,
    profileOnce: [String: Any?]? = nil,
    tags: [String]? = nil,
    unsubscribed: Bool? = nil,
    language: String? = nil) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.updateUser(
      profile: profile,
      profileOnce: profileOnce,
      tags: tags,
      unsubscribed: unsubscribed,
      language: language
    )
  }
  
  static func addTags(tags: [String]?) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.addTags(tags: tags)
  }
  
  static func removeTags(tags: [String]?) -> Observable<(CHUser?, ChannelError?)> {
    return UserPromise.removeTags(tags: tags)
  }
  
  static func closePopup() -> Observable<Any?> {
    return UserPromise.closePopup()
  }
  
  static func get() -> CHUser {
    return userSelector(state: mainStore.state)
  }
}

