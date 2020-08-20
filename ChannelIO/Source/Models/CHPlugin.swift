//
//  Plugin.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 18..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import RxSwift
import Foundation
import ObjectMapper

struct CHPlugin: ModelType {
  var id = ""
  var color = ""
  var gradientColor = ""
  var borderColor = ""
  var textColor = ""
  var botName = ""
  var profileBotSchemaIds: [String] = []
  
  var mobilePosition = "right"
  var welcomeI18n: CHi18n?
  var showPoweredBy: Bool?
  
  var name: String {
    return mainStore.state.channel.name
  }
  
  var isValid: Bool {
    return id != ""
  }
  
  var textUIColor: UIColor {
    if self.textColor == "white" {
      return .white
    } else {
      return .black
    }
  }
  
  var gradientColors: [UIColor] {
    let color = UIColor(self.color) ?? .white
    let gradientColor = UIColor(self.gradientColor) ?? .white
    
    return [color, color, color, gradientColor]
  }
  
  var bgColor: UIColor {
    return UIColor(self.color) ?? .white
  }
}

extension CHPlugin: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id                    <- map["id"]
    color                 <- map["color"]
    gradientColor         <- map["gradientColor"]
    borderColor           <- map["borderColor"]
    textColor             <- map["textColor"]
    botName               <- map["botName"]
    welcomeI18n           <- map["welcomeI18n"]
    showPoweredBy         <- map["showPoweredBy"]
    profileBotSchemaIds   <- map["profileBotSchemaIds"]
  }
}

extension CHPlugin {
  static func get(with key: String) -> Observable<(CHPlugin, CHBot?)> {
    return PluginPromise.getPlugin(pluginKey: key)
  }
}

extension CHPlugin: Equatable {
  static func == (lhs:CHPlugin, rhs:CHPlugin) -> Bool {
    return lhs.id == rhs.id &&
      lhs.color == rhs.color &&
      lhs.gradientColor == rhs.gradientColor &&
      lhs.borderColor == rhs.borderColor &&
      lhs.textColor == rhs.textColor &&
      lhs.botName == rhs.botName &&
      lhs.name == rhs.name
  }
}
