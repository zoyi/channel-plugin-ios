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
    return ChannelPromise.getChannel()
  }
  
  func getPlugin() -> Observable<(CHPlugin, CHBot?)> {
    return PluginPromise.getPlugin(pluginId: mainStore.state.plugin.id)
  }
  
  func getFollowers() -> Observable<[CHManager]> {
    return CHManager.getRecentFollowers()
  }
  
  func getSupportBot() -> Observable<CHSupportBotEntryInfo> {
    return Observable.create({ (subscriber) -> Disposable in
      let signal = CHSupportBot.get(with: mainStore.state.plugin.id, fetch: true)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (entry) in
          if entry.step != nil && entry.supportBot != nil {
            mainStore.dispatch(GetSupportBotEntry(bot: nil, entry: entry))
          }
          subscriber.onNext(entry)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })

      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func getChats() -> Observable<[CHUserChat]> {
    return Observable.create({ (subscriber) -> Disposable in
      let showCompletion = PrefStore.getVisibilityOfClosedUserChat()
      let signal = UserChatPromise.getChats(since: nil, limit: 4, showCompleted: showCompletion)
        .observeOn(MainScheduler.instance)
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
  
  func updateChats() -> Observable<[CHUserChat]> {
    return self.chatSignal.asObservable()
  }
  
  func getExternalSource() -> Observable<[CHExternalSourceType:String]?> {
    return ChannelPromise.getExternalMessengers()
  }
  
  func updateExternalSource() -> Observable<[Any]> {
    return .just([])
  }

  func updateGeneralInfo() -> Observable<(CHChannel, CHPlugin)> {
    return self.infoSignal.asObservable()
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

