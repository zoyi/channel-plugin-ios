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
import CHPhotoBrowser
import DKImagePickerController

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
  
  var shouldShowUserGuide = false
  var didFetchInfo = false
  var didChatLoaded = false
  var didLoad = false
  var state: ChatState = .idle
  
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
  
  init(userChatId: String) {
    self.userChatId = userChatId
    self.shouldShowUserGuide = (mainStore.state.guest.ghost == true ||
      mainStore.state.guest.mobileNumber == nil) &&
      mainStore.state.channel.requestGuestInfo
  }
  
  func subscribeDataSource() {
    mainStore.subscribe(self)
    self.observeAppState()
    self.observeChatEvents()
    self.observeTypingEvents()
    self.observeMessageEvents()
    self.observeSessionEvents()
    self.joinSocket()
  }
  
  func unsunbscribeDataSource() {
    mainStore.unsubscribe(self)
    self.messageDispose?.dispose()
    self.typingDispose?.dispose()
    self.notiDispose?.dispose()
    self.chatDispose?.dispose()
    self.eventDispose?.dispose()
    self.leaveSocket()
  }
  
  func refreshUserChat() {
    
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
    self.notiDispose = NotificationCenter.default
      .rx.notification(Notification.Name.UIApplicationWillEnterForeground)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        if self?.userChatId == "" {
          self?.didFetchInfo = false
        }
        self?.didChatLoaded = false
      }
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
          self?.chatEventSubject.onNext(.typing(obj: self?.typingPersons, animated: self?.animateTyping ?? false))
        }
        let messages = messagesSelector(state: mainStore.state, userChatId: self?.userChatId)
        self?.chatEventSubject.onNext(.messages(obj: messages, next: self?.nextSeq ?? ""))
      })
  }
  
  fileprivate func observeChatEvents() {
    self.chatDispose = WsService.shared.eventSubject
      .takeUntil(self.rx.deallocated)
      .filter({ (type, data) -> Bool in
        return type == WsServiceType.CreateUserChat ||
          type == WsServiceType.UpdateUserChat
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (type, data) in
        let chat = userChatSelector(state: mainStore.state, userChatId: self?.userChatId)
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
        self?.chatEventSubject.onNext(.typing(obj: self?.typingPersons, animated: self?.animateTyping ?? false))
      })
  }
}

//API
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
      sortOrder: "DESC").subscribe(onNext: { [weak self] (data) in
        if let nextSeq = data["next"] {
          self?.nextSeq = nextSeq as! String
        }
        self?.state = .messageLoaded
        mainStore.dispatch(GetMessages(payload: data))
        self?.updateMessages()
      }, onError: { [weak self] error in
        // TODO: show error
        self?.isFetching = false
        self?.state = .messageNotLoaded
        self?.chatEventSubject.onNext(.error(obj: error))
      }, onCompleted: { [weak self] in
        self?.isFetching = false
        if self?.didLoad == false {
          self?.didLoad = true
          self?.state = .chatReady
          //self?.delegate?.readyToDisplay()
          self?.requestReadAll()
        }
      }).disposed(by: self.disposeBag)
  }
  
  func fetchChat() -> Observable<CHUserChat> {
    return Observable.create({ (subscriber) in
      return Disposables.create()
    })
  }
  
  func createChat() -> Observable<CHUserChat> {
    return Observable.create({ (subscriber) in
      return Disposables.create()
    })
  }
  
  func requestReadAll() {
    guard !self.isRequstingReadAll else { return }
    
    if self.userChat?.session == nil {
      return
    }
    
    if self.userChat?.session?.unread == 0 &&
      self.userChat?.session?.alert == 0 {
      return
    }
    
    self.isRequstingReadAll = true
    
    self.userChat?.readAll()
      .subscribe(onNext: { [weak self] _ in
        self?.isRequstingReadAll = false
        self?.readAllManually()
      }).disposed(by: self.disposeBag)
  }
  
  func readAllManually() {
    guard var session = self.userChat?.session else { return }
    session.unread = 0
    session.alert = 0
    mainStore.dispatch(UpdateSession(payload: session))
  }
  
  func send(text: String, assets: [DKAsset])  {
    let me = mainStore.state.guest
    var message = CHMessage(chatId: self.userChatId, guest: me, message: text)
    
    mainStore.dispatch(CreateMessage(payload: message))
    self.updateMessages()
    
    message.send().subscribe(onNext: { [weak self] (updated) in
      dlog("Message has been sent successfully")
      self?.sendTyping(isStop: true)
      mainStore.dispatch(CreateMessage(payload: updated))
      self?.updateMessages()
      self?.showUserInfoGuideIfNeeded()
    }, onError: { [weak self] (error) in
      dlog("Message has been failed to send")
      message.state = .Failed
      mainStore.dispatch(CreateMessage(payload: message))
      self?.updateMessages()
    }).disposed(by: self.disposeBag)

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
    self.userChat?.feedback(rating: rating)
      .observeOn(MainScheduler.instance)
      .subscribe (onNext: { (response) in
        mainStore.dispatch(GetUserChat(payload: response))
        let chat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
        self.chatEventSubject.onNext(.chat(obj: chat))
      }).disposed(by: self.disposeBag)
  }
}

//custom dialogs
extension UserChatInteractor {
  func showUserInfoGuideIfNeeded() {
    if self.shouldShowUserGuide && self.userChat != nil {
      self.shouldShowUserGuide = false
      dispatch(delay: 1.0, execute: { [weak self] in
        mainStore.dispatch(
          CreateUserInfoGuide(payload: ["userChat": self?.userChat])
        )
        self?.updateMessages()
      })
    }
  }
}

//
extension UserChatInteractor: StoreSubscriber {
  func newState(state: AppState) {
    
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
    WsService.shared.sendTyping(
      chat: self.userChat,
      isStop: isStop
    )
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
    if let index = self.typingPersons.index(where: { (p) in
      return p.id == person.id && p.kind == person.kind
    }) {
      self.typingPersons.remove(at: index)
      self.timeStorage.removeValue(forKey: person.key)
      self.chatEventSubject.onNext(.typing(obj: nil, animated: self.animateTyping))
    }
  }
  
  fileprivate func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.index(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
  }
}


extension UserChatInteractor: MWPhotoBrowserDelegate {
  func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(self.photoUrls.count)
  }
  
  func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
    return MWPhoto(url: self.photoUrls[Int(index)] as URL)
  }
}

