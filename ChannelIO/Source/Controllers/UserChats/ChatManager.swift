//
//  ChatManager.swift
//  CHPlugin
//
//  Created by Haeun Chung on 12/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CHSlackTextViewController

enum ChatElement {
  case photos(obj: [String])
  case messages(obj: [CHMessage])
  case manager(obj: CHManager?)
  case session(obj: CHSession?)
  case chat(obj: CHUserChat?)
  case typing(obj: [CHEntity]?, animated: Bool)
  case profile(obj: CHMessage)
}

protocol ChatDelegate : class {
  func readyToDisplay()
  func update(for element: ChatElement)
  func updateInputBar(state: SLKInputBarState)
  func showError()
  func hideError()
}

class ChatManager {
  var chatId = ""
  var chatType = ""
  var chat: CHUserChat? = nil {
    didSet {
      if let chat = self.chat {
        self.chatId = chat.id
        self.chatType = "UserChat"
      }
    }
  }
  
  var didFetchInfo = false
  var didChatLoaded = false
  var didLoad = false
  var state: ChatState = .idle
  var shouldRedrawProfileBot = true
  var profileIsFocus = false
  
  let disposeBag = DisposeBag()

  fileprivate var welcomedAt = Date()
  fileprivate var typingPersons = [CHEntity]()
  fileprivate var timeStorage = [String: Timer]()
  fileprivate var animateTyping = false
  fileprivate var isFetching = false
  fileprivate var isRequstingReadAll = false
  fileprivate var nextSeq = ""
  
  fileprivate var messageDispose: Disposable?
  fileprivate var typingDispose: Disposable?
  
  var typers: [CHEntity] {
    get {
      return self.typingPersons
    }
  }
  
  weak var delegate: ChatDelegate? = nil
  
  deinit {
    dlog("Destroyed chatManager")
  }
  
  init(id: String?, type: String = "UserChat"){
    self.chatId = id ?? ""
    self.chatType = type
    self.chat = userChatSelector(
      state: mainStore.state,
      userChatId: id)
    
    self.observeAppState()
  }
  
  fileprivate func observeSocketEvents() {
    self.observeMessageEvents()
    self.observeChatEvents()
    self.observeSessionEvents()
    self.observeTypingEvents()
  }
  
  fileprivate func disposeSignals() {
    self.messageDispose?.dispose()
    self.typingDispose?.dispose()
  }
  
  fileprivate func observeAppState() {
    NotificationCenter.default
      .rx.notification(Notification.Name.UIApplicationWillEnterForeground)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.willAppear()
      }.disposed(by: self.disposeBag)
    
    NotificationCenter.default
      .rx.notification(Notification.Name.UIApplicationWillResignActive)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.willDisappear()
      }.disposed(by: self.disposeBag)
  }
  
  fileprivate func observeMessageEvents() {
    self.messageDispose = WsService.shared.mOnCreate()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (message) in
        let typing = CHTypingEntity.transform(from: message)
        if let index = self?.getTypingIndex(of: typing) {
          let person = self?.typingPersons.remove(at: index)
          self?.removeTimer(with: person)
          self?.delegate?.update(for: .typing(obj: self?.typingPersons ?? [], animated: self?.animateTyping ?? false))
        }
        self?.shouldRedrawProfileBot = true
//        let messages = messagesSelector(state: mainStore.state, userChatId: s.chatId)
//        s.delegate?.updateFor(element: .messages(obj: messages))
      })
  }
  
  fileprivate func observeChatEvents() { }
  fileprivate func observeSessionEvents() {
    _ = WsService.shared.joined()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chatId) in
      if self?.chatId == "" {
        self?.didFetchInfo = false
      }
      self?.didChatLoaded = false
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
          if let typer = personSelector(
            state: mainStore.state,
            personType: typingEntity.personType ?? "",
            personId: typingEntity.personId) {
            if self?.getTypingIndex(of: typingEntity) == nil {
              self?.typingPersons.append(typer)
            }
            self?.addTimer(with: typer, delay: 15)
          }
        }

        self?.delegate?.update(for: .typing(obj: self?.typingPersons ?? [], animated: self?.animateTyping ?? false))
      })
  }
}

// MARK: live typing

extension ChatManager {
  public func sendTyping(isStop: Bool) {
    WsService.shared.sendTyping(
      chat: self.chat,
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
      self.delegate?.update(for: .typing(obj: self.typingPersons, animated: self.animateTyping))
    }
  }
  
  fileprivate func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.index(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
  }
}

extension ChatManager {
  func sendMessage(userChatId: String, text: String) -> Observable<CHMessage?> {
    return Observable.create({ (subscriber) in
      let me = mainStore.state.guest
      var message = CHMessage(chatId: userChatId, guest: me, message: text)
      
      mainStore.dispatch(CreateMessage(payload: message))
      //self.scrollToBottom(false)
      
      let signal = message.send().subscribe(onNext: { [weak self] (updated) in
        dlog("Message has been sent successfully")
        self?.sendTyping(isStop: true)
        mainStore.dispatch(CreateMessage(payload: updated))
        subscriber.onNext(updated)
      }, onError: { (error) in
        dlog("Message has been failed to send")
        message.state = .Failed
        mainStore.dispatch(CreateMessage(payload: message))
        subscriber.onNext(message)
      })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func sendMessageRecursively(allMessages: [CHMessage], currentIndex: Int, requestBot: Bool = false) {
    var message = allMessages.get(index: currentIndex)
    if message == nil && requestBot {
      _ = PluginPromise.requestProfileBot(pluginId: mainStore.state.plugin.id, chatId: self.chatId)
        .subscribe(onNext: { (_) in
        
      })
    }
    
    message?.send().subscribe(onNext: { [weak self] (updated) in
      message?.state = .Sent
      mainStore.dispatch(CreateMessage(payload: updated))
      self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
    }, onError: { [weak self] (error) in
      message?.state = .Failed
      mainStore.dispatch(CreateMessage(payload: message!))
      self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
    }).disposed(by: self.disposeBag)
  }
  
  func profileIsFocus(focus: Bool) {
    self.profileIsFocus = focus
    if focus {
      self.delegate?.updateInputBar(state: .disabled)
    } else {
      self.delegate?.updateInputBar(state: .normal)
    }
  }
}

extension ChatManager {
  func isChatReady() -> Bool {
    return self.state == .chatReady
  }
  
  func isNewUserChat() -> Bool {
    return self.chatId == ""
  }
  
  func needToFetchInfo() -> Bool {
    return !self.didFetchInfo && self.chatId == "" && self.state != .infoLoading
  }
  
  func needToFetchChat() -> Bool {
    return !self.didChatLoaded && self.chatId != "" && self.state != .chatLoading
  }
  
  func isChatLoading() -> Bool {
    return self.state == .chatLoading
  }
  
  func isMessageLoading() -> Bool {
    return self.state == .messageLoading
  }
  
  func canLoadMore() -> Bool {
    return self.nextSeq != "" && self.chatId != "" && self.chatType != ""
  }
}

// MARK: APIs

extension ChatManager {
  //NOTE: not considered simultaneous calling of difference fetching functions
  
  func fetchChat() -> Observable<ChatResponse> {
    return Observable.create { [weak self] subscriber in
      guard self?.state != .chatLoading else { return Disposables.create() }
      guard let s = self else  { return Disposables.create() }
      self?.state = .chatLoading
      self?.nextSeq = ""
      
      let signal = CHUserChat.get(userChatId: s.chatId)
        .subscribe(onNext: { (response) in
          self?.didChatLoaded = true
          //due to message update step were not desirable
          var response = response
          response.message = nil
          mainStore.dispatch(GetUserChat(payload: response))
        
          self?.chat = userChatSelector(state: mainStore.state, userChatId: s.chatId)
          subscriber.onNext(response)
          subscriber.onCompleted()
          self?.state = .chatLoaded
        }, onError: { (error) in
          self?.state = .chatNotLoaded
          self?.didChatLoaded = false
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func createChat(pluginId:String = "") -> Observable<String> {
    return Observable.create({ [weak self] (subscriber) in
      if let chatId = self?.chatId, chatId != "" {
        subscriber.onNext(chatId)
        return Disposables.create()
      }
      
      var pluginId = pluginId
      if pluginId == "" {
        pluginId = mainStore.state.plugin.id
      }
      
      let signal = CHUserChat.create(
        pluginId: pluginId,
        timeStamp: self?.welcomedAt)
        .subscribe(onNext: { (chatResponse) in
          guard let userChat = chatResponse.userChat,
            let session = chatResponse.session else { return }
          mainStore.dispatch(CreateSession(payload: session))
          mainStore.dispatch(CreateUserChat(payload: userChat))
          WsService.shared.join(chatId: userChat.id)
          
          self?.didChatLoaded = true
          self?.chatId = userChat.id
          
          subscriber.onNext(userChat.id)
          subscriber.onCompleted()
        }, onError: { [weak self] (error) in
          self?.didChatLoaded = false
          self?.state = .chatNotLoaded
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func requestProfileBot(chatId: String?) -> Observable<Bool?> {
    return PluginPromise.requestProfileBot(pluginId: mainStore.state.plugin.id, chatId: chatId)
  }
  
  func resetUserChat() -> Observable<String?> {
    return Observable.create({ [weak self] (subscribe) in
      //guard let s = self else { return Disposables.create() }
      self?.nextSeq = ""
      var signal: Disposable?
      
      if let chatId = self?.chatId, chatId != "" {
        signal = self?.fetchChat().subscribe(onNext: { _ in
          mainStore.dispatch(RemoveMessages(payload: chatId))
          subscribe.onNext(chatId)
        }, onError: { error in
          subscribe.onError(error)
        })
      } else {
        signal = self?.createChat().subscribe(onNext: { chatId in
          subscribe.onNext(chatId)
        }, onError: { error in
          subscribe.onError(error)
        })
      }
      
      return Disposables.create {
        signal?.dispose()
      }
    })
  }
  
  func fetchMessages() {
    if self.isFetching {
      return
    }
    
    // TODO: show loader
    self.isFetching = true
    CHMessage.getMessages(userChatId: self.chatId,
      since: self.nextSeq,
      limit: 30,
      sortOrder: "DESC").subscribe(onNext: { [weak self] (data) in
        if let nextSeq = data["next"] {
          self?.nextSeq = nextSeq as! String
        }
        self?.state = .messageLoaded
        mainStore.dispatch(GetMessages(payload: data))
      }, onError: { [weak self] error in
        // TODO: show error
        self?.isFetching = false
        self?.state = .messageNotLoaded
        self?.delegate?.showError()
      }, onCompleted: { [weak self] in
        self?.isFetching = false
        if self?.didLoad == false {
          self?.didLoad = true
          self?.state = .chatReady
          self?.delegate?.readyToDisplay()
          self?.requestReadAll()
        }
      }).disposed(by: self.disposeBag)
  }
  
  func requestReadAll() {
    guard !self.isRequstingReadAll else { return }
    
    if self.chat?.session == nil {
      return
    }
    
    if self.chat?.session?.unread == 0 &&
      self.chat?.session?.alert == 0 {
      return
    }
    
    self.isRequstingReadAll = true
    
    self.chat?.readAll().subscribe(onNext: { [weak self] (completed) in
      self?.isRequstingReadAll = false
    }).disposed(by: self.disposeBag)
  }
  
  func getPlugin() -> Observable<(CHPlugin, CHBot?)> {
    return PluginPromise.getPlugin(pluginId: mainStore.state.plugin.id)
  }
  
  func updateProfileItem(with message: CHMessage?, key: String?, value: Any?) -> Observable<Bool> {
    return Observable.create({ (subscriber) in
      guard let message = message else {
        subscriber.onNext(false)
        return Disposables.create()
      }
      guard let key = key, let value = value else {
        subscriber.onNext(false)
        return Disposables.create()
      }
      
      message.updateProfile(with: key, value: value)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (message) in
          self?.shouldRedrawProfileBot = true
          self?.delegate?.update(for: .profile(obj: message))
          mainStore.dispatch(UpdateMessage(payload: message))
          subscriber.onNext(true)
        }, onError: { (error) in
          subscriber.onNext(false)
        }).disposed(by: self.disposeBag)
      return Disposables.create()
    })

  }
}

extension ChatManager {
  func willAppear() {
    self.state = .chatJoining
    self.observeSocketEvents()
    WsService.shared.join(chatId: self.chatId)
  }
  
  func willDisappear() {
    self.sendTyping(isStop: true)
    self.requestReadAll()
    self.disposeSignals()
    WsService.shared.leave(chatId: self.chatId)
  }

  func hasNewMessage(current: [CHMessage], updated: [CHMessage]) -> Bool {
    let currentCount = current.count
    let updatedCount = updated.count
    
    if updatedCount == 0 {
      return false
    }
    
    if currentCount == 0 && updatedCount != 0 {
      return true
    }
    
    if updatedCount < currentCount {
      return false
    }
    
    if updatedCount > currentCount {
      let updatedLast = updated.first!
      let currLast = current.first!
      
      if updatedLast.createdAt > currLast.createdAt {
        return true
      }
    }
    
    return false
  }
}

extension ChatManager {
  func didClickOnRetry(for message: CHMessage?) {
    guard let message = message else { return }
    
    let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
    
    alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.delete"), style: .destructive) {  _ in
      mainStore.dispatch(DeleteMessage(payload: message))
    })
    
    alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.retry_sending_message"), style: .default) { [weak self] _ in
      message.send().subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }).disposed(by: (self?.disposeBag)!)
    })

    alertView.addAction(UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in
      // no action
    })
    
    CHUtils.getTopController()?.present(alertView, animated: true, completion: nil)
  }
}
