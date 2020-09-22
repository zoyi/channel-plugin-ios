//
//  LoungeInteractor.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
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
  
  func getChats() -> Observable<UserChatsResponse> {
    return CHUserChat.getChats(
      since: nil,
      limit: 50,
      showCompleted: mainStore.state.userChatsState.showCompletedChats
    )
  }

  func getChannel() -> Observable<CHChannel> {
    return CHChannel.get()
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

extension LoungeInteractor: ReSwift_StoreSubscriber {
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

