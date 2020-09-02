//
//  LoungePresenter.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import RxSwift
import RxSwiftExt
import RxCocoa
import JGProgressHUD

class LoungePresenter: NSObject, LoungePresenterProtocol {
  weak var view: LoungeViewProtocol?
  var interactor: LoungeInteractorProtocol?
  var router: LoungeRouterProtocol?
  
  var needToFetch = false
  var chatId: String?
  var preloadText: String?
  var isOpenChat: Bool = false
  
  var disposeBag = DisposeBag()
  var notiDisposeBag = DisposeBag()
  
  var errorSignal = PublishSubject<Any?>()
  
  var loungeCompletion = BehaviorRelay<Bool>(value: false)
  
  var locale: CHLocaleString? = ChannelIO.bootConfig?.appLocale
  
  func viewDidLoad() {
    self.updateHeaders()
    self.fetchLoungeData()
    
    CHNotification.shared.refreshSignal
      .subscribe(onNext: { [weak self] (_) in
        self?.fetchLoungeData()
        CHNotification.shared.dismiss()
      }).disposed(by: self.disposeBag)
    
    WsService.shared.error()
      .observeOn(MainScheduler.instance)
      .bind(to: self.errorSignal)
      .disposed(by: self.disposeBag)
    
    self.errorSignal
      .debounce(.seconds(1), scheduler: MainScheduler.instance)
      .subscribe(onNext: { (_) in
        CHNotification.shared.display(
          message: CHAssets.localized("ch.toast.unstable_internet"),
          config: CHNotificationConfiguration.warningConfig
        )
      }).disposed(by: self.disposeBag)
  }
  
  private func updateHeaders() {
    let operators = mainStore.state.managersState.followingManagers
    let headerModel = LoungeHeaderViewModel(
      chanenl: mainStore.state.channel,
      plugin: mainStore.state.plugin,
      operators: operators
    )
    self.view?.displayHeader(with: headerModel)
  }
  
  func prepare(fetch: Bool = false) {
    if self.needToFetch || fetch {
      self.needToFetch = false
      self.fetchLoungeData()
    }
    
    //handle showUserChat
    if let chatId = self.chatId, let view = self.view as? UIViewController {
      self.view?.setViewVisible(false)
      self.router?.pushChat(
        with: chatId,
        text: self.preloadText,
        isOpenChat: false,
        animated: false,
        from: view
      )
      self.chatId = nil
      self.isOpenChat = false
    } else if self.chatId == nil,
      self.isOpenChat == true,
      let view = self.view as? UIViewController {
      self.view?.setViewVisible(false)
      self.router?.pushChat(
        with: chatId,
        text: self.preloadText,
        isOpenChat: self.preloadText != nil,
        animated: false,
        from: view
      )
      self.chatId = nil
      self.isOpenChat = false
    } else {
      self.view?.setViewVisible(true)
      self.view?.displayReady()
    }
    
    if self.locale != ChannelIO.bootConfig?.appLocale {
      self.locale = ChannelIO.bootConfig?.appLocale
      self.view?.reloadContents()
    }
    
    self.initObservers()
    self.interactor?.subscribeDataSource()
  }
  
  func cleanup() {
    self.notiDisposeBag = DisposeBag()
    self.interactor?.unsubscribeDataSource()
  }
  
  func initObservers() {
    ChannelAvailabilityChecker.shared.updateSignal
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] (_) -> Observable<CHChannel> in
        return self?.interactor?.getChannel() ?? .empty()
      }
      .subscribe(onNext: { [weak self] (channel) in
        mainStore.dispatch(UpdateChannel(payload: channel))
        guard let self = self else { return }
        //update headers
        let operators = mainStore.state.managersState.followingManagers
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: mainStore.state.plugin,
          operators: operators
        )
        self.view?.displayHeader(with: headerModel)
        
        self.updateMainContent()
      }).disposed(by: self.notiDisposeBag)
    
    self.interactor?.updateGeneralInfo()
      .observeOn(MainScheduler.instance)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, plugin) in
        self?.updateHeaders()
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateChats()
      .observeOn(MainScheduler.instance)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chats) in
        if self?.loungeCompletion.value == true {
          self?.updateMainContent()
        }
      }).disposed(by: self.disposeBag)
  }
  
  func updateMainContent() {
    let models = userChatsSelector(state: mainStore.state, showCompleted: true)
      .map { UserChatCellModel(userChat: $0) }
    
    let welcomeModel = UserChatCellModel.getWelcomeModel(
      with: mainStore.state.plugin,
      user: mainStore.state.user,
      supportBotMessage: supportBotEntrySelector(state: mainStore.state)
    )
    
    self.view?.displayMainContent(
      activeChats: models.filter { !$0.isClosed },
      inactiveChats: showCompletedChatsSelector(state: mainStore.state) ?
        models.filter { $0.isClosed } : [],
      welcomeModel: welcomeModel)
  }
  
  func isReadyToPresentChat(chatId: String?) -> Single<Any?> {
    return Single<Any?>.create { [weak self] subscriber in
      guard let self = self, let interactor = self.interactor else {
        subscriber(.error(ChannelError.unknownError))
        return Disposables.create()
      }
      
      guard chatId != nil else {
        subscriber(.success(nil))
        return Disposables.create()
      }
      
      self.view?.showHUD()
      
      let signal = Observable
        .zip(
          interactor.getLounge(),
          interactor.getChats()
        )
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (info, chatData) in
          guard
            let channel = info.channel,
            let plugin = info.plugin,
            let bot = info.bot,
            let operators = info.operators else {
              subscriber(.error(ChannelError.notFoundError))
              self.view?.dismissHUD()
              return
          }
          
          mainStore.dispatch(
            UpdateLoungeInfo(
              channel: channel,
              plugin: plugin,
              bot: bot,
              operators: operators,
              supportBotEntryInfo: info.supportBotEntryInfo,
              userChats: chatData
            )
          )
          subscriber(.success(nil))
          self.view?.dismissHUD()
        }, onError: { (error) in
          subscriber(.error(error))
          self.view?.dismissHUD()
        })
      
      return Disposables.create{
        signal.dispose()
      }
    }
  }
  
  func fetchChatIfNeeded(chatId: String? = nil) -> Observable<ChatResponse?> {
    return Observable.create { subscriber in
      let chat = userChatSelector(state: mainStore.state, userChatId: chatId)
      guard let chatId = chatId else {
        subscriber.onNext(nil)
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      guard chat == nil else {
        subscriber.onNext(nil)
        subscriber.onCompleted()
        return Disposables.create()
      }
      
      let signal = CHUserChat.get(userChatId: chatId)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          dlog("Error while fetching chat. Attempting to fetch again")
          return true
        })
        .subscribe(onNext: { (response) in
          subscriber.onNext(response)
          subscriber.onCompleted()
        }, onError: { (error) in
          subscriber.onError(error)
        })
     
     return Disposables.create {
       signal.dispose()
     }
    }
  }
  
  func didClickOnRefresh() {
    self.fetchLoungeData()
  }
  
  func didClickOnSetting(from view: UIViewController?) {
    self.router?.pushSettings(from: view)
  }
  
  func didClickOnDismiss() {
    ChannelIO.hideMessenger()
  }
  
  func didClickOnChat(with chatId: String?, animated: Bool, from view: UIViewController?) {
    self.pushChat(with: chatId, animated: animated, from: view)
  }
  
  func didClickOnNewChat(from view: UIViewController?) {
    self.pushChat(with: self.chatId, animated: true, from: view)
  }
  
  func didClickOnSeeMoreChat(from view: UIViewController?) {
    self.router?.pushChatList(from: view)
  }
  
  func didClickOnHelp(from view: UIViewController?) {
    self.router?.presentBusinessHours(from: view)
  }
  
  func didClickOnExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?) {
    self.router?.presentExternalSource(with: source, from: view)
  }
  
  func didClickOnDelete(chatId: String?) {
    guard
      let userChat = userChatSelector(state: mainStore.state, userChatId: chatId),
      let interactor = self.interactor else { return }
    
    interactor.deleteChat(userChat: userChat)
      .subscribe(onNext: { [weak self] (chat) in
        mainStore.dispatch(DeleteUserChat(payload: userChat))
        self?.updateMainContent()
      }, onError: { (error) in
        
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnWatermark() {
    let channel = mainStore.state.channel
    let channelName = channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    let urlString = CHUtils.getUrlForUTM(source: "plugin_watermark", content: channelName)
    
    if let url = URL(string: urlString) {
      url.open()
    }
  }
}

extension LoungePresenter {
  private func fetchLoungeData() {
    guard let interactor = self.interactor else { return }
    
    Observable
      .zip(
        interactor.getLounge(),
        interactor.getChats()
      )
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (info, chatData) in
        guard
          let channel = info.channel,
          let plugin = info.plugin,
          let bot = info.bot,
          let operators = info.operators else {
            self?.view?.displayError()
            self?.loungeCompletion.accept(false)
            return
        }
        
        mainStore.dispatch(
          UpdateLoungeInfo(
            channel: channel,
            plugin: plugin,
            bot: bot,
            operators: operators,
            supportBotEntryInfo: info.supportBotEntryInfo,
            userChats: chatData
          )
        )

        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: plugin,
          operators: operators
        )
        
        self?.view?.displayHeader(with: headerModel)
        self?.updateMainContent()
        
        let sources = LoungeExternalSourceModel.generate(
          with: mainStore.state.channel,
          plugin: mainStore.state.plugin,
          appMessengers: info.appMessengers
        )
        self?.view?.displayExternalSources(with: sources)
        
        self?.loungeCompletion.accept(true)
      }, onError: { [weak self] (_) in
        self?.view?.displayError()
        self?.loungeCompletion.accept(false)
      }).disposed(by: self.disposeBag)
  }
  
  private func pushChat(with chatId: String?, isOpenChat: Bool = false, animated: Bool, from view: UIViewController?) {
    self.router?.pushChat(with: chatId, text: nil, isOpenChat: isOpenChat, animated: animated, from: view)
  }
}
