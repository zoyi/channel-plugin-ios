//
//  AppManager.swift
//  ChannelIO
//
//  Created by Haeun Chung on 02/01/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class AppManager {
  static let shared = AppManager()
  let disposeBag = DisposeBag()
  
  private var viewSignal = PublishSubject<(CHMarketingType?, String?)>()
  private var clickSignal = PublishSubject<(CHMarketingType?, String?)>()
  
  private init() {
    self.viewSignal
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { (type, id) in
        guard let type = type, let id = id else { return }
        switch type {
        case .campaign:
          MarketingPromise
            .viewCampaign(id: id)
            .subscribe()
            .disposed(by: self.disposeBag)
        case .oneTimeMsg:
          MarketingPromise
            .viewOneTimeMsg(id: id)
            .subscribe()
            .disposed(by: self.disposeBag)
        }
      }).disposed(by: self.disposeBag)
    
    self.clickSignal
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { (type, id) in
        guard let type = type, let id = id else { return }
        switch type {
        case .campaign:
          MarketingPromise
            .clickCampaign(id: id)
            .subscribe()
            .disposed(by: self.disposeBag)
        case .oneTimeMsg:
          MarketingPromise
            .clickOneTimeMsg(id: id)
            .subscribe()
            .disposed(by: self.disposeBag)
        }
      }).disposed(by: self.disposeBag)
  }
  
  func boot(pluginKey: String, params: CHParam) -> Observable<BootResponse?> {
    return PluginPromise.boot(pluginKey: pluginKey, params: params)
  }
  
  func registerPushToken() {
    guard let pushToken = ChannelIO.pushToken else { return }

    PluginPromise
      .registerPushToken(token: pushToken)
      .subscribe(onNext: { (result) in
        dlog("register token success")
      }, onError:{ error in
        dlog("register token failed")
      }).disposed(by: disposeBag)
  }
  
  func sendAck(userChatId: String) -> Observable<Bool?> {
    return PluginPromise.sendPushAck(chatId: userChatId)
  }
  
  func unregisterToken() -> Observable<Any?> {
    return PluginPromise.unregisterPushToken()
  }
  
  func checkVersion() -> Observable<Any?> {
    return PluginPromise.checkVersion()
  }
  
  func touch() -> Observable<BootResponse> {
    return UserPromise.touch(pluginId: mainStore.state.plugin.id)
  }
  
  func displayMarketingIfNeeeded() {
    guard let chatId = CHUser.get().popUpChatId else { return }
    
    CHUserChat
      .get(userChatId: chatId)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (chatResponse) in
        mainStore.dispatch(GetUserChat(payload: chatResponse))
        let userChat = userChatSelector(
          state: mainStore.state,
          userChatId: chatResponse.userChat?.id)
        mainStore.dispatch(GetPush(payload: userChat?.lastMessage))
      }).disposed(by: self.disposeBag)
  }
  
  func sendViewMarketing(type: CHMarketingType?, id: String?) {
    self.viewSignal.onNext((type, id))
  }
  
  func sendClickMarketing(type: CHMarketingType?, id: String?) {
    self.clickSignal.onNext((type, id))
  }
}
