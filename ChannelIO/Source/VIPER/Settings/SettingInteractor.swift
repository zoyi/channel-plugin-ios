//
//  SettingInteractor.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift
//import RxCocoa

class SettingInteractor: SettingInteractorProtocol {
  weak var presenter: SettingPresenterProtocol?
  
  var channel: CHChannel? = nil
  var plugin: CHPlugin? = nil
  var user: CHUser? = nil
  var showCloseChat: Bool? = nil
  var userUnsubscribed: Bool? = nil
  var showTranslation: Bool? = nil
  var language: LanguageOption? = nil
  
  var updateSignal = _RXRelay_PublishRelay<CHUser>()
  var updateOptionSignal = _RXRelay_PublishRelay<Any?>()
  var updateGeneralSignal = _RXRelay_PublishRelay<(CHChannel, CHPlugin)>()
  
  private var isUpdatingUnsubscribed = false
  private let disposeBag = _RXSwift_DisposeBag()
  
  func subscribeDataSource() {
    mainStore.subscribe(self)
  }
  
  func unsubscribeDataSource() {
    mainStore.unsubscribe(self)
  }
  
  func getChannel() -> _RXSwift_Observable<CHChannel> {
    return CHChannel.get()
  }
  
  func getProfileSchemas() -> _RXSwift_Observable<[CHProfileSchema]> {
    return PluginPromise.getProfileSchemas(pluginId: mainStore.state.plugin.id)
  }
  
  func getTranslationEnabled() -> Bool {
    return mainStore.state.userChatsState.showTranslation
  }
  
  func updateUser() -> _RXSwift_Observable<CHUser> {
    return self.updateSignal.asObservable()
  }
  
  func updateUserUnsubscribed(with unsubscribed: Bool) {
    self.isUpdatingUnsubscribed = true
    CHUser
    .updateUnsubscribed(with: unsubscribed)
    .observeOn(_RXSwift_MainScheduler.instance)
    .subscribe(onNext: { (user, error) in
      mainStore.dispatch(UpdateUser(payload: user))
      self.isUpdatingUnsubscribed = false
      
      guard let error = error else { return }
      
      CHNotification.shared.display(
        message: error.errorDescription ?? error.localizedDescription,
        config: CHNotificationConfiguration.warningServerErrorConfig
      )
    }).disposed(by: self.disposeBag)
  }
  
  func updateOptions() -> _RXSwift_Observable<Any?> {
    return self.updateOptionSignal.asObservable()
  }
  
  func updateGeneral() -> _RXSwift_Observable<(CHChannel, CHPlugin)> {
    return self.updateGeneralSignal.asObservable()
  }
}

extension SettingInteractor: ReSwift_StoreSubscriber {
  func newState(state: AppState) {
    if self.channel != state.channel ||
      self.plugin != state.plugin {
      self.channel = state.channel
      self.plugin = state.plugin
      self.updateGeneralSignal.accept((state.channel, state.plugin))
    }
    
    if self.language != ChannelIO.bootConfig?.language ||
      self.showTranslation != state.userChatsState.showTranslation ||
      self.showCloseChat != state.userChatsState.showCompletedChats ||
      self.userUnsubscribed != state.user.unsubscribed {
      self.language = ChannelIO.bootConfig?.language
      self.showTranslation = state.userChatsState.showTranslation
      self.showCloseChat = state.userChatsState.showCompletedChats
      self.userUnsubscribed = state.user.unsubscribed
      self.updateOptionSignal.accept(nil)
    }
    
    if (self.user == nil || self.user != state.user) && !self.isUpdatingUnsubscribed {
      self.user = state.user
      self.updateSignal.accept(state.user)
    }
  }
}
