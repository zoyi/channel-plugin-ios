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

class LoungeInteractor: NSObject, LoungeInteractorProtocol {
  var presenter: LoungePresenterProtocol?
  
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
  
  func getPlugin() -> Observable<CHPlugin> {
    return Observable.create({ (subscriber) -> Disposable in
      subscriber.onNext(mainStore.state.plugin)
      subscriber.onCompleted()
      return Disposables.create {
        
      }
    })
  }
  
  func getFollowers() -> Observable<[CHManager]> {
    return CHManager.getRecentFollowers()
  }
  
  func getChats() -> Observable<[CHUserChat]> {
    return Observable.create({ (subscriber) -> Disposable in
      let signal = UserChatPromise.getChats(since: nil, limit: 4, showCompleted: true)
        .subscribe(onNext: { (data) in
          mainStore.dispatch(GetUserChats(payload: data))
          let chats = data["userChats"] as? [CHUserChat] ?? []
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
}

extension LoungeInteractor: StoreSubscriber {
  func newState(state: AppState) {
    
  }
}

