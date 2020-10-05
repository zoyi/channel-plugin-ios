//
//  Session.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation

struct CHSession: ModelType {
  // ModelType
  var id = ""
  // Session
  var chatType: ChatType!
  var chatId = ""
  var personType: PersonType!
  var personId = ""
  var unread = 0
  var alert = 0
  var readAt: Date? = nil
  var postedAt: Date? = nil
}

extension CHSession: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  init(id: String, chatId: String, user: CHUser, alert: Int, type: ChatType = .userChat) {
    self.id = id
    self.chatId = chatId
    self.personType = .user
    self.personId = user.id
    self.alert = alert
    self.chatType = type
  }
  
  mutating func mapping(map: ObjectMapper_Map) {
    id          <- map["id"]
    chatType    <- map["chatType"]
    chatId      <- map["chatId"]
    personType  <- map["personType"]
    personId    <- map["personId"]
    unread      <- map["unread"]
    alert       <- map["alert"]
    readAt      <- (map["readAt"], CustomDateTransform())
    postedAt    <- (map["postedAt"], CustomDateTransform())
  }
}
