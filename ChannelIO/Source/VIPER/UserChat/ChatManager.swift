//
//  ChatManager.swift
//  CHPlugin
//
//  Created by Haeun Chung on 12/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxCocoa
import CHSlackTextViewController
import SVProgressHUD
import Alamofire
import AVKit
import Photos
import MobileCoreServices
import TLPhotoPicker

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

class ChatManager: NSObject {
  var chatId = ""
  var chatType = ""
  var chat: CHUserChat? = nil {
    willSet {
      if let chat = newValue {
        self.chatId = chat.id
        self.chatType = "UserChat"
      }
    }
  }
  
  var guest: CHGuest? = nil
  
  var didFetchInfo = false
  var didChatLoaded = false
  var didLoad = false
  var chatNewlyCreated = false
  var state: ChatState = .idle
  var shouldRedrawProfileBot = true
  var profileIsFocus = false
  
  let disposeBag = DisposeBag()
  
  fileprivate var typingPersons = [CHEntity]()
  fileprivate var timeStorage = [String: Timer]()
  fileprivate var animateTyping = false
  fileprivate var nextSeq = ""
  
  fileprivate var isRequestingAction = false
  fileprivate var isFetching = false
  fileprivate var isRequestingReadAll = false
  
  
  fileprivate var messageDispose: Disposable?
  fileprivate var typingDispose: Disposable?
  fileprivate var chatDispose: Disposable?
  fileprivate var readyDispose: Disposable?
  
  var typers: [CHEntity] {
    get {
      return self.typingPersons
    }
  }
  
  weak var delegate: ChatDelegate? = nil
  weak var viewController: UIViewController? = nil
  
  deinit {
    dlog("Destroyed chatManager")
  }
  
  init(id: String?, type: String = "UserChat"){
    super.init()
    
    self.chatType = type
    self.setChatEntities(with: id)
    self.observeAppState()
    self.requestRead()
  }
  
  fileprivate func setChatEntities(with chatId: String?) {
    self.chatId = chatId ?? ""
    self.chat = userChatSelector(
      state: mainStore.state,
      userChatId: chatId)
    self.guest = personSelector(
      state: mainStore.state,
      personType: self.chat?.personType,
      personId: self.chat?.personId) as? CHGuest
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
    self.messageDispose?.dispose()
    self.readyDispose?.dispose()
  }
  
  fileprivate func observeAppState() {
    NotificationCenter.default
      .rx.notification(UIApplication.didBecomeActiveNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.didChatLoaded = false
        self?.prepareToChat()
      }.disposed(by: self.disposeBag)
    
    NotificationCenter.default
      .rx.notification(UIApplication.willResignActiveNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.prepareToLeave()
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
        self?.shouldRedrawProfileBot = message.profileBot?.count != 0
      })
  }
  
  fileprivate func observeChatEvents() {
    self.chatDispose = WsService.shared.eventSubject
      .filter({ [weak self] (type, data) -> Bool in
        guard let userChat = data as? CHUserChat else { return false }
        return type == WsServiceType.UpdateUserChat &&
          userChat.id == self?.chat?.id &&
          userChat.personId == self?.chat?.personId
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (type, data) in
        guard let newChat = data as? CHUserChat else { return }
        guard let prevChat = self?.chat else { return }
        if prevChat.shouldRequestRead(otherChat: newChat) {
          self?.requestRead()
        }

        mainStore.dispatch(UpdateUserChat(payload: newChat))
        self?.setChatEntities(with: newChat.id)
      })
  }
  
  fileprivate func observeSessionEvents() {
    _ = WsService.shared.joined()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chatId) in
        if self?.chatNewlyCreated == false {
          self?.didChatLoaded = false
        }
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
  
  public func clearTyping() {
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
      self.delegate?.update(for: .typing(obj: self.typingPersons, animated: self.animateTyping))
    }
  }
  
  fileprivate func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.firstIndex(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
  }
}

extension ChatManager {
  func sendMessage(message: CHMessage, local: Bool = false) -> Observable<CHMessage?> {
    var message = message
    return Observable.create({ [weak self] (subscriber) in
      if local {
        subscriber.onNext(message)
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      let signal = message.send()
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
        message.state = .Failed
        subscriber.onNext(message)
        subscriber.onCompleted()
      })
      
      return Disposables.create {
        signal.dispose()
      }
    })
  }
  
  func sendMessageRecursively(allMessages: [CHMessage], currentIndex: Int) {
    var message = allMessages.get(index: currentIndex)
    
    message?.send()
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
      mainStore.dispatch(CreateMessage(payload: message!))
      self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
    }).disposed(by: self.disposeBag)
  }
  
  //for image capture on channelIO
  func sendImage(imageData: UIImage) {
  
    if self.chatId != "" {
      let message = CHMessage(chatId: self.chatId, guest: mainStore.state.guest, image: imageData)
      mainStore.dispatch(CreateMessage(payload: message))
      self.sendMessageRecursively(allMessages: [message], currentIndex: 0)
    } else {
      self.createChat()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chatId) in
          var message = CHMessage(chatId: chatId, guest: mainStore.state.guest, image: imageData)
          message.createdAt = Date()
          mainStore.dispatch(CreateMessage(payload: message))
          self?.sendMessageRecursively(allMessages: [message], currentIndex: 0)
        }, onError: { [weak self] (error) in
          self?.state = .chatNotLoaded
        }).disposed(by: self.disposeBag)
    }
  }
  
  //from images from albums
  func sendAssets(assets: [PHAsset]) {
    if self.chatId != "" {
      let messages = self.createMessageForImages(assets: assets)
      self.sendMessageRecursively(allMessages: messages, currentIndex: 0)
    } else {
      self.createChat()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chatId) in
          let messages = self?.createMessageForImages(assets: assets, requestBot: true) ?? []
          self?.sendMessageRecursively(allMessages: messages, currentIndex: 0)
        }, onError: { [weak self] (error) in
          self?.state = .chatNotLoaded
        }).disposed(by: self.disposeBag)
    }
  }
  
  private func createMessageForImages(assets: [PHAsset], requestBot: Bool = false) -> [CHMessage] {
    let messages = assets.map({ (asset) -> CHMessage in
      return CHMessage(chatId: self.chatId, guest: mainStore.state.guest, asset: asset)
    })
    
    messages.forEach({ mainStore.dispatch(CreateMessage(payload: $0)) })
    return messages
  }
}

extension ChatManager {  
  func processSendMessage(msg: String) -> Observable<CHUserChat?> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      let createChatSignal = self?.chat?.isActive == true ?
        Observable.just(self?.chat?.id ?? "") :
        self?.createChat()
      
      createChatSignal?
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .flatMap({ (chatId) -> Observable<CHMessage?> in
          guard let s = self else { return .empty() }
          guard chatId != "" else { return .empty() }
          
          s.chatId = chatId
          let message = CHMessage.createLocal(chatId: self!.chatId, text: msg)
          mainStore.dispatch(CreateMessage(payload: message))
          return s.sendMessage(message: message, local: false)
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (message) in
          mainStore.dispatch(CreateMessage(payload: message))
          subscriber.onNext(self?.chat)
          subscriber.onCompleted()
        }, onError: { (error) in
          self?.state = .chatNotLoaded
          subscriber.onError(error)
        }).disposed(by: self!.disposeBag)
      return Disposables.create()
    })
  }
  
  private func processPostAction(originId: String?, key: String, value: String) {
    let message = CHMessage.createLocal(chatId: self.chatId, text: value, originId: originId, key: key)
    mainStore.dispatch(CreateMessage(payload: message))
    
    self.sendMessage(message: message, local: false)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload:message))
      }, onError: { (error) in
        //handle error
      }).disposed(by: self.disposeBag)
  }
  
  func processNudgeKeepAction(){
    guard let chat = self.chat, chat.fromNudge, let nudgeId = chat.nudgeId else { return }
    
    self.createNudgeChat(nudgeId: nudgeId)
      .observeOn(MainScheduler.instance)
      .flatMap {( chatId) -> Observable<CHMessage?> in
        return UserChatPromise.keepNudge(userChatId: chatId)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }, onError: { (erro) in
        //?
      }).disposed(by: self.disposeBag)
  }
  
  private func processSupportBotAction(originId: String?, key: String?, value: String?) {
    guard !self.isRequestingAction else { return }
    self.isRequestingAction = true
    
    self.createSupportBotChatIfNeeded(originId: originId)
      .observeOn(MainScheduler.instance)
      .flatMap({ (chat, message) -> Observable<CHMessage> in
        let msg = CHMessage.createLocal(chatId: chat!.id, text: value, originId: originId, key: key)
        mainStore.dispatch(CreateMessage(payload: msg))
        return CHSupportBot.reply(with: msg, actionId: message?.id)
      })
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while replying supportBot. Attempting to reply again")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (updated) in
        self?.isRequestingAction = false
        mainStore.dispatch(CreateMessage(payload: updated))
      }, onError: { [weak self] (error) in
        self?.isRequestingAction = false
        //handle error
      }).disposed(by: self.disposeBag)
  }
  
  private func processUserChatAction(originId: String?, key: String?, value: String?) {
    guard var origin = messageSelector(state: mainStore.state, id: originId),
      let type = origin.action?.type,
      let key = key, let value = value else { return }
    
    var msg: CHMessage?
    if (type == .solve && key == "close") || type == .close {
      msg = CHMessage.createLocal(chatId: self.chatId, text: value, originId: originId, key: key)
      mainStore.dispatch(CreateMessage(payload: msg))
    }
    
    if type == .solve && key == "close" {
      self.chat?.close(mid: origin.id, requestId: msg?.requestId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chat) in
          mainStore.dispatch(UpdateUserChat(payload:chat))
        }, onError: { (error) in
          //handle error
        }).disposed(by: self.disposeBag)
    } else if type == .solve && key == "reopen" {
      origin.action?.closed = true
      mainStore.dispatch(UpdateMessage(payload: origin))
      if var updatedChat = userChatSelector(state: mainStore.state, userChatId: self.chatId) {
        updatedChat.state = updatedChat.assigneeId == nil ? .unassigned : .assigned
        mainStore.dispatch(UpdateUserChat(payload: updatedChat))
      }
    } else if type == .close {
      self.chat?.review(mid: origin.id, rating: ReviewType(rawValue: key)!, requestId:msg?.requestId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chat) in
          mainStore.dispatch(UpdateUserChat(payload:chat))
        }, onError: { (error) in
          
        }).disposed(by: self.disposeBag)
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
    return !self.didFetchInfo &&
      self.chatId == "" &&
      self.state != .infoLoading &&
      !self.chatId.hasPrefix(CHConstants.nudgeChat)
  }
  
  func needToFetchChat() -> Bool {
    return !self.didChatLoaded &&
      self.chatId != "" &&
      self.state != .chatLoading &&
      !self.chatId.hasPrefix(CHConstants.nudgeChat)
  }
  
  func isChatLoading() -> Bool {
    return self.state == .chatLoading
  }
  
  func isMessageLoading() -> Bool {
    return self.state == .messageLoading
  }
  
  func canLoadMore() -> Bool {
    return self.nextSeq != "" &&
      self.chatId != "" &&
      self.chatType != "" &&
      !self.chatId.hasPrefix(CHConstants.nudgeChat)
  }
}

// MARK: APIs

extension ChatManager {
  //NOTE: not considered simultaneous calling of difference fetching functions
  
  func fetchChat() -> Observable<ChatResponse> {
    return Observable.create { [weak self] subscriber in
      guard self?.state != .chatLoading else {
        subscriber.onCompleted()
        return Disposables.create()
      }
      guard let s = self else  {
        subscriber.onCompleted()
        return Disposables.create()
      }
      guard !s.chatId.hasPrefix(CHConstants.nudgeChat) else {
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      self?.state = .chatLoading
      self?.nextSeq = ""
      
      let signal = CHUserChat.get(userChatId: s.chatId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while fetching chat. Attempting to fetch again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (response) in
        self?.didChatLoaded = true
        self?.state = .chatLoaded
        //due to message update step were not desirable
        var response = response
        response.message = nil
        mainStore.dispatch(GetUserChat(payload: response))
      
        self?.chat = userChatSelector(state: mainStore.state, userChatId: s.chatId)
        subscriber.onNext(response)
        subscriber.onCompleted()
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
  
  func createNudgeChat(nudgeId:String?) -> Observable<String> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      guard let nudgeId = nudgeId else {
        subscriber.onError(CHErrorPool.paramError)
        return Disposables.create()
      }
      if let chatId = self?.chatId, chatId != "", !chatId.hasPrefix(CHConstants.nudgeChat) {
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
          
          self?.chatNewlyCreated = true
          self?.didChatLoaded = true
          self?.setChatEntities(with: chatResponse.userChat?.id)
          self?.prepareToChat()
          
          subscriber.onNext(chatResponse.userChat?.id ?? "")
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
  
  func createSupportBotChatIfNeeded(originId: String? = nil) -> Observable<(CHUserChat?, CHMessage?)> {
    return Observable.create({ [weak self] (subscriber) -> Disposable in
      var disposable: Disposable?
      if let chat = self?.chat, let message = messageSelector(state: mainStore.state, id: originId) {
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
            
          self?.chatNewlyCreated = true
          self?.didChatLoaded = true
          self?.setChatEntities(with: chatResponse.userChat?.id)
          self?.prepareToChat()
         
          subscriber.onNext((chatResponse.userChat, chatResponse.message))
          subscriber.onCompleted()
        }, onError: { [weak self] (error) in
          self?.didChatLoaded = false
          self?.state = .chatNotLoaded
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
      
      //if push bot message is present, create push bot user chat
      let signal = CHUserChat.create(pluginId: pluginId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while creating a chat. Attempting to create again")
          return true
        })
        .observeOn(MainScheduler.instance).subscribe(onNext: { (chatResponse) in
          mainStore.dispatch(GetUserChat(payload: chatResponse))
          
          self?.chatNewlyCreated = true
          self?.didChatLoaded = true
          self?.setChatEntities(with: chatResponse.userChat?.id)
          self?.prepareToChat()
        
          subscriber.onNext(chatResponse.userChat?.id ?? "")
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
  
  func reconnect() {
    self.nextSeq = ""
    self.didChatLoaded = false
    WsService.shared.connect()
    
    AppManager.touch().observeOn(MainScheduler.instance).subscribe(onNext: { (user) in
      mainStore.dispatch(UpdateGuest(payload: user))
    }).disposed(by: self.disposeBag)
  }
  
  func fetchMessages() {
    if self.isFetching {
      return
    }
    
    // TODO: show loader
    self.isFetching = true
    CHMessage.getMessages(
      userChatId: self.chatId,
      since: self.nextSeq,
      limit: 30,
      sortOrder: "DESC")
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching messages. Attempting to fetch again")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (data) in
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
        }
      }).disposed(by: self.disposeBag)
  }
  
  func requestRead() {
    guard !self.isRequestingReadAll else { return }
    guard let chat = userChatSelector(state: mainStore.state, userChatId: self.chatId) else { return }

    self.isRequestingReadAll = true
    chat.read()
      .debounce(1, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (completed) in
        self?.isRequestingReadAll = false
      }, onError: { [weak self] (error) in
        self?.isRequestingReadAll = false
      }).disposed(by: self.disposeBag)
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
          let updatedValue = message.profileBot?.filter { $0.key == key }.first?.value
          ChannelIO.delegate?.onChangeProfile?(key: key, value: updatedValue)
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
  func prepareToChat() {
    guard self.chatId != "" else { return }
    guard !self.chatId.hasPrefix(CHConstants.nudgeChat) else { return }
    
    self.state = .chatJoining
    self.observeSocketEvents()
    
    WsService.shared.join(chatId: self.chatId)
    self.readyDispose = WsService.shared.ready().subscribe(onNext: { (_) in
       WsService.shared.join(chatId: self.chatId)
    })
  }
  
  func prepareToLeave() {
    self.sendTyping(isStop: true)
    self.clearTyping()
    self.disposeSignals()
  }
  
  func leave() {
    guard self.chatId != "" else { return }
    guard !self.chatId.hasPrefix(CHConstants.nudgeChat) else { return }
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
    
    return !current.elementsEqual(updated)
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
  func onClickActionButton(originId: String?, key: String?, value: String?) {
    guard let origin = messageSelector(state: mainStore.state, id: originId),
      let type = origin.action?.type, let key = key, let value = value else { return }
    
    if type == .select {
      self.processPostAction(originId: originId, key: key, value: value)
    } else if type == .support {
      self.processSupportBotAction(originId: originId, key: key, value: value)
    } else {
      self.processUserChatAction(originId: originId, key: key, value: value)
    }
  }
  
  func didClickOnWebPage(with message: CHMessage) {
    guard let url = URL(string:message.webPage?.url ?? "") else { return }
    let shouldHandle = ChannelIO.delegate?.onClickChatLink?(url: url)
    if shouldHandle == false || shouldHandle == nil {
      url.openWithUniversal()
    }
  }
  
  func didClickOnRedirectUrl(with url: String) {
    guard let url = URL(string: url) else { return }
    let shouldHandle = ChannelIO.delegate?.onClickRedirect?(url: url)
    if shouldHandle == false || shouldHandle == nil {
      url.openWithUniversal()
    }
  }
  
  func didClickOnFile(with message: CHMessage) {
    guard let url = message.file?.url else { return }
    
    if message.file?.category == "video" {
      let moviePlayer = AVPlayerViewController()
      let player = AVPlayer(url: URL(string: url)!)
      moviePlayer.player = player
      moviePlayer.modalPresentationStyle = .overFullScreen
      moviePlayer.modalTransitionStyle = .crossDissolve
      self.viewController?.present(moviePlayer, animated: true, completion: nil)
      return
    }
    
    if let localUrl = message.file?.localUrl,
      message.file?.downloaded == true {
      self.showDocumentController(url: localUrl)
      return
    }
    
    SVProgressHUD.showProgress(0)
    
    let destination = DownloadRequest
      .suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
    
    Alamofire.download(url, to: destination)
      .downloadProgress{ (download) in
        SVProgressHUD.showProgress(Float(download.fractionCompleted))
      }
      .validate(statusCode: 200..<300)
      .response{ [weak self] (response) in
        SVProgressHUD.dismiss()
        
        let directoryURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathURL = URL(fileURLWithPath: directoryURL, isDirectory: true)
        guard let fileName = response.response?.suggestedFilename else { return }
        let fileURL = pathURL.appendingPathComponent(fileName)
        
        var message = message
        message.file?.downloaded = true
        message.file?.localUrl = fileURL
        mainStore.dispatch(UpdateMessage(payload: message))
        
        self?.showDocumentController(url: fileURL)
      }
  }
  
  func didClickOnRetry(for message: CHMessage?, sender: UIView? = nil) {
    guard let message = message else { return }
    
    let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
    
    let deleteText = CHAssets.localized("ch.chat.delete")
    alertView.addAction(UIAlertAction(title: deleteText, style: .destructive) {  _ in
      mainStore.dispatch(DeleteMessage(payload: message))
    })
    
    let sendText = CHAssets.localized("ch.chat.retry_sending_message")
    alertView.addAction(UIAlertAction(title: sendText, style: .default) { [weak self] _ in
      message.send()
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while sending message. Attempting to send again")
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }).disposed(by: (self?.disposeBag)!)
    })

    let cancelText = CHAssets.localized("ch.chat.resend.cancel")
    alertView.addAction(UIAlertAction(title: cancelText, style: .cancel) { _ in
      // no action
    })
    
    if let popOver = alertView.popoverPresentationController {
      popOver.sourceView = sender
      popOver.sourceRect = sender?.bounds ?? CGRect.zero
      popOver.permittedArrowDirections = .left
    }
    
    CHUtils.getTopController()?.present(alertView, animated: true, completion: nil)
  }
  
  func didClickOnTranslate(for message: CHMessage?) {
    guard var message = message else { return }
    if message.translateState == .original && message.translatedText != nil {
      message.translateState = .translated
      mainStore.dispatch(UpdateMessage(payload: message))
      return
    } else if message.translateState == .translated {
      message.translateState = .original
      mainStore.dispatch(UpdateMessage(payload: message))
      return
    }
    
    message.translateState = .loading
    mainStore.dispatch(UpdateMessage(payload: message))
    
    guard let language = CHUtils.getLocale()?.rawValue else { return }
    
    message.translate(to: language)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (text) in
        guard let text = text else { return }
        (message.translatedText, _) = CustomMessageTransform.markdown.parse(text)
        message.translateState = .translated
        mainStore.dispatch(UpdateMessage(payload: message))
      }, onError: { (error) in
        message.translateState = .failed
        mainStore.dispatch(UpdateMessage(payload: message))
      }).disposed(by: self.disposeBag)
  }
}

//routing
extension ChatManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func presentPicker(
    max: Int = 0,
    from view: UIViewController?) {
    
    let viewController = TLPhotosPickerViewController(withPHAssets: { [weak self] (assets) in // TLAssets
      self?.sendAssets(assets: assets)
    }, didCancel: nil)
    let configure = TLPhotosPickerConfigure()
    viewController.configure = configure
    
    view?.present(viewController, animated: true, completion: nil)
  }
  
  func presentCameraPicker(from view: UIViewController?) {
    let controller = UIImagePickerController()
    controller.sourceType = .camera
    controller.allowsEditing = true
    controller.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    controller.videoQuality = .typeMedium
    controller.videoMaximumDuration = 60

    controller.delegate = self
    view?.present(controller, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[.originalImage] as? UIImage {
      var placeholderAsset: PHObjectPlaceholder? = nil
      PHPhotoLibrary.shared().performChanges({
        let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
        placeholderAsset = newAssetRequest.placeholderForCreatedAsset
      }, completionHandler: { [weak self] (sucess, error) in
        if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
          guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
          dispatch {
            picker.dismiss(animated: true, completion: { [weak self] in
              self?.sendAssets(assets: [asset])
            })
          }
        }
      })
    }
    else if (info[.mediaType] as? String) == kUTTypeMovie as String {
      var placeholderAsset: PHObjectPlaceholder? = nil
      PHPhotoLibrary.shared().performChanges({
        let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: info[.mediaURL] as! URL)
        placeholderAsset = newAssetRequest?.placeholderForCreatedAsset
      }) { [weak self] (sucess, error) in
        if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
          guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
          dispatch {
            picker.dismiss(animated: true, completion: { [weak self] in
              self?.sendAssets(assets: [asset])
            })
          }
        }
      }
    }
  }
}

extension ChatManager : UIDocumentInteractionControllerDelegate {
  func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
    if let controller = CHUtils.getTopController() {
      return controller
    }
    return UIViewController()
  }
  
  func showDocumentController(url: URL) {
    guard let viewController = self.viewController else { return }
    
    let docController = UIDocumentInteractionController(url: url)
    docController.delegate = self
    
    if !docController.presentPreview(animated: true) {
      docController.presentOptionsMenu(
        from: viewController.view.bounds,
        in: viewController.view, animated: true)
    }
  }
}
