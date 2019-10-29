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
  var presenter: UserChatPresenterProtocol?
  var photoUrls: [URL] {
    get {
      let messages = messagesSelector(state: mainStore.state, userChatId: self.userChatId)
      return messages.reversed().filter({
        $0.file?.isPreviewable == true
      }).map({ (message) in
        return (message.file?.fileUrl)!
      })
    }
  }

  var userChatId: String = ""
  var userChat: CHUserChat? = nil
  
  var didFetchInfo = false
  var didChatLoaded = false
  var didLoad = false
  
  fileprivate var typingPersons = [CHEntity]()
  fileprivate var timeStorage = [String: Timer]()
  fileprivate var animateTyping = false
  fileprivate var isFetching = false
  fileprivate var isRequstingReadAll = false
  fileprivate var nextSeq = ""
  
  fileprivate var messageDispose: Disposable?
  fileprivate var typingDispose: Disposable?
  fileprivate var notiDispose: Disposable?
  fileprivate var chatDispose: Disposable?
  fileprivate var eventDispose: Disposable?
  fileprivate var joinDispose: Disposable?
  
  var typingSubject = PublishSubject<([CHEntity], Bool)>()
  var chatEventSubject = PublishSubject<ChatEvent>()
  var sendSubject = PublishSubject<CHMessage>()
  
  var disposeBag = DisposeBag()
  
  var shouldFetchChat: Bool {
    return self.didFetchInfo == false || self.didLoad == false
  }
  
  var shouldRefreshChat: Bool {
    return false
  }
  
  deinit {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
  }
  
  init(userChatId: String = "") {
    super.init()
    
    self.userChatId = userChatId
    self.observeAppState()
  }
  
  func willAppear() {
    self.chatEventSubject.onNext(.state(.chatJoining))
    self.subscribeDataSource()
    self.joinSocket()
  }
  
  func willDisppear() {
    self.sendTyping(isStop: true)
    self.unsunbscribeDataSource()
    self.leaveSocket()
  }
  
  func subscribeDataSource() {
    mainStore.subscribe(self)
    self.observeChatEvents()
    self.observeTypingEvents()
    self.observeMessageEvents()
    self.observeSessionEvents()
  }
  
  func unsunbscribeDataSource() {
    mainStore.unsubscribe(self)
    self.messageDispose?.dispose()
    self.typingDispose?.dispose()
    self.notiDispose?.dispose()
    self.chatDispose?.dispose()
    self.eventDispose?.dispose()
    self.joinDispose?.dispose()
  }
  
  func refreshUserChat() {
    
  }
  
  func readyToPresent() -> Observable<Bool> {
    return Observable.create({ (subscriber) in
      let signal = Observable.zip(CHPlugin.get(with: mainStore.state.plugin.id), AppManager.getOperators())
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (info, managers) in
          mainStore.dispatch(UpdateFollowingManagers(payload: managers))
          mainStore.dispatch(GetPlugin(plugin: info.0, bot: info.1))
          
          dlog("ready to present")
          
          subscriber.onNext(true)
          subscriber.onCompleted()
        }, onError: { error in
          subscriber.onError(error)
          dlog("error getting following managers: \(error.localizedDescription)")
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func joinSocket() {
    WsService.shared.join(chatId: self.userChatId)
  }
  
  func leaveSocket() {
    WsService.shared.leave(chatId: self.userChatId)
  }
}

extension UserChatInteractor {
  func observeAppState() {
    NotificationCenter.default
      .rx.notification(UIApplication.willEnterForegroundNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.willAppear()
      }.disposed(by: self.disposeBag)
    
    NotificationCenter.default
      .rx.notification(UIApplication.willResignActiveNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.willDisppear()
      }.disposed(by: self.disposeBag)
  }
  
  fileprivate func observeMessageEvents() {
    self.messageDispose = WsService.shared.eventSubject
      .takeUntil(self.rx.deallocated)
      .filter({ (type, data)  in
        return type == WsServiceType.CreateMessage
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (type, data) in
        guard let message = data as? CHMessage else { return }
        let typing = CHTypingEntity.transform(from: message)
        if let index = self?.getTypingIndex(of: typing) {
          let person = self?.typingPersons.remove(at: index)
          self?.removeTimer(with: person)
          self?.chatEventSubject.onNext(.typing(obj: self?.typingPersons ?? [], animated: self?.animateTyping ?? false))
        }
        let messages = messagesSelector(state: mainStore.state, userChatId: self?.userChatId)
        self?.chatEventSubject.onNext(.messages(obj: messages, next: self?.nextSeq ?? ""))
      })
  }
  
  fileprivate func observeChatEvents() {
    self.joinDispose = WsService.shared.joined()
      .subscribe(onNext: { (chatId) in
        //reload chat
        //reload messages
      })
    
    self.chatDispose = WsService.shared.eventSubject
      .takeUntil(self.rx.deallocated)
      .filter({ (type, data) -> Bool in
        return type == WsServiceType.CreateUserChat ||
          type == WsServiceType.UpdateUserChat
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (type, data) in
        let chat = userChatSelector(state: mainStore.state, userChatId: self?.userChatId)
        if let chat = chat, let prevChat = self?.userChat, chat.updatedAt != prevChat.updatedAt {
          self?.requestRead()
        }
        self?.chatEventSubject.onNext(.chat(obj: chat))
      })
  }
  
  fileprivate func observeSessionEvents() {
    self.eventDispose = WsService.shared.eventSubject
      .takeUntil(self.rx.deallocated)
      .filter({ (type, data) -> Bool in
        return type == WsServiceType.CreateSession ||
          type == WsServiceType.UpdateSession ||
          type == WsServiceType.DeleteSession
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] session in
        let chat = userChatSelector(state: mainStore.state, userChatId: self?.userChatId)
        self?.chatEventSubject.onNext(.chat(obj: chat))
      })
  }
  
  fileprivate func observeTypingEvents() {
    self.typingDispose = WsService.shared.typingSubject
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (typingEntity) in
        if typingEntity.action == "stop" {
          if let index = self?.getTypingIndex(of: typingEntity) {
            let person = self?.typingPersons.remove(at: index)
            self?.removeTimer(with: person)
          }
        }
        else if typingEntity.action == "start" {
          if let manager = personSelector(
            state: mainStore.state,
            personType: typingEntity.personType ?? "",
            personId: typingEntity.personId) as? CHManager {
            if self?.getTypingIndex(of: typingEntity) == nil {
              self?.typingPersons.append(manager)
            }
            self?.addTimer(with: manager, delay: 15)
          }
        }
        self?.chatEventSubject.onNext(
          .typing(
            obj: self?.typingPersons ?? [],
            animated: self?.animateTyping ?? false
          ))
      })
  }
}

extension UserChatInteractor {
  func chatEventSignal() -> Observable<ChatEvent> {
    return self.chatEventSubject
  }
  
  func canLoadMore() -> Bool {
    return self.nextSeq != "" && self.userChatId != ""
  }
  
  func fetchMessages() {
    if self.isFetching {
      return
    }
    
    // TODO: show loader
    self.isFetching = true
    CHMessage.getMessages(
      userChatId: self.userChatId,
      since: self.nextSeq,
      limit: 30,
      sortOrder: "DESC")
      .subscribe(onNext: { [weak self] (data) in
        //move to presenter
        if let nextSeq = data["next"] {
          self?.nextSeq = nextSeq as! String
        }
        self?.chatEventSubject.onNext(.state(.messageLoaded))
        mainStore.dispatch(GetMessages(payload: data))
        self?.updateMessages()
      }, onError: { [weak self] error in
        // TODO: show error
        self?.isFetching = false
        if self?.didLoad == false {
          self?.chatEventSubject.onNext(.state(.messageNotLoaded))
        }
        self?.chatEventSubject.onNext(.error(obj: error))
      }, onCompleted: { [weak self] in
        self?.isFetching = false
        if self?.didLoad == false {
          self?.didLoad = true
          self?.chatEventSubject.onNext(.state(.chatReady))
        }
      }).disposed(by: self.disposeBag)
  }
  
  func fetchChat() -> Observable<CHUserChat?> {
    return Observable.create({ [weak self] (subscriber) in
      guard let self = self else {
        subscriber.onError(CHErrorPool.unknownError)
        return Disposables.create()
      }
      let signal = UserChatPromise.getChat(userChatId: self.userChatId)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chatResponse) in
          mainStore.dispatch(GetUserChat(payload: chatResponse))
          subscriber.onNext(chatResponse.userChat)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func requestRead() {
    guard !self.isRequstingReadAll else { return }
    self.isRequstingReadAll = true
    self.userChat?.read()
      .subscribe(onNext: { [weak self] (completed) in
      self?.isRequstingReadAll = false
    }, onError: { [weak self] (error) in
      self?.isRequstingReadAll = false
    }).disposed(by: self.disposeBag)
  }

  func send(text: String, assets: [PHAsset])  {
    let me = mainStore.state.user
    var message = CHMessage(chatId: self.userChatId, user: me, message: text)
    
    mainStore.dispatch(CreateMessage(payload: message))
    self.updateMessages()
    
    message.send().subscribe(onNext: { [weak self] (updated) in
      dlog("Message has been sent successfully")
      self?.sendTyping(isStop: true)
      mainStore.dispatch(CreateMessage(payload: updated))
      self?.updateMessages()
    }, onError: { [weak self] (error) in
      dlog("Message has been failed to send")
      message.state = .Failed
      mainStore.dispatch(CreateMessage(payload: message))
      self?.updateMessages()
    }).disposed(by: self.disposeBag)

  }
  
  func send(messages: [CHMessage]) -> Observable<Any?> {
    return Observable.create({ (subscribe) -> Disposable in
      return Disposables.create()
    })
  }
  
  func send(text: String, originId: String? = nil, key: String? = nil) -> Observable<CHMessage> {
    return Observable.create({ (subscribe) -> Disposable in
      return Disposables.create()
    })
  }
  
  func send(assets: [PHAsset]) -> Observable<[CHMessage]> {
    return Observable.create({ (subscribe) -> Disposable in
      return Disposables.create()
    })
  }
  
  func send(message: CHMessage?) -> Observable<CHMessage?> {
    return Observable.create({ (subscribe) -> Disposable in
      return Disposables.create()
    })
  }
  
  func send(message: CHMessage?) {
    guard let message = message else { return }
    message.send().subscribe(onNext: { (message) in
      mainStore.dispatch(CreateMessage(payload: message))
      self.updateMessages()
    }, onError: { [weak self] error in
      var failedMessage = message
      failedMessage.state = .Failed
      mainStore.dispatch(CreateMessage(payload: failedMessage))
      self?.updateMessages()
    }).disposed(by: self.disposeBag)
  }
  
  func delete(message: CHMessage?) {
    guard let message = message else { return }
    mainStore.dispatch(DeleteMessage(payload: message))
  }
  
  func translate(for message: CHMessage) {
    
  }
  
  func sendFeedback(rating: String) {
//    self.userChat?.feedback(rating: rating)
//      .observeOn(MainScheduler.instance)
//      .subscribe (onNext: { (response) in
//        mainStore.dispatch(GetUserChat(payload: response))
//        let chat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
//        self.chatEventSubject.onNext(.chat(obj: chat))
//      }).disposed(by: self.disposeBag)
  }
  
}


//
extension UserChatInteractor: StoreSubscriber {
  func newState(state: AppState) {
    //let messages = messagesSelector(state: state, userChatId: self.userChatId)
    //self.showNewMessageBannerIfNeeded(current: self.messages, updated: messages)
    
    //saved contentOffset
    //let offset = self.tableView.contentOffset
    //let hasNewMessage = self.chatManager.hasNewMessage(current: self.messages, updated: messages)
    
    //message only needs to be replace if count is differe
    //self.messages = messages
    //fixed contentOffset
    //self.tableView.layoutIfNeeded()
    
    // Photo - is this scalable? or doesn't need to care at this moment?
//    self.photoUrls = self.messages.reversed()
//      .filter({ $0.file?.isPreviewable == true })
//      .map({ (message) -> String in
//        return message.file?.url ?? ""
//      })
    
    //let userChat = userChatSelector(state: state, userChatId: self.userChatId)
    
    //self.updateNavigationIfNeeded(state: state, nextUserChat: userChat)
    //self.updateInputFieldIfNeeded(userChat: self.userChat, nextUserChat: userChat)
    //self.showFeedbackIfNeeded(userChat, lastMessage: messages.first)
    //self.fixedOffsetIfNeeded(previousOffset: offset, hasNewMessage: hasNewMessage)
    //self.showErrorIfNeeded(state: state)
    
    //self.fetchWelcomeInfoIfNeeded()
    //self.fetchChatIfNeeded()
    
    //self.userChat = userChat
    //self.chatManager.chat = userChat
    //self.channel = state.channel
    self.showErrorIfNeeded(state: state)
  }
  
  func showErrorIfNeeded(state: AppState) {
    let socketState = state.socketState.state

    if socketState == .reconnecting {
      self.chatEventSubject.onNext(.state(.waitingSocket))
    } else if socketState == .disconnected {
      self.chatEventSubject.onNext(.error(obj: nil))
      //self.showError()
    } else {
      //self.hideError()
    }
  }
  
  func updateMessages() {
    let messages = messagesSelector(
      state: mainStore.state,
      userChatId: self.userChatId)
    self.chatEventSubject.onNext(.messages(obj: messages, next: self.nextSeq))
  }
}

extension UserChatInteractor {
  public func sendTyping(isStop: Bool) {
    WsService.shared.sendTyping(chat: self.userChat, isStop: isStop)
  }
  
  fileprivate func addTimer(with person: CHEntity, delay: TimeInterval) {
    let timer = Timer.scheduledTimer(
      timeInterval: delay,
      target: self,
      selector: #selector(self.expired(_:)),
      userInfo: [person],
      repeats: false
    )
    
    if let t = self.timeStorage[person.key] {
      t.invalidate()
    }
    
    self.timeStorage[person.key] = timer
  }
  
  fileprivate func removeTimer(with person: CHEntity?) {
    guard let person = person else { return }
    if let t = self.timeStorage.removeValue(forKey: person.key) {
      t.invalidate()
    }
  }
  
  public func reset() {
    self.timeStorage.forEach { (k, t) in
      t.invalidate()
    }
    self.typingPersons.removeAll()
    self.timeStorage.removeAll()
  }
  
  @objc fileprivate func expired(_ timer: Timer) {
    guard let params = timer.userInfo as? [Any] else { return }
    guard let person = params[0] as? CHEntity else { return }
    
    timer.invalidate()
    if let index = self.typingPersons.firstIndex(where: { (p) in
      return p.id == person.id && p.kind == person.kind
    }) {
      self.typingPersons.remove(at: index)
      self.timeStorage.removeValue(forKey: person.key)
      self.chatEventSubject.onNext(.typing(obj: self.typingPersons, animated: self.animateTyping))
    }
  }
  
  fileprivate func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.firstIndex(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
  }
}

extension UserChatInteractor {
  func createNudgeChat(nudgeId:String?) -> Observable<String> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      guard let nudgeId = nudgeId else {
        subscriber.onError(CHErrorPool.paramError)
        return Disposables.create()
      }
      if let chatId = self?.userChatId, chatId != "", !chatId.hasPrefix(CHConstants.nudgeChat) {
        subscriber.onNext(chatId)
        return Disposables.create()
      }
      //if push bot message is present, create push bot user chat
      let signal = CHNudge.createChat(nudgeId: nudgeId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chatResponse) in
          //replace local nudgeChat
          mainStore.dispatch(GetNudgeChat(nudgeId: nudgeId, payload: chatResponse))
          
//          self?.chatNewlyCreated = true
//          self?.didChatLoaded = true
//          self?.setChatEntities(with: chatResponse.userChat?.id)
//          self?.prepareToChat()
          
          subscriber.onNext(chatResponse.userChat?.id ?? "")
          subscriber.onCompleted()
        }, onError: { [weak self] (error) in
//          self?.didChatLoaded = false
//            self?.state = .chatNotLoaded
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
    
  func createSupportBotChatIfNeeded(originId: String? = nil) -> Observable<(CHUserChat?, CHMessage?)> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      var disposable: Disposable?
      if let chat = self?.userChat, let message = messageSelector(state: mainStore.state, id: originId) {
        subscriber.onNext((chat, message))
        subscriber.onCompleted()
      } else if let bot = mainStore.state.botsState.findSupportBot() {
        disposable = CHSupportBot.create(with: bot.id)
          .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
            dlog("Error while creating a chat. Attempting to create again")
            return true
          })
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { (chatResponse) in
            mainStore.dispatch(GetUserChat(payload: chatResponse))
            
//            self?.chatNewlyCreated = true
//            self?.didChatLoaded = true
//            self?.setChatEntities(with: chatResponse.userChat?.id)
//            self?.prepareToChat()
         
            subscriber.onNext((chatResponse.userChat, chatResponse.message))
            subscriber.onCompleted()
          }, onError: { [weak self] (error) in
//            self?.didChatLoaded = false
//              self?.state = .chatNotLoaded
            subscriber.onError(error)
          })
      } else {
        subscriber.onError(CHErrorPool.unknownError)
      }
      return Disposables.create {
        disposable?.dispose()
      }
    })
  }
    
  func createChat() -> Observable<CHUserChat?> {
    return Observable.create({ [weak self] (subscriber) in
      if let userChat = self?.userChat {
        subscriber.onNext(userChat)
        return Disposables.create()
      }
      let pluginId = mainStore.state.plugin.id
      
      //if push bot message is present, create push bot user chat
      let signal = CHUserChat.create(pluginId: pluginId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance).subscribe(onNext: { (chatResponse) in
          mainStore.dispatch(GetUserChat(payload: chatResponse))
          
//          self?.chatNewlyCreated = true
//          self?.didChatLoaded = true
//          self?.setChatEntities(with: chatResponse.userChat?.id)
//          self?.prepareToChat()
//
          subscriber.onNext(userChatSelector(
            state: mainStore.state,
            userChatId: chatResponse.userChat?.id
          ))
          subscriber.onCompleted()
        }, onError: { [weak self] (error) in
//          self?.didChatLoaded = false
//            self?.state = .chatNotLoaded
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
}
