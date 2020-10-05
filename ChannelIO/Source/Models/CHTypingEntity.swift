//
//  CHTypingEntity.swift
//  CHPlugin
//
//  Created by R3alFr3e on 11/14/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

struct CHTypingEntity: SocketIO_SocketData {
  var action = ""
  var chatId = ""
  var chatType: ChatType?
  var personId: String?
  var personType: PersonType?

  init(action: String, chatId: String, chatType: ChatType?,
       personId: String? = nil, personType: PersonType? = nil) {
    self.action = action
    self.chatId = chatId
    self.chatType = chatType
    self.personId = personId
    self.personType = personType
  }
  
  func socketRepresentation() -> SocketIO_SocketData {
    return [
      "action": self.action,
      "chatId": self.chatId,
      "chatType": self.chatType?.rawValue ?? "userChat",
    ]
  }
  
  static func transform(from message: CHMessage) -> CHTypingEntity {
    return CHTypingEntity(
      action: "stop",
      chatId: message.chatId,
      chatType: message.chatType,
      personId: message.personId,
      personType: message.personType
    )
  }
}

extension CHTypingEntity: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    action          <- map["action"]
    chatId          <- map["channelId"]
    chatType        <- map["chatType"]
    personId        <- map["personId"]
    personType      <- map["personType"]
  }
}
