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
import AVKit

class UserChatPresenter: NSObject, UserChatPresenterProtocol {
  weak var view: UserChatViewProtocol?
  var interactor: UserChatInteractorProtocol?
  var router: UserChatRouterProtocol?
  
  private var userChat: CHUserChat?
  private var chatType: ChatType = .userChat
  private var state: ChatProcessState = .idle
  
  private var navigationUpdateSubject = PublishSubject<CHUserChat?>()
  
  private var didChatLoaded: Bool = false
  private var didMessageLoaded: Bool = false
  private var isRequestingAction = false
  private var isRequestingReadAll = false
  
  private var typingPersons = [CHEntity]()
  private var timeStorage = [String: Timer]()
  
  private var queueKey: ChatQueueKey? {
    guard let chatId = self.userChatId else { return nil }
    return ChatQueueKey(chatType: self.chatType, chatId: chatId)
  }
  
  var userChatId: String?
  var shouldRedrawProfileBot = true
  var isProfileFocus = false
  var preloadText: String = ""
  
  private var disposeBag = DisposeBag()
  private var fileDisposable: Disposable?
  
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
        guard let self = self else { return }
        self.showLocalMessageIfNeed()
        if let queueKey = self.queueKey, let queue = ChatQueueService.shared.find(key: queueKey) {
          self.displayFileStatus(with: queue.items)
          self.observeFileQueue()
        }
      }, onError: { [weak self] (error) in
        self?.view?.display(error: error.localizedDescription, visible: true)
      }).disposed(by: self.disposeBag)
  }
  
  private func displayFileStatus(with items: [ChatQueuable]) {
    guard let items = items as? [ChatFileQueueItem] else { return }
    
    self.view?.display(errorFiles: items.filter { $0.status == .error })
    if let item = items.filter({ $0.status == .progress }).first {
      let count = items.filter { $0.status == .initial }.count
      self.view?.display(loadingFile: item, waitingCount: count)
    } else {
      self.view?.hideLodingFile()
    }
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
            personType: typingEntity.personType,
            personId: typingEntity.personId) {
            if self?.getTypingIndex(of: typingEntity) == nil {
              self?.typingPersons.append(typer)
            }
            self?.addTimer(with: typer, delay: 15)
          }
        }
        self?.view?.display(typers: self?.typingPersons ?? [])
      }).disposed(by: self.disposeBag)
    
    WsService.shared.mOnCreate()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (message) in
        let typing = CHTypingEntity.transform(from: message)
        if let index = self?.getTypingIndex(of: typing) {
          let person = self?.typingPersons.remove(at: index)
          self?.removeTimer(with: person)
          self?.view?.display(typers: self?.typingPersons ?? [])
        }
        self?.shouldRedrawProfileBot = message.profileBot?.count != 0
      }).disposed(by: self.disposeBag)
  }
  
  private func observeFileQueue() {
    guard let queueKey = self.queueKey else { return }
    
    self.fileDisposable?.dispose()
    self.fileDisposable = ChatQueueService.shared
      .status(key: queueKey)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (status) in
        guard let self = self else { return }
        switch status {
        case .loading(let items):
          self.displayFileStatus(with: items)
        case .error(_, let items):
          self.displayFileStatus(with: items)
        case .completed(let items):
          self.displayFileStatus(with: items)
        case .idle:
          break
        case .enqueue(let items):
          self.displayFileStatus(with: items)
        }
      }, onError: { [weak self] (error) in
        self?.view?.display(error: error.localizedDescription, visible: true)
      })
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
      chatId != "" else {
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
      self.userChatId != nil,
      !self.didChatLoaded,
      self.state != .chatLoading else {
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
      $0.id == typingEntity.personId && $0.entityType.rawValue == typingEntity.personType?.rawValue
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
  
  func handleError(with error: String?, visible: Bool, state: ChatProcessState?) {
    if let state = state {
      self.state = state
    }
    self.view?.display(error: error, visible: visible)
  }
  
  func profileIsFocus(focus: Bool) {
    self.isProfileFocus = focus
    self.view?.updateInputBar(state: focus ? .disabled : .normal)
  }
  
  func didClickOnMarketingToSupportBotButton() {
    SVProgressHUD.show()
    self.interactor?
      .startMarketingToSupportBot()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { _ in
        SVProgressHUD.dismiss()
      }, onError: { [weak self] (error) in
        SVProgressHUD.dismiss()
        self?.view?.display(error: error.localizedDescription, visible: true)
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnProfileUpdate(
    with message: CHMessage?,
    key: String?,
    value: Any?) -> Observable<Bool> {
    guard let message = message, let key = key, let value = value else {
      return .just(false)
    }
    
    return Observable.create { (subscriber) in
      let signal = self.interactor?
        .updateProfileItem(with: message, key: key, value: value)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (message) in
          self?.shouldRedrawProfileBot = true
          let updatedValue = message.profileBot?.filter { $0.key == key }.first?.value
          ChannelIO.delegate?.onChangeProfile?(key: key, value: updatedValue)
          mainStore.dispatch(UpdateMessage(payload: message))
          self?.view?.reloadTableView()
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
  
  func didClickOnVideo(with url: URL?, from view: UIViewController?) {
    guard let url = url else { return }
    self.router?.presentVideoPlayer(with: url, from: view)
  }
  
  func didClickOnFile(
    with message: CHMessage?,
    file: CHFile?,
    on imageView: UIImageView?,
    from view: UIViewController?) {
    if let mkInfo = message?.mkInfo {
      mainStore.dispatch(ClickMarketing(type: mkInfo.type, id: mkInfo.id))
    }
    
    if file?.type == .image, let imageView = imageView {
      self.view?.dismissKeyboard(false)
      self.router?.presentImageViewer(
        with: file?.url,
        photoUrls: self.interactor?.photoUrls ?? [],
        imageView: imageView,
        from: view
      )
    } else if file?.type == .video, let url = file?.url {
      let controller = AVPlayerViewController()
      controller.player = AVPlayer(url: url)
      controller.showsPlaybackControls = true
      if #available(iOS 11.0, *) {
        controller.exitsFullScreenWhenPlaybackEnds = true
      }
      view?.present(controller, animated: true, completion: nil)
    } else {
      guard let file = file else { return }
      SVProgressHUD.showProgress(0)
      file
        .download()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (fileURL, progress) in
          if let fileURL = fileURL {
            SVProgressHUD.dismiss()
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
  }

  func didClickOnWeb(with message: CHMessage?, url: URL?, from view: UIViewController?) {
    guard let url = url else { return }
    let shouldHandle = ChannelIO.delegate?.onClickChatLink?(url: url)
    if shouldHandle == false || shouldHandle == nil {
      url.openWithUniversal()
    }
    if let mkInfo = message?.mkInfo {
      mainStore.dispatch(ClickMarketing(type: mkInfo.type, id: mkInfo.id))
    }
  }
  
  func didClickOnTranslate(for message: CHMessage?) {
    guard var message = message else { return }
    
    if message.translateState == .original && message.translatedBlocks.count != 0 {
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
      .subscribe(onNext: { blocks in
        let transform = CustomBlockTransform(
          config: CHMessageParserConfig(font: UIFont.systemFont(ofSize: 15))
        )
        message.translatedBlocks = blocks.compactMap { transform.transformFromJSON($0.toJSON()) }
        message.translateState = .translated
        mainStore.dispatchOnMain(UpdateMessage(payload: message))
      }, onError: { (error) in
        message.translateState = .failed
        mainStore.dispatchOnMain(UpdateMessage(payload: message))
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnRightNaviItem(from view: UIViewController?) {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
    ChannelIO.close(animated: true)
  }
  
  func didClickOnNewChat(with text: String, from view: UINavigationController?) {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
    self.router?.showNewChat(with: text, from: view)
  }
  
  func didClickOnClipButton(from view: UIViewController?) {
    guard let interactor = self.interactor else { return }
    
    self.router?
      .showOptionActionSheet(from: view)
      .subscribe(onNext: { [weak self] assets in
        guard let self = self else { return }
        interactor
        .createChatIfNeeded()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] (chat) in
          guard let self = self, let chat = chat else { return }
          self.userChatId = chat.id
          self.userChat = chat
          self.joinSocket()
          self.observeFileQueue()
          let files = assets.map { CHFile(asset: $0) }
          self.uploadFile(files: files)
        }, onError: { [weak self] (error) in
          self?.view?.display(error: error.localizedDescription, visible: false)
        }).disposed(by: self.disposeBag)
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnSendButton(text: String) {
    self.interactor?
    .createChatIfNeeded()
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { [weak self] (chat) in
      guard let chat = chat else { return }
      self?.userChatId = chat.id
      self?.userChat = chat
      self?.joinSocket()
      let message = CHMessage.createLocal(chatId: chat.id, text: text)
      mainStore.dispatch(CreateMessage(payload: message))
      self?.observeFileQueue()
      self?.sendMessage(with: message)
    }, onError: { [weak self] (error) in
      self?.view?.display(error: error.localizedDescription, visible: false)
    }).disposed(by: self.disposeBag)
  }
  
  func didClickOnRetryFile(with item: ChatFileQueueItem) {
    guard
      let queueKey = self.queueKey,
      let queue = ChatQueueService.shared.find(key: queueKey) else {
      return
    }
    queue.remove(item: item)
    item.status = .initial
    queue.enqueue(item: item)
  }
  
  func didClickOnRemoveFile(with item: ChatFileQueueItem) {
    guard
      let queueKey = self.queueKey,
      let queue = ChatQueueService.shared.find(key: queueKey) else {
      return
    }
    queue.remove(item: item)
    self.displayFileStatus(with: queue.items)
  }
  
  private func uploadFile(files: [CHFile]) {
    self.interactor?
      .upload(files: files)
      .subscribe()
      .disposed(by: self.disposeBag)
  }
  
  private func sendMessage(with message: CHMessage) {
    self.interactor?
      .send(message: message)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (message) in
        mainStore.dispatch(CreateMessage(payload: message))
      }, onError: { [weak self] (error) in
        self?.view?.display(error: error.localizedDescription, visible: false)
      }).disposed(by: self.disposeBag)
  }
  
  func sendFiles(fileDictionary: [String: Any]?) {
    let message = CHMessage(
      chatId: self.userChatId ?? "",
      user: mainStore.state.user,
      fileDictionary: fileDictionary
    )
    self.sendMessage(with: message)
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
      self.view?.display(typers: self.typingPersons)
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
     
    self.sendMessage(with: message)
  }
   
  private func processSupportBotAction(originId: String?, key: String?, value: String?) {
    guard !self.isRequestingAction else { return }
    self.isRequestingAction = true
     
    self.interactor?
      .createSupportBotChatIfNeeded(originId: originId)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] (chat, message) -> Observable<CHMessage> in
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
      }
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
        .close(actionId: origin.id, requestId: message?.requestId ?? "")
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
          actionId: origin.id,
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
