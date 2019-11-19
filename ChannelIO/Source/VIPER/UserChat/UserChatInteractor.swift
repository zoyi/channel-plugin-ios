//
//  UserChatInteractor.swift
//  CHPlugin
//
//  Created by Haeun Chung on 27/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import Photos

class UserChatInteractor: NSObject, UserChatInteractorProtocol {
  weak var presenter: UserChatPresenterProtocol?
  
  var userChatId: String = "" {
    didSet {
      self.userChat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
    }
  }
  var userChat: CHUserChat? = nil
  
  private var isFetching = false
  private var nextSeq = ""
  
  private let disposeBag = DisposeBag()
  
  func subscribeDataSource() {
    mainStore.subscribe(self) { subcription in
      subcription.select { state in state.chatState }
    }
  }
  
  func unsunbscribeDataSource() {
    mainStore.unsubscribe(self)
  }

  func readyToPresent() -> Observable<Bool> {
    return Observable.create { (subscriber) in
      let signal = CHPlugin
        .get(with: mainStore.state.plugin.id)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (info) in
          mainStore.dispatch(GetPlugin(plugin: info.0, bot: info.1))
          dlog("ready to present")
          subscriber.onNext(true)
          subscriber.onCompleted()
        }, onError: { error in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func joinSocket() {
    WsService.shared.join(chatId: self.userChatId)
  }
  
  func leaveSocket() {
    WsService.shared.leave(chatId: self.userChatId)
  }
  
  func getChannel() -> Observable<CHChannel> {
    return CHChannel.get()
  }
}

extension UserChatInteractor {
  func canLoadMore() -> Bool {
    return self.nextSeq != ""
  }
  
  func fetchMessages() -> Observable<ChatProcessState> {
    guard !self.isFetching else {
      return .just(.messageLoading)
    }
    
    return Observable.create { (subscribe) in
      self.isFetching = true
      let signal = CHMessage
        .getMessages(
          userChatId: self.userChatId,
          since: self.nextSeq,
          limit: 30,
          sortOrder: "DESC")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (data) in
          if let nextSeq = data["next"] {
            self?.nextSeq = nextSeq as! String
          }
          subscribe.onNext(.messageLoaded)
          mainStore.dispatch(GetMessages(payload: data))
        }, onError: { [weak self] error in
          self?.isFetching = false
          subscribe.onError(error)
        }, onCompleted: { [weak self] in
          self?.isFetching = false
          subscribe.onCompleted()
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func fetchChat() -> Observable<CHUserChat?> {
    return Observable.create { [weak self] (subscriber) in
      self?.nextSeq = ""
      let signal = CHUserChat
        .get(userChatId: self?.userChatId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chatResponse) in
          mainStore.dispatch(GetUserChat(payload: chatResponse))
          self?.userChat = userChatSelector(
            state: mainStore.state,
            userChatId: chatResponse.userChat?.id)
          self?.userChatId = self?.userChat?.id ?? ""
          subscriber.onNext(self?.userChat)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func send(message: CHMessage?) -> Observable<CHMessage?> {
    guard var message = message else {
      return .empty()
    }
    
    return Observable.create { [weak self] (subscriber) in
      let signal = message
        .send()
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while sending message. Attempting to send again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (updated) in
          dlog("Message has been sent successfully")
          self?.sendTyping(isStop: true)
          subscriber.onNext(updated)
          subscriber.onCompleted()
        }, onError: { (error) in
          dlog("Message has been failed to send")
          self?.sendTyping(isStop: true)
          message.state = .Failed
          mainStore.dispatch(CreateMessage(payload: message))
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func sendMessageRecursively(allMessages: [CHMessage], currentIndex: Int) {
    var message = allMessages.get(index: currentIndex)
    
    message?
      .send()
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while sending message. Attempting to send again")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (updated) in
        message?.state = .Sent
        mainStore.dispatch(CreateMessage(payload: updated))
        self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
      }, onError: { [weak self] (error) in
        message?.state = .Failed
        mainStore.dispatch(CreateMessage(payload: message))
        self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
      }).disposed(by: self.disposeBag)
  }
  
  func delete(message: CHMessage?) {
    guard let message = message else { return }
    mainStore.dispatch(DeleteMessage(payload: message))
  }
  
  func translate(for message: CHMessage) -> Observable<String?> {
    guard let language = CHUtils.getLocale()?.rawValue else {
      return .just(nil)
    }
    
    return Observable.create { (subscriber) in
      let signal =  message
        .translate(to: language)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (text) in
          subscriber.onNext(text)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func updateProfileItem(with message: CHMessage, key: String, value: Any) -> Observable<CHMessage> {
    return Observable.create { (subscriber) in
      let signal = message
        .updateProfile(with: key, value: value)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (message) in
          subscriber.onNext(message)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func sendTyping(isStop: Bool) {
    WsService.shared.sendTyping(chat: self.userChat, isStop: isStop)
  }
}

extension UserChatInteractor: StoreSubscriber {
  func newState(state: ChatState) {
    let messages = messagesSelector(state: mainStore.state, userChatId: self.userChatId)
    self.userChat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
    let channel = mainStore.state.channel
    self.presenter?.updateMessages(
      with: messages,
      userChat: self.userChat,
      channel: channel)
    self.showErrorIfNeeded()
  }
  
  private func showErrorIfNeeded() {
    let socketState = mainStore.state.socketState.state
    if socketState == .reconnecting {
      self.presenter?.handleError(
        with: nil,
        visible: false,
        state: .waitingSocket)
    } else if socketState == .disconnected {
      self.presenter?.handleError(
        with: CHAssets.localized("ch.toast.unstable_internet"),
        visible: true,
        state: .socketDisconnected)
    }
  }
}

extension UserChatInteractor {
  func createNudgeChat(nudgeId:String?) -> Observable<CHUserChat?> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      guard let nudgeId = nudgeId else {
        subscriber.onError(CHErrorPool.paramError)
        return Disposables.create()
      }
      
      if let chatId = self?.userChatId,
        chatId != "",
        !chatId.hasPrefix(CHConstants.nudgeChat) {
        subscriber.onNext(
          userChatSelector(state: mainStore.state, userChatId: chatId)
        )
        return Disposables.create()
      }
      
      let signal = CHNudge
        .createChat(nudgeId: nudgeId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chatResponse) in
          mainStore.dispatch(GetNudgeChat(nudgeId: nudgeId, payload: chatResponse))
          subscriber.onNext(
            userChatSelector(state: mainStore.state, userChatId: chatResponse.userChat?.id)
          )
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
    
  func createSupportBotChatIfNeeded(originId: String? = nil) -> Observable<(CHUserChat?, CHMessage?)> {
    return Observable.create { [weak self] (subscriber) -> Disposable in
      var disposable: Disposable?
      if let chat = self?.userChat, let message = messageSelector(state: mainStore.state, id: originId) {
        subscriber.onNext((chat, message))
        subscriber.onCompleted()
      } else if let bot = mainStore.state.botsState.findSupportBot() {
        disposable = CHSupportBot
          .create(with: bot.id)
          .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
            dlog("Error while creating a chat. Attempting to create again")
            return true
          })
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (chatResponse) in
            guard let chatId = chatResponse.userChat?.id else { return }
            mainStore.dispatch(GetUserChat(payload: chatResponse))
            self?.userChatId = chatId
            subscriber.onNext((chatResponse.userChat, chatResponse.message))
            subscriber.onCompleted()
          }, onError: { (error) in
            subscriber.onError(error)
          })
      } else {
        subscriber.onError(CHErrorPool.unknownError)
      }
      
      return Disposables.create {
        disposable?.dispose()
      }
    }
  }
    
  func createChat() -> Observable<CHUserChat?> {
    return Observable.create { [weak self] (subscriber) in
      if let userChat = self?.userChat {
        subscriber.onNext(userChat)
        return Disposables.create()
      }
      let pluginId = mainStore.state.plugin.id
      
      let signal = CHUserChat
        .create(pluginId: pluginId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chatResponse) in
          mainStore.dispatch(GetUserChat(payload: chatResponse))
          self?.userChat = userChatSelector(
            state: mainStore.state,
            userChatId: chatResponse.userChat?.id)
          self?.userChatId = self?.userChat?.id ?? ""
          subscriber.onNext(self?.userChat)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
}
