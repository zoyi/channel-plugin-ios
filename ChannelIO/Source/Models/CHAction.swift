//
//  CHForm.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

enum ActionType: String {
  case select
  case button
  case solve = "userChat.solve"
  case close = "userChat.close"
  case support = "supportBot"
}

struct CHAction {
  var type: ActionType = .select
  var buttons: [CHActionButton] = []
  var closed: Bool = false
  
  static func create(botEntry: CHSupportBotEntryInfo) -> CHAction {
    var action = CHAction()
    action.type = .support
    action.buttons = botEntry.buttons
    
    return action
  }
}

extension CHAction: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    type        <- map["type"]
    buttons     <- map["buttons"]
    closed      <- map["closed"]
  }
}

extension CHAction {
  var displayText: String {
    return self.buttons
      .compactMap{ $0.text?.string }
      .reduce("") { $0 == "" ? "[\($1)]" : $0 + ", [\($1)]" }
  }
}

struct CHActionButton {
  var key: String = ""
  var text: NSAttributedString? = nil
}

extension CHActionButton: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    key <- map["key"]
    
    let rawText = map["text"].currentValue as? String ?? ""
    let transformer = CustomBlockTransform(
      config: CHMessageParserConfig(
        font: UIFont.systemFont(ofSize: 14)
      ))
    
    text = transformer.parser.parseText(rawText)
  }
}

struct CHSubmit {
  var id: String = ""
  var key: String = ""
}

extension CHSubmit: ObjectMapper_Mappable {
  init?(map: ObjectMapper_Map) { }
  
  mutating func mapping(map: ObjectMapper_Map) {
    id        <- map["id"]
    key       <- map["key"]
  }
}
