//
//  CHForm.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import ObjectMapper

enum ActionOptionKey: String {
  case disableToManager
}

enum ActionType: String {
  case select
  case button
  case solve = "userChat.solve"
  case close = "userChat.close"
  case support = "supportBot"
}

struct CHAction {
  var type: ActionType = .select
  var inputs: [CHInput] = []
  var closed: Bool = false
  var option: [ActionOptionKey: Bool] = [:]
  
  static func create(botEntry: CHSupportBotEntryInfo) -> CHAction {
    var action = CHAction()
    action.type = .support
    action.inputs = botEntry.actions.map { (action) in
      let (text, onlyEmoji) = CustomMessageTransform.markdown.parse(action.text)
      return CHInput(key: action.key, text: text, onlyEmoji: onlyEmoji)
    }
    
    return action
  }
}

extension CHAction: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    type        <- map["type"]
    inputs      <- map["inputs"]
    option      <- map["option"]
    closed      <- map["closed"]
  }
}

struct CHInput {
  var key: String = ""
  var text: NSAttributedString? = nil
  
  var onlyEmoji: Bool = false
}

extension CHInput: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    key         <- map["key"]
    let rawText = map["text"].currentValue as? String ?? ""
    (text, onlyEmoji) = CustomMessageTransform.markdown.parse(rawText)
  }
}

struct CHSubmit {
  var id: String = ""
  var key: String = ""
}

extension CHSubmit: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id        <- map["id"]
    key       <- map["key"]
  }
}
