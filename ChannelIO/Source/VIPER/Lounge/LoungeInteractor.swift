//
//  LoungeInteractor.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift
import RxCocoa

class LoungeInteractor: NSObject, LoungeInteractorProtocol {  
  var presenter: LoungePresenterProtocol?
  
  var chatSignal = PublishRelay<[CHUserChat]>()
  var infoSignal = PublishRelay<(CHChannel, CHPlugin)>()
  var sourceSignal = PublishRelay<[Any?]>()
  
  var chats: [CHUserChat] = []
  var plugin: CHPlugin? = nil
  var channel: CHChannel? = nil
  var sources: [Any] = []
  
  var showCompleted = mainStore.state.userChatsState.showCompletedChats
  var showTranslated: CHLocale? = ChannelIO.settings?.locale 
  
  func subscribeDataSource() {
    mainStore.subscribe(self)
  }
  
  func unsubscribeDataSource() {
    mainStore.unsubscribe(self)
  }

  func getChannel() -> Observable<CHChannel> {
    return Observable.create({ (subscriber) -> Disposable in
      subscriber.onNext(mainStore.state.channel)
      subscriber.onCompleted()
      return Disposables.create {
        
      }
    })
  }
  
  func getPlugin() -> Observable<(CHPlugin, CHBot?)> {
    return PluginPromise.getPlugin(pluginId: mainStore.state.plugin.id)
  }
  
  func getFollowers() -> Observable<[CHManager]> {
    return CHManager.getRecentFollowers()
  }
  
  func getChats() -> Observable<[CHUserChat]> {
    return Observable.create({ (subscriber) -> Disposable in
      let signal = UserChatPromise.getChats(since: nil, limit: 4, showCompleted: true)
        .subscribe(onNext: { [weak self] (data) in
          mainStore.dispatch(GetUserChats(payload: data))
          let showCompletion = mainStore.state.userChatsState.showCompletedChats
          let chats = userChatsSelector(state: mainStore.state, showCompleted: showCompletion)
          self?.chats = chats
          subscriber.onNext(chats)
          subscriber.onCompleted()
        }, onError: { error in
          subscriber.onError(error)
        })
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func getExternalSource() -> Observable<Any?> {
    return Observable.create({ (subscriber) -> Disposable in
      subscriber.onNext(nil)
      subscriber.onCompleted()
      return Disposables.create {

      }
    })
  }
  
  func updateChats() -> Observable<[CHUserChat]> {
    return self.chatSignal.asObservable()
  }
  
  func updateGeneralInfo() -> Observable<(CHChannel, CHPlugin)> {
    let channel = mainStore.state.channel
    let plugin = mainStore.state.plugin
    return Observable.just((channel, plugin))
  }
  
  func updateExternalSource() -> Observable<[Any]> {
    return .just([])
  }
}

extension LoungeInteractor: StoreSubscriber {
  func newState(state: AppState) {
    let userChats = userChatsSelector(
      state: mainStore.state,
      showCompleted: state.userChatsState.showCompletedChats
    )
    
    if !self.chats.elementsEqual(userChats) {
      self.chats = userChats
      self.chatSignal.accept(userChats)
    }
    
    if self.channel != state.channel || self.plugin != state.plugin {
      self.channel = state.channel
      self.plugin = state.plugin
      self.infoSignal.accept((state.channel, state.plugin))
    }
    
//    if !self.sources.elementsEqual(sources) {
//
//    }
//
//    self.sourceSignal.accept([])
//    
    //if language change update
    //if channel change update
    //if plugin change update
    //if userchats changes update
  }
}

