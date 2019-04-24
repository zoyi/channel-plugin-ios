//
//  SettingOptionModel.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

struct SettingOptionModel {
  var title: String = ""
  var type: SettingOptionType = .language
  var option: SettingOptionValueType = .editable
  var value: Any? = nil
  
  static func generate(options: [SettingOptionType]) -> [SettingOptionModel] {
    var models: [SettingOptionModel] = []
    
    for option in options {
      switch option {
      case .language:
        var model = SettingOptionModel()
        
        let locale = CHUtils.getLocale()
        if locale == .english {
          model.title = CHAssets.localized("en")
        } else if locale == .korean {
          model.title = CHAssets.localized("ko")
        } else if locale == .japanese {
          model.title = CHAssets.localized("ja")
        }
        
        model.type = option
        model.option = .selectable
        models.append(model)
      case .translation:
        var model = SettingOptionModel()
        model.title = CHAssets.localized("ch.settings.translate_message")
        model.type = option
        model.option = .switchable
        model.value = mainStore.state.userChatsState.showTranslation
        models.append(model)
      default:
        break
      }
    }
    return models
  }
}

enum SettingOptionType {
  case language
  case translation
}

enum SettingOptionValueType {
  case selectable
  case editable
  case switchable
  case none
}
