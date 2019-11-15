//
//  AppManager.swift
//  ChannelIO
//
//  Created by Haeun Chung on 02/01/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

struct AppManager {
  static let disposeBag = DisposeBag()
  
  static func boot(pluginKey: String, params: CHParam) -> Observable<[String: Any]> {
    return PluginPromise.boot(pluginKey: pluginKey, params: params)
  }
  
  static func registerPushToken() {
    guard let pushToken = ChannelIO.pushToken else { return }

    PluginPromise
      .registerPushToken(channelId: mainStore.state.channel.id, token: pushToken)
      .subscribe(onNext: { (result) in
        dlog("register token success")
      }, onError:{ error in
        dlog("register token failed")
      }).disposed(by: disposeBag)
  }
  
  static func sendAck(userChatId: String) -> Observable<Bool?> {
    return PluginPromise.sendPushAck(chatId: userChatId)
  }
  
  static func unregisterToken(token: String) {
    PluginPromise.unregisterPushToken(guestToken: token)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { _ in
        dlog("shutdown success")
      }, onError: { (error) in
        dlog("shutdown fail")
      }).disposed(by: disposeBag)
  }
  
  static func checkVersion() -> Observable<Any?> {
    return PluginPromise.checkVersion()
  }
  
  static func getOperators() -> Observable<[CHManager]> {
    return PluginPromise.getOperators()
  }
  
  static func touch() -> Observable<CHUser> {
    return UserPromise.touch()
  }
}
