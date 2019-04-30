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
  
  var mobilePosition = "right"
  var welcomeNamedI18n: CHi18n?
  var welcomeI18n: CHi18n?
  
  var name: String {
    return mainStore.state.channel.name
  }
  
  var isValid: Bool {
    return id != ""
  }
  
  var textUIColor: UIColor! {
    if self.textColor == "white" {
      return CHColors.white
    } else {
      return CHColors.black
    }
  }
  
  func requestProfileBot(chatId: String) {
    _ = PluginPromise.requestProfileBot(pluginId: self.id, chatId: chatId)
      .subscribe(onNext: { (_) in
        
      })
  }
  
  var gradientColors: [CGColor] {
    let color = UIColor(self.color) ?? .white
    let gradientColor = UIColor(self.gradientColor) ?? .white
    
    return [
      color.cgColor,
      color.cgColor,
      gradientColor.cgColor
    ]
  }
  
  var bgColor: UIColor {
    return UIColor(self.color) ?? .white
  }
}

extension CHPlugin: Mappable {
  init?(map: Map) { }
  
  mutating func mapping(map: Map) {
    id               <- map["id"]
    color            <- map["color"]
    gradientColor    <- map["gradientColor"]
    borderColor      <- map["borderColor"]
    textColor        <- map["textColor"]
    botName          <- map["botName"]
    welcomeNamedI18n <- map["welcomeNamedI18n"]
    welcomeI18n      <- map["welcomeI18n"]
  }
}

extension CHPlugin {
  static func get(with id: String) -> Observable<(CHPlugin, CHBot?)> {
    return PluginPromise.getPlugin(pluginId: id)
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
