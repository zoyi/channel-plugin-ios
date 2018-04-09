//
//  DialogViewModel.swift
//  CHPlugin
//
//  Created by Haeun Chung on 17/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

protocol DialogViewModelType {
  var title: String { get }
  var message: String { get }
  var footer: String { get }
  var errorTitle: String { get }
  var errorMessage: String { get }
  var errorFooter: String { get }
  
  var type: DialogType { get }
  
  func shouldShowFooter() -> Bool
}

//TODO: find a better structure to handle localized string with attributes

struct DialogViewModel: DialogViewModelType {
  var title: String = ""
  var message: String = ""
  var footer: String = ""
  var errorTitle: String = ""
  var errorMessage: String = ""
  var errorFooter: String = ""
  
  var type: DialogType = .Default

  func shouldShowFooter() -> Bool {
    if self.type == .UserName {
      let locale = CHUtils.getLocale()
      return locale == "ko" || locale == "ja"
    } else {
      return true
    }
  }
  
  static func model(type: DialogType) -> DialogViewModel {
    switch type {
    case .UserName:
      return DialogViewModel.nameModel()
    case .PhoneNumber:
      return DialogViewModel.phoneModel()
    case .Completed:
      return DialogViewModel.completeModel()
    default:
      return DialogViewModel.defaultModel()
    }
  }
  
  static func nameModel() -> DialogViewModel {
    return DialogViewModel(
      title: CHAssets.localized("ch.name_verification.title"),
      message: CHAssets.localized("ch.name_verification.description"),
      footer: "",
      errorTitle: CHAssets.localized("ch.name_verification.error.title"),
      errorMessage: "이름에는 숫자나 특수문자가 포함될 수 없습니다.\n고객님 성함을 다시 입력해 주시겠어요?", // TODO: 서버에서 보내준 에러로 보여주기?
      errorFooter: "",
      type: .UserName)
  }
  
  static func phoneModel() -> DialogViewModel {
    return DialogViewModel(
      title: CHAssets.localized("ch.mobile_verification.title"),
      message: CHAssets.localized("ch.mobile_verification.description"),
      footer: "",
      errorTitle: CHAssets.localized("ch.mobile_verification.error.title"),
      errorMessage: CHAssets.localized("ch.mobile_verification.error.description"),
      errorFooter: "",
      type: .PhoneNumber)
  }
  
  static func completeModel() -> DialogViewModel {
    return DialogViewModel(
      title: CHAssets.localized("ch.complete_verification.title"),
      message: "",
      footer:  "",
      errorTitle: "",
      errorMessage: "",
      errorFooter: "",
      type: .Completed)
  }
  
  static func defaultModel() -> DialogViewModel {
    return DialogViewModel(
      title: "title",
      message: "",
      footer:  "",
      errorTitle: "",
      errorMessage: "",
      errorFooter: "",
      type: .Completed)
  }
}


