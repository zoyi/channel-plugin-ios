//
//  UserChatResponse.swift
//  CHPlugin
//
//  Created by Haeun Chung on 07/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

struct ChatResponse {
  var userChat: CHUserChat? = nil
  var session: CHSession? = nil
  var managers: [CHManager]? = nil
  var message: CHMessage? = nil
  var bot: CHBot?
}

extension ChatResponse : ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    userChat          <- map["userChat"]
    session           <- map["session"]
    managers          <- map["managers"]
    message           <- map["message"]
    bot               <- map["bot"]
  }
}

struct LoungeResponse {
  var channel: CHChannel?
  var plugin: CHPlugin?
  var bot: CHBot?
  var operators: [CHManager]?
  var userChatsResponse: UserChatsResponse?
  var supportBotEntryInfo: CHSupportBotEntryInfo?
  var appMessengers: [CHAppMessenger] = []
}

extension LoungeResponse : ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {}
  
  mutating func mapping(map: ObjectMapper_Map) {
    channel                 <- map["channel"]
    plugin                  <- map["plugin"]
    bot                     <- map["bot"]
    operators               <- map["operators"]
    userChatsResponse       <- map["userChats"]
    supportBotEntryInfo     <- map["supportBot"]
    appMessengers           <- map["appMessengers"]
  }
}

struct UriResponse {
  var uri: String?
}

extension UriResponse: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {}
  mutating func mapping(map: ObjectMapper_Map) {
    uri         <- map["uri"]
  }
}

struct UserChatsResponse {
  var sessions: [CHSession]?
  var next: String?
  var userChats: [CHUserChat]?
  var messages: [CHMessage]?
  var managers: [CHManager]?
  var bots: [CHBot]?
}

extension UserChatsResponse : ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) {}
  
  mutating func mapping(map: ObjectMapper_Map) {
    sessions          <- map["sessions"]
    next              <- map["next"]
    userChats         <- map["userChats"]
    messages          <- map["messages"]
    managers          <- map["managers"]
    bots              <- map["bots"]
  }
}

struct GeoIPInfo {
  var ip: String = ""
  var country: String = ""
  var city: String = ""
  var timezone: String = ""
  var longitude: CGFloat = 0.0
  var latitude: CGFloat = 0.0
}

extension GeoIPInfo : ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    ip        <- map["ip"]
    country   <- map["country"]
    city      <- map["city"]
    timezone  <- map["timezone"]
    longitude <- map["longitude"]
    latitude  <- map["latitude"]
  }
}

struct CHCountry: Codable {
  var name = ""
  var code = ""
  var dial = ""
}

extension CHCountry: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    name       <- map["name"]
    code       <- map["code"]
    dial       <- (map["callingCode"], StringTransform())
  }
}

struct CHErrorResponse: ObjectMapper_Mappable {
  var message: String!
  var field: String?
  
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    message <- map["message"]
    field <- map["field"]
  }
}
