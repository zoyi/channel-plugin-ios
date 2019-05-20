//
//  SettingInteractor.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift
import RxCocoa

class SettingInteractor: SettingInteractorProtocol {
  weak var presenter: SettingPresenterProtocol?
  
  var guest: CHGuest = mainStore.state.guest
  var updateSignal = PublishRelay<CHGuest>()
  
  func subscribeDataSource() {
    mainStore.subscribe(self)
  }
  
  func unsubscribeDataSource() {
    mainStore.unsubscribe(self)
  }
  
  func getChannel() -> Observable<CHChannel> {
    return ChannelPromise.getChannel()
  }
  
  func getProfileSchemas() -> Observable<[CHProfileSchema]> {
    return PluginPromise.getProfileSchemas(pluginId: mainStore.state.plugin.id)
  }
  
  func getCurrentLocale() -> CHLocale? {
    return ChannelIO.settings?.locale
  }
  
  func getTranslationEnabled() -> Bool {
    return mainStore.state.userChatsState.showTranslation
  }
  
  func updateGuest() -> Observable<CHGuest> {
    return self.updateSignal.asObservable()
  }
}

extension SettingInteractor: StoreSubscriber {
  func newState(state: AppState) {
    self.updateSignal.accept(state.guest)
  }
}
