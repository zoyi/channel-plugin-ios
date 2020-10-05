//
//  AppState.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 15..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

struct AppState: ReSwift_StateType {
  var bootState: BootState
  var plugin: CHPlugin
  var channel: CHChannel
  var user: CHUser
  var userChatsState: UserChatsState
  var popup: CHPopupDisplayable?
  var managersState: ManagersState
  var botsState: BotsState
  var sessionsState: SessionsState
  var messagesState: MessagesState
  var uiState: UIState
  var socketState: WSocketState
  var countryCodeState: CountryCodeState
  var chatState: ChatState
}
// TODO: Will deprecated
@objc public enum CHLocale: Int {
  case english
  case korean
  case japanese
  // it need becase Objective c can't use optional
  case device
}

@objc public enum LanguageOption: Int {
  case english
  case korean
  case japanese
  // it need becase Objective c can't use optional
  case device
}

enum CHLocaleString: String {
  case english = "en"
  case korean = "ko"
  case japanese = "ja"
}
