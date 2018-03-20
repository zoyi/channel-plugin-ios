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

enum ChatElement {
  case messages(obj: [CHMessage])
  case manager(obj: CHManager?)
  case session(obj: CHSession?)
  case chat(obj: CHUserChat?)
  case typing(obj: [CHEntity]?, animated: Bool)
}

enum ChatState {
  case idle
  case infoNotLoaded
  case infoLoading
  case infoLoaded
  case chatLoading
  case chatLoaded
  case chatNotLoaded
  case chatJoining
  case waitingSocket
  case messageLoading
  case messageLoaded
  case messageNotLoaded
  case chatReady
}

protocol ChatDelegate : class {
  func readyToDisplay()
  func updateFor(element: ChatElement)
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
  fileprivate var notiDispose: Disposable?
  
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
    
    //self.observeSocketEvents()
  }
  
  fileprivate func observeSocketEvents() {
    self.observeMessageEvents()
    self.observeChatEvents()
    self.observeSessionEvents()
    self.observeTypingEvents()
    self.observeAppState()
  }
  
  fileprivate func disposeSignals() {
    self.messageDispose?.dispose()
    self.notiDispose?.dispose()
    self.typingDispose?.dispose()
  }
  
  fileprivate func observeAppState() {
    self.notiDispose = NotificationCenter.default
      .rx.notification(Notification.Name.UIApplicationWillEnterForeground)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        if self?.chatId == "" {
          self?.didFetchInfo = false
        }
        self?.didChatLoaded = false
      }
  }
  
  fileprivate func observeMessageEvents() {
    self.messageDispose = WsService.shared.mOnCreate()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (message) in
        let typing = CHTypingEntity.transform(from: message)
        if let index = self?.getTypingIndex(of: typing) {
          let person = self?.typingPersons.remove(at: index)
          self?.removeTimer(with: person)
          self?.delegate?.updateFor(element: .typing(obj: self?.typingPersons, animated: self?.animateTyping ?? false))
        }
        
//        let messages = messagesSelector(state: mainStore.state, userChatId: s.chatId)
//        s.delegate?.updateFor(element: .messages(obj: messages))
      })
  }
  
  fileprivate func observeChatEvents() { }
  fileprivate func observeSessionEvents() { }
  
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
        //reload row not section only if visible
        self?.delegate?.updateFor(element: .typing(obj: self?.typingPersons, animated: self?.animateTyping ?? false))
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
      self.delegate?.updateFor(element: .typing(obj: nil, animated: self.animateTyping))
    }
  }
  
  fileprivate func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.index(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
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
}

// MARK: APIs

extension ChatManager {
  //NOTE: not considered simultaneous calling of difference fetching functions
  func fetchForNewUserChat() -> Observable<Any?> {
    return Observable.create { [weak self] subscriber in
      guard let s = self else { return Disposables.create() }
      guard s.state != .infoLoading else { return Disposables.create() }
      
      s.state = .infoLoading
      
      let signal = s.getPlugin()
        .flatMap({ (plugin, bot) -> Observable<CHScript?> in
          mainStore.dispatchOnMain(GetPlugin(plugin: plugin, bot: bot))
          return s.getWelcomeScript()
        })
        .subscribe(onNext: { (script) in
          s.didFetchInfo = true
          s.state = .infoLoaded
          mainStore.dispatchOnMain(GetScript(payload: script))
          subscriber.onNext(nil)
        }, onError: { (error) in
          s.didFetchInfo = false
          s.state = .infoNotLoaded
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal.dispose()
      }
    }
  }
  
  func fetchChat() -> Observable<ChatResponse> {
    return Observable.create { [weak self] subscriber in
      guard self?.state != .chatLoading else { return Disposables.create() }
      guard let s = self else  { return Disposables.create() }
      self?.state = .chatLoading
      self?.nextSeq = ""
      
      let signal = CHUserChat.get(userChatId: s.chatId)
        .subscribe(onNext: { (response) in
          self?.didChatLoaded = true
          mainStore.dispatch(GetUserChat(payload: response))
        
          self?.chat = userChatSelector(state: mainStore.state, userChatId: s.chatId)
          subscriber.onNext(response)
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
  
  func createChat(pluginId:String = "", completion: @escaping (String?) -> Void) {
    if self.chatId != "" {
      completion(self.chatId)
      return;
    }

    var pluginId = pluginId
    if pluginId == "" {
      pluginId = mainStore.state.plugin.id
    }
    
    CHUserChat.create(
      pluginId: pluginId,
      timeStamp: self.welcomedAt)
      .subscribe(onNext: { [weak self] (chatResponse) in
        guard let userChat = chatResponse.userChat,
          let session = chatResponse.session else { return }
        mainStore.dispatch(CreateSession(payload: session))
        mainStore.dispatch(CreateUserChat(payload: userChat))
        WsService.shared.join(chatId: userChat.id)
        
        self?.didChatLoaded = true
        self?.chatId = userChat.id

        completion(userChat.id)
      }, onError: { [weak self] (error) in
        self?.didChatLoaded = false
        self?.state = .chatNotLoaded
        completion(nil)
      }).disposed(by: self.disposeBag)
  }
  
  func resetUserChat() -> Observable<String?> {
    return Observable.create({ [weak self] (subscribe) in
      //guard let s = self else { return Disposables.create() }
      self?.nextSeq = ""

      if let chatId = self?.chatId, chatId != "" {
        _ = self?.fetchChat().subscribe(onNext: { _ in
          mainStore.dispatch(RemoveMessages(payload: chatId))
          subscribe.onNext(chatId)
        }, onError: { error in
          subscribe.onError(error)
        })
        return Disposables.create()
      }
      
      self?.createChat(completion: { (userChatId) in
        subscribe.onNext(userChatId)
      })
      
      return Disposables.create()
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
    
    self.chat?.readAll()
      .subscribe(onNext: { [weak self] _ in
        self?.isRequstingReadAll = false
        self?.readAllManually()
      }).disposed(by: self.disposeBag)
  }
  
  func readAllManually() {
    guard var session = self.chat?.session else { return }
    session.unread = 0
    session.alert = 0
    mainStore.dispatch(UpdateSession(payload: session))
  }
  
  func getPlugin() -> Observable<(CHPlugin, CHBot?)> {
    return PluginPromise.getPlugin(pluginId: mainStore.state.plugin.id)
  }
  
  func getWelcomeScript() -> Observable<CHScript?> {
    let scriptKey = mainStore.state.guest.ghost ? "welcome_ghost" : "welcome"
    return ScriptPromise.get(pluginId: mainStore.state.plugin.id, scriptKey: scriptKey)
  }
}

extension ChatManager {
  func willAppear() {
    self.state = .chatJoining
    self.observeSocketEvents()
    WsService.shared.join(chatId: self.chatId)
  }
  
  func willDisppear() {
    self.sendTyping(isStop: true)
    self.requestReadAll()
    self.disposeSignals()
    WsService.shared.leave(chatId: self.chatId)
  }
  
  func canLoadMore() -> Bool {
    return self.nextSeq != "" && self.chatId != "" && self.chatType != ""
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
