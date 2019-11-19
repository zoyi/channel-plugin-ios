//
//  UserChatPresenter.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import RxSwift
import ReSwift
import UIKit
import SVProgressHUD
import Photos

class UserChatPresenter: NSObject, UserChatPresenterProtocol {
  weak var view: UserChatViewProtocol?
  var interactor: UserChatInteractorProtocol?
  var router: UserChatRouterProtocol?
  
  var userChatId: String?
  private var userChat: CHUserChat?
  
  private var navigationUpdateSubject = PublishSubject<CHUserChat?>()
  
  private var state: ChatProcessState = .idle
  private var didChatLoaded: Bool = false
  private var didMessageLoaded: Bool = false
  private var isRequestingAction = false
  private var isRequestingReadAll = false
  
  var shouldRedrawProfileBot = true
  var isProfileFocus = false
  
  private var typingPersons = [CHEntity]()
  private var timeStorage = [String: Timer]()
  private var animateTyping = false
  
  var preloadText: String = ""
  
  private var disposeBag = DisposeBag()
  
  deinit {
    self.leaveSocket()
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
    mainStore.dispatch(ClearChat())
  }
  
  func viewDidLoad() {
    self.observeActiveNotification()
    self.observeNavigation()
    self.observeTypingEvents()
    
    self.prepareChat()

    self.view?.setPreloadtext(with: self.preloadText)
    
    self.interactor?
      .readyToPresent()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        self?.showLocalMessageIfNeed()
      }, onError: { [weak self] (error) in
        self?.view?.display(error: error.localizedDescription, visible: true)
      }).disposed(by: self.disposeBag)
  }
  
  private func showLocalMessageIfNeed() {
    if supportBotEntrySelector(state: mainStore.state) != nil && self.userChatId == nil {
      mainStore.dispatch(InsertSupportBotEntry())
      self.requestRead()
      self.view?.display(userChat: self.userChat, channel: mainStore.state.channel)
    } else if self.userChatId == nil {
      mainStore.dispatch(InsertWelcome())
      self.requestRead()
      self.view?.display(userChat: self.userChat, channel: mainStore.state.channel)
    } else if self.userChatId?.hasPrefix(CHConstants.nudgeChat) == true {
      self.requestRead()
      self.view?.display(userChat: self.userChat, channel: mainStore.state.channel)
    }
  }
  
  private func observeActiveNotification() {
    NotificationCenter.default
      .rx.notification(UIApplication.didBecomeActiveNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.didChatLoaded = false
        self?.didMessageLoaded = false
        self?.joinSocket()
      }.disposed(by: self.disposeBag)
    
    NotificationCenter.default
      .rx.notification(UIApplication.willResignActiveNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        self?.prepareLeave()
        self?.leaveSocket()
      }.disposed(by: self.disposeBag)
  }
  
  private func observeNavigation() {
    self.navigationUpdateSubject
      .takeUntil(self.rx.deallocated)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chat) in
        self?.view?.updateNavigation(userChat: chat)
      }).disposed(by: self.disposeBag)
  }
  
  private func observeTypingEvents() {
    WsService.shared.typingSubject
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (typingEntity) in
        if typingEntity.action == "stop" {
          if let index = self?.getTypingIndex(of: typingEntity) {
            let person = self?.typingPersons.remove(at: index)
            self?.removeTimer(with: person)
          }
        } else if typingEntity.action == "start" {
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
        self?.view?.display(
          typers: self?.typingPersons ?? [],
          channel: mainStore.state.channel
        )
      }).disposed(by: self.disposeBag)
    
    WsService.shared.mOnCreate()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (message) in
        let typing = CHTypingEntity.transform(from: message)
        if let index = self?.getTypingIndex(of: typing) {
          let person = self?.typingPersons.remove(at: index)
          self?.removeTimer(with: person)
          self?.view?.display(
            typers: self?.typingPersons ?? [],
            channel: mainStore.state.channel)
        }
        self?.shouldRedrawProfileBot = message.profileBot?.count != 0
      }).disposed(by: self.disposeBag)
  }
  
  private func prepareChat() {
    WsService.shared.observeJoin()
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] (_) -> Observable<CHUserChat?> in
        guard let self = self else { return .empty() }
        self.state = .chatJoined
        return self.fetchChatIfNeeded()
      }.subscribe(onNext: { [weak self] (chat) in
        guard let self = self, let chat = chat else { return }
        self.userChatId = chat.id
        self.userChat = chat
        self.fetchMessages()
      }).disposed(by: self.disposeBag)
    
    self.joinSocket()
  }

  private func prepareLeave() {
    self.sendTyping(isStop: true)
    self.clearTyping()
  }
  
  private func leaveSocket() {
    guard
      let chatId = self.userChatId,
      chatId != "",
      !chatId.hasPrefix(CHConstants.nudgeChat) else {
      return
    }
    WsService.shared.leave(chatId: chatId)
  }
  
  private func joinSocket() {
    guard let chatId = self.userChatId else { return }
    self.interactor?.userChatId = chatId
    self.state = .chatJoining
    self.interactor?.joinSocket()
  }
  
  private func needToFetchChat() -> Bool {
    guard
      let chatId = self.userChatId,
      !self.didChatLoaded,
      self.state != .chatLoading,
      !chatId.hasPrefix(CHConstants.nudgeChat) else {
      return false
    }
    return true
  }
  
  private func fetchChatIfNeeded() -> Observable<CHUserChat?> {
    guard self.needToFetchChat() else {
      return .just(nil)
    }
    
    return Observable.create { subscriber in
      self.state = .chatLoading
      let signal = self.interactor?
        .fetchChat()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chat) in
          self?.didChatLoaded = true
          self?.state = .chatLoaded
          self?.userChatId = chat?.id
          self?.userChat = chat
          subscriber.onNext(chat)
          subscriber.onCompleted()
        }, onError: { [weak self] (error) in
          self?.didChatLoaded = false
          self?.state = .chatNotLoaded
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal?.dispose()
      }
    }
  }
  
  func fetchMessages() {
    guard !self.didMessageLoaded ||
      self.interactor?.canLoadMore() == true else {
      return
    }
    
    self.interactor?
      .fetchMessages()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (state) in
        self?.state = state
      }, onError: { [weak self] (error) in
        self?.state = .messageNotLoaded
        self?.view?.display(error: error.localizedDescription, visible: false)
      }, onCompleted: { [weak self] in
        self?.state = .chatReady
        if self?.didMessageLoaded == false {
          self?.didMessageLoaded = true
          self?.requestRead()
          self?.view?.display(
            userChat: self?.userChat,
            channel: mainStore.state.channel
          )
        }
      }).disposed(by: self.disposeBag)
  }
  
  private func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingPersons.firstIndex(where: {
      $0.id == typingEntity.personId && $0.kind == typingEntity.personType
    })
  }

  func prepareDataSource() {
    self.interactor?.subscribeDataSource()
  }
  
  func cleanDataSource() {
    self.interactor?.unsunbscribeDataSource()
    self.prepareLeave()
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
  
  func updateMessages(
    with messages: [CHMessage],
    userChat: CHUserChat?,
    channel: CHChannel) {
    if let prevChat = self.userChat,
      prevChat.shouldRequestRead(otherChat: userChat),
      state != .chatLoading,
      state != .messageLoading {
      self.requestRead()
    }
    
    self.userChat = userChat
    self.navigationUpdateSubject.onNext(self.userChat)
    self.view?.display(
      messages: messages,
      userChat: self.userChat,
      channel: channel
    )
  }
  
  func handleError(with error: String?, visible: Bool, state: ChatProcessState) {
    self.state = state
    self.view?.display(error: error, visible: visible)
  }
  
  func profileIsFocus(focus: Bool) {
    self.isProfileFocus = focus
    self.view?.updateInputBar(state: focus ? .disabled : .normal)
  }
  
  func didClickOnProfileUpdate(with message: CHMessage?, key: String?, value: Any?) -> Observable<Bool> {
    guard let message = message, let key = key, let value = value else {
      return .just(false)
    }
    
    return Observable.create { (subscriber) in
      let signal = self.interactor?
        .updateProfileItem(with: message, key: key, value: value)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (message) in
          self?.shouldRedrawProfileBot = true
          self?.view?.reloadTableView()
          let updatedValue = message.profileBot?.filter { $0.key == key }.first?.value
          ChannelIO.delegate?.onChangeProfile?(key: key, value: updatedValue)
          mainStore.dispatch(UpdateMessage(payload: message))
          subscriber.onNext(true)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onNext(false)
          subscriber.onError(error)
        })
      
      return Disposables.create {
        signal?.dispose()
      }
    }
  }
  
  func didClickOnRetry(for message: CHMessage?, from view: UIView?) {
    self.router?
      .showRetryActionSheet(from: view)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] (retry) -> Observable<CHMessage?> in
        guard let interactor = self?.interactor else {
          return .empty()
        }
        
        guard retry == true else {
          interactor.delete(message: message)
          return .empty()
        }
        
        return interactor.send(message: message)
      }
      .observeOn(MainScheduler.instance)
      .subscribe()
      .disposed(by: self.disposeBag)
  }
  
  func didClickOnRedirectUrl(with url: String) {
    guard let url = URL(string: url) else { return }
    let shouldHandle = ChannelIO.delegate?.onClickRedirect?(url: url)
    if shouldHandle == false || shouldHandle == nil {
      url.openWithUniversal()
    }
  }
  
  func didClickOnVideo(with url: URL?, from view: UIViewController?) {
    guard let url = url else { return }
    self.router?.presentVideoPlayer(with: url, from: view)
  }
  
  func didClickOnFile(with message: CHMessage?, from view: UIViewController?) {
    guard var message = message else { return }
    guard let file = message.file else { return }
    
    if file.category == "video" {
      self.didClickOnVideo(with: file.fileUrl!, from: view)
      return
    }
    
    SVProgressHUD.showProgress(0)
    file
      .download()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (fileURL, progress) in
        if let fileURL = fileURL {
          SVProgressHUD.dismiss()
          message.file?.urlInDocumentsDirectory = fileURL
          mainStore.dispatch(UpdateMessage(payload: message))
          self?.router?.pushFileView(with: fileURL, from: view)
        }
        if progress < 1 {
          SVProgressHUD.showProgress(progress)
        }
      }, onError: { (error) in
        SVProgressHUD.dismiss()
      }, onCompleted: {
        SVProgressHUD.dismiss()
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnImage(
    with url: URL?,
    photoUrls: [URL],
    imageView: UIImageView,
    from view: UIViewController?) {
    self.router?.presentImageViewer(
      with: url, photoUrls: photoUrls,
      imageView: imageView,
      from: view
    )
  }

  func didClickOnWeb(with url: String?, from view: UIViewController?) {
    guard let url = URL(string: url ?? "") else { return }
    UIApplication.shared.openURL(url)
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
    
    self.interactor?.translate(for: message)
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
  
  func didClickOnRightNaviItem(from view: UIViewController?) {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
    ChannelIO.close(animated: true)
  }
  
  func didClickOnNewChat(with text: String, from view: UINavigationController?) {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
    let pluginSignal = CHPlugin.get(with: mainStore.state.plugin.id)
    let supportSignal =  CHSupportBot.get(with: mainStore.state.plugin.id, fetch: true)
  
    Observable
      .zip(pluginSignal, supportSignal)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        let reloadMessage = CHAssets.localized("plugin.reload.message")
        SVProgressHUD.show(withStatus: reloadMessage)
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (plugin, entry) in
        mainStore.dispatch(GetPlugin(plugin: plugin.0, bot: plugin.1))
        mainStore.dispatch(GetSupportBotEntry(bot: plugin.1, entry: entry))
        SVProgressHUD.dismiss()
        self?.router?.showNewChat(with: text, from: view)
      }, onError: { (error) in
        SVProgressHUD.dismiss()
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnAssetButton(from view: UIViewController?) {
    self.router?
      .showOptionActionSheet(from: view)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (assets) in
        self?.sendAssets(assets: assets)
      }, onError: { [weak self] (error) in
        self?.view?.display(error: error.localizedDescription, visible: true)
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnSendButton(text: String) {
    guard
      let chatId = self.userChatId,
      let chat = self.userChat,
      chat.isActive else {
      self.interactor?
        .createChat()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chat) in
          guard let chat = chat else { return }
          self?.userChatId = chat.id
          self?.userChat = chat
          self?.sendMessage(with: text, chatId: chat.id)
        }, onError: { [weak self] (error) in
          self?.view?.display(error: error.localizedDescription, visible: false)
        }).disposed(by: self.disposeBag)
      return
    }

    self.sendMessage(with: text, chatId: chatId)
  }
    
  private func sendMessage(with text: String, chatId: String) {
    let message = CHMessage.createLocal(chatId: chatId, text: text)
    mainStore.dispatch(CreateMessage(payload: message))
    self.sendMessage(with: message, chatId: chatId)
  }
  
  private func sendMessage(with message: CHMessage, chatId: String) {
    self.interactor?
      .send(message: message)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }, onError: { [weak self] (error) in
        self?.view?.display(error: error.localizedDescription, visible: false)
      }).disposed(by: self.disposeBag)
  }
  
  private func sendAssets(assets: [PHAsset]) {
    guard let chat = self.userChat, chat.isActive else {
      self.interactor?
        .createChat()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chat) in
          guard let chat = chat else { return }
          self?.userChatId = chat.id
          self?.userChat = chat
          let messages = self?.createMessageForImages(assets: assets, requestBot: true) ?? []
          self?.interactor?.sendMessageRecursively(allMessages: messages, currentIndex: 0)
        }, onError: { [weak self] (error) in
          self?.state = .chatNotLoaded
          self?.view?.display(error: error.localizedDescription, visible: false)
        }).disposed(by: self.disposeBag)
      return
    }
    
    let messages = self.createMessageForImages(assets: assets)
    self.interactor?.sendMessageRecursively(allMessages: messages, currentIndex: 0)
  }
  
  private func createMessageForImages(assets: [PHAsset], requestBot: Bool = false) -> [CHMessage] {
    let messages = assets.map({ (asset) -> CHMessage in
      return CHMessage(chatId: self.userChatId ?? "", guest: mainStore.state.guest, asset: asset)
    })
    messages.forEach { mainStore.dispatch(CreateMessage(payload: $0)) }
    return messages
  }
  
  func didClickOnActionButton(originId: String?, key: String?, value: String?) {
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
  
  func didClickOnNudgeKeepAction(){
    guard
      let chat = self.userChat,
      chat.fromNudge,
      let nudgeId = chat.nudgeId else {
      return
    }
    
    self.interactor?
      .createNudgeChat(nudgeId: nudgeId)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self](chat) -> Observable<CHMessage?> in
        guard let chat = chat else {
            return .empty()
        }
        self?.userChat = chat
        self?.userChatId = chat.id
        self?.joinSocket()
        return chat.keepNudge()
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }, onError: { [weak self](error) in
        self?.view?.display(error: error.localizedDescription, visible: false)
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnWaterMark() {
    let channelName = mainStore.state.channel.name
    let urlEncoded = channelName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let urlString = CHUtils.getUrlForUTM(source: "plugin_watermark", content: urlEncoded)
    if let url = URL(string: urlString) {
      url.openWithUniversal()
    }
  }
  
  func sendTyping(isStop: Bool) {
    self.interactor?.sendTyping(isStop: isStop)
  }
  
  private func addTimer(with person: CHEntity, delay: TimeInterval) {
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
  
  private func removeTimer(with person: CHEntity?) {
    guard let person = person else { return }
    if let t = self.timeStorage.removeValue(forKey: person.key) {
      t.invalidate()
    }
  }
  
  private func clearTyping() {
    self.timeStorage.forEach { (k, t) in
      t.invalidate()
    }
    self.typingPersons.removeAll()
    self.timeStorage.removeAll()
  }
  
  @objc private func expired(_ timer: Timer) {
    guard let params = timer.userInfo as? [Any] else { return }
    guard let person = params[0] as? CHEntity else { return }
    
    timer.invalidate()
    if let index = self.typingPersons.firstIndex(where: { (p) in
      return p.id == person.id && p.kind == person.kind
    }) {
      self.typingPersons.remove(at: index)
      self.timeStorage.removeValue(forKey: person.key)
      self.view?.display(
        typers: self.typingPersons,
        channel: mainStore.state.channel
      )
    }
  }
  
  private func requestRead(shouldDebounce: Bool = false) {
    guard !self.isRequestingReadAll, let chat = self.userChat else { return }

    self.isRequestingReadAll = true
    chat
      .read()
      .debounce(.seconds(shouldDebounce ? 1 : 0), scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (completed) in
        self?.isRequestingReadAll = false
      }, onError: { [weak self] (error) in
        self?.isRequestingReadAll = false
      }).disposed(by: self.disposeBag)
  }
   
  private func processPostAction(originId: String?, key: String, value: String) {
    guard let chatId = self.userChatId else { return }
    let message = CHMessage.createLocal(chatId: chatId, text: value, originId: originId, key: key)
    mainStore.dispatch(CreateMessage(payload: message))
     
    self.sendMessage(with: message, chatId: chatId)
  }
   
  private func processSupportBotAction(originId: String?, key: String?, value: String?) {
    guard !self.isRequestingAction else { return }
    self.isRequestingAction = true
     
    self.interactor?
      .createSupportBotChatIfNeeded(originId: originId)
      .observeOn(MainScheduler.instance)
      .flatMap({ [weak self] (chat, message) -> Observable<CHMessage> in
        guard let chat = chat else { return .empty() }
        self?.userChatId = chat.id
        self?.userChat = chat
        self?.joinSocket()
        let msg = CHMessage.createLocal(
          chatId: chat.id,
          text: value,
          originId: originId,
          key: key)
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
      }, onError: { [weak self](error) in
        self?.isRequestingAction = false
        self?.view?.display(error: error.localizedDescription, visible: false)
      }).disposed(by: self.disposeBag)
  }
   
  private func processUserChatAction(originId: String?, key: String?, value: String?) {
    guard var origin = messageSelector(state: mainStore.state, id: originId),
      let type = origin.action?.type,
      let key = key, let value = value else { return }
     
    var message: CHMessage?
    guard let userChatId = self.userChatId else { return }
    if (type == .solve && key == "close") || type == .close {
      message = CHMessage.createLocal(
        chatId: userChatId,
        text: value,
        originId: originId,
        key: key)
      mainStore.dispatch(CreateMessage(payload: message))
    }
     
    if type == .solve && key == "close" {
      self.userChat?
        .close(mid: origin.id, requestId: message?.requestId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chat) in
          mainStore.dispatch(UpdateUserChat(payload:chat))
        }, onError: { [weak self] (error) in
          self?.view?.display(error: error.localizedDescription, visible: false)
        }).disposed(by: self.disposeBag)
    } else if type == .solve && key == "reopen" {
      origin.action?.closed = true
      mainStore.dispatch(UpdateMessage(payload: origin))
      if var updatedChat = userChatSelector(state: mainStore.state, userChatId: userChatId) {
        updatedChat.state = updatedChat.assigneeId == nil ? .unassigned : .assigned
        mainStore.dispatch(UpdateUserChat(payload: updatedChat))
      }
    } else if type == .close, let review = ReviewType(rawValue: key) {
      self.userChat?
        .review(
          mid: origin.id,
          rating: review,
          requestId: message?.requestId ?? "")
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (chat) in
          mainStore.dispatch(UpdateUserChat(payload:chat))
        }, onError: { [weak self] (error) in
          self?.view?.display(error: error.localizedDescription, visible: false)
        }).disposed(by: self.disposeBag)
    }
  }
}
