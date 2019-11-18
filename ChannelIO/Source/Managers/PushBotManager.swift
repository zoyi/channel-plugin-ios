//
//  PushBotManager.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/11/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class PushBotManager {
  internal static var disposeBag = DisposeBag()
  internal static var reached: [String: Bool] = [:]
  
  class func reset() {
    reached = [:]
    disposeBag = DisposeBag()
  }
  
  class func process(with nudges: [CHNudge]? = [], property: [String: Any]) {
    guard let nudges = nudges else { return }
    guard mainStore.state.channel.canUsePushBot else { return }
    
//    if let nudge = response.nudge {
//      reached[nudge.id] = true
//    }
//
//    let (chat, message, session) = CHUserChat.createLocal(
//      writer: response.bot,
//      variant: response.variant
//    )
//
//    mainStore.dispatch(
//      CreateLocalUserChat(
//        chat: chat,
//        message: message,
//        writer: response.bot,
//        session: session
//      )
//    )
//    guard ChannelIO.baseNavigation == nil else { return }
//    if let chat = chat, let message = message {
//      mainStore.dispatch(GetPush(payload: CHPush(
//        chat: chat,
//        message: message,
//        response: response
//      )))
//    }
  }
}
