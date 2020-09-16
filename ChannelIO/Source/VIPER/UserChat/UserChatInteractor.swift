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
  private let chatType: ChatType = .userChat
  
  var photoUrls: [URL] {
    let messages = messagesSelector(state: mainStore.state, userChatId: self.userChatId)
    return messages.reversed()
      .reduce([]) { $0 + $1.files }
      .filter { $0.type == .image }
      .compactMap { $0.url }
  }
  
  private var isFetching = false
  private var nextSeq: String?
  
  private let disposeBag = DisposeBag()
  private var queueKey: ChatQueueKey {
    return ChatQueueKey(chatType: self.chatType, chatId: self.userChatId)
  }
  
  func subscribeDataSource() {
    mainStore.subscribe(self) { subcription in
      subcription.select { state in state.chatState }
    }
  }
  
  func unsunbscribeDataSource() {
    mainStore.unsubscribe(self)
  }

  func readyToPresent() -> Observable<Bool> {
    guard
      let pluginKey = ChannelIO.bootConfig?.pluginKey,
      pluginKey != "" else {
      return .just(false)
    }
    
    return Observable.create { subscriber in
      let signal = CHPlugin
        .get(with: pluginKey)
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
    return self.nextSeq != nil
  }
  
  func upload(files: [CHFile]) -> Observable<ChatQueueKey> {
    return Observable
      .just(files.map {
        ChatFileQueueItem(
          channelId: mainStore.state.channel.id,
          type: self.chatType,
          chatId: self.userChatId,
          file: $0,
          completion: self.presenter?.sendFiles
        )
      })
      .flatMap { items in
        return Observable.combineLatest(items.map { $0.prepare() })
      }
      .flatMap { [weak self] items -> Observable<ChatQueueKey> in
        guard let self = self else {
          return .error(ChannelError.unknownError())
        }
        
        ChatQueueService.shared.enqueue(items: items)
        return .just(self.queueKey)
      }
  }
  
  func fetchMessages() -> Observable<ChatProcessState> {
    guard !self.isFetching else {
      return .just(.messageLoading)
    }
    
    return Observable.create { subscribe in
      self.isFetching = true
      let signal = CHUserChat
        .getMessages(
          userChatId: self.userChatId,
          since: self.nextSeq,
          limit: 30,
          sortOrder: "DESC")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (data) in
          self?.nextSeq = data["next"] as? String
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
    return Observable.create { [weak self] subscriber in
      self?.nextSeq = nil
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
      return .error(ChannelError.parameterError)
    }
    
    return Observable.create { [weak self] subscriber in
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
          message.state = .networkError
          mainStore.dispatch(CreateMessage(payload: message))
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func delete(message: CHMessage?) {
    guard let message = message else { return }
    mainStore.dispatch(DeleteMessage(payload: message))
  }
  
  func translate(for message: CHMessage) -> Observable<[CHMessageBlock]> {
    guard let language = CHUtils.getLocale()?.rawValue else {
      return .just([])
    }
    
    return Observable.create { (subscriber) in
      let signal =  message
        .translate(to: language)
        .subscribe(onNext: { blocks in
          subscriber.onNext(blocks)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func updateProfileItem(
    with message: CHMessage,
    key: String,
    type: ProfileSchemaType,
    value: Any
  ) -> Observable<CHMessage> {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    var param = value
    switch type {
    case .date:
      let date = value as? Date
      param = (date?.timeIntervalSince1970 ?? 0) * 1000
    default: break
    }
    
    return Observable.create { (subscriber) in
      let signal = message
        .updateProfile(with: key, value: param)
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
    } else {
      self.presenter?.handleError(with: nil, visible: false, state: nil)
    }
  }
}

extension UserChatInteractor {
  func createSupportBotChatIfNeeded(originId: String? = nil) -> Observable<(CHUserChat?, CHMessage?)> {
    return Observable.create { [weak self] subscriber in
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
          .subscribe(onNext: { chatResponse in
            guard let chatId = chatResponse.userChat?.id else { return }
            mainStore.dispatch(GetUserChat(payload: chatResponse))
            self?.userChatId = chatId
            subscriber.onNext((chatResponse.userChat, chatResponse.message))
            subscriber.onCompleted()
          }, onError: { error in
            subscriber.onError(error)
          })
      } else {
        subscriber.onError(ChannelError.unknownError())
      }
      
      return Disposables.create {
        disposable?.dispose()
      }
    }
  }
  
  func fetchMarketingSupportBot() -> Observable<String?> {
    return Observable.create { [weak self] subscriber in
      let signal = self?
        .userChat?
        .lastMessage?
        .marketing?
        .fetchSupportBot()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { supportBotEntryInfo in
          subscriber.onNext(supportBotEntryInfo.supportBot?.id ?? mainStore.state.botsState.findSupportBot()?.id)
          subscriber.onCompleted()
        }, onError: { error in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal?.dispose()
      }
    }
  }
  
  func startMarketingToSupportBot(with supportBotId: String?) -> Observable<CHMessage> {
    return Observable.create { [weak self] subscriber in
      let signal = CHSupportBot
        .startFromMarketing(
          userChatId: self?.userChat?.id,
          supportBotId: supportBotId
        )
        .retry(.delayed(maxCount: 3, time: 3.0))
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (message) in
          mainStore.dispatch(CreateMessage(payload: message))
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
  
  func createChatIfNeeded() -> Observable<CHUserChat?> {
    guard self.userChat == nil || self.userChat?.isActive == false else {
      return .just(self.userChat)
    }
    
    return Observable.create { [weak self] subscriber in
      if let userChat = self?.userChat {
        subscriber.onNext(userChat)
        return Disposables.create()
      }

      let signal = CHUserChat
        .create()
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
