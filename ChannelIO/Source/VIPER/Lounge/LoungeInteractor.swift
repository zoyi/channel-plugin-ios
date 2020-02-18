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
  
  var chats: [CHUserChat] = []
  var plugin: CHPlugin? = nil
  var channel: CHChannel? = nil
  var sources: [Any] = []
  
  var needUpdate = false
  var showCompleted = mainStore.state.userChatsState.showCompletedChats
  var showTranslated: CHLocale? = ChannelIO.settings?.language
  
  func subscribeDataSource() {
    self.needUpdate = true
    mainStore.subscribe(self)
  }
  
  func unsubscribeDataSource() {
    mainStore.unsubscribe(self)
  }
  
  func getLounge() -> Observable<LoungeResponse> {
    return LoungePromise.getLounge(
      pluginId: mainStore.state.plugin.id,
      url: ChannelIO.hostTopControllerName ?? ""
    )
  }

  func getChannel() -> Observable<CHChannel> {
    return CHChannel.get()
  }
  
  func getChats() -> Observable<[CHUserChat]> {
    let showCompletion = mainStore.state.userChatsState.showCompletedChats
    return Observable.create { (subscriber) -> Disposable in
      let signal = CHUserChat
        .getChats(since: nil, limit: 50, showCompleted: showCompletion)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (data) in
          self?.needUpdate = true
          mainStore.dispatch(GetUserChats(payload: data))
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
    }
  }
  
  func deleteChat(userChat: CHUserChat) -> Observable<CHUserChat> {
    return Observable.create { subscribe in
      
      let observe = userChat.remove()
        .subscribe(onNext: { (_) in
          subscribe.onNext(userChat)
          subscribe.onCompleted()
        }, onError: { (error) in
          subscribe.onError(error)
        })
      
      return Disposables.create() {
        observe.dispose()
      }
    }
  }
  
  func updateChats() -> Observable<[CHUserChat]> {
    return self.chatSignal.asObservable()
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
    
    if !self.chats.elementsEqual(userChats) || self.needUpdate {
      self.needUpdate = false
      self.chats = userChats
      self.chatSignal.accept(userChats)
    }
    
    if self.channel != state.channel || self.plugin != state.plugin {
      self.channel = state.channel
      self.plugin = state.plugin
      self.infoSignal.accept((state.channel, state.plugin))
    }
  }
}

