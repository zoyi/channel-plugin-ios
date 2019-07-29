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

class LoungePresenter: NSObject, LoungePresenterProtocol {
  weak var view: LoungeViewProtocol?
  var interactor: LoungeInteractorProtocol?
  var router: LoungeRouterProtocol?
  
  var needToFetch = false
  var chatId: String?
  var externalSources: [LoungeExternalSourceModel] = []
  
  var disposeBag = DisposeBag()
  var notiDisposeBag = DisposeBag()
  
  var errorSignal = PublishSubject<Any?>()
  
  var headerCompletion = PublishRelay<Any?>()
  var mainCompletion = PublishRelay<Any?>()
  var externalCompletion = PublishRelay<Any?>()
  
  var locale: CHLocaleString? = ChannelIO.settings?.appLocale
  
  func viewDidLoad() {
    self.fetchData()
    
    CHNotification.shared.refreshSignal
      .subscribe(onNext: { [weak self] (_) in
        self?.fetchData()
        CHNotification.shared.dismiss()
      }).disposed(by: self.disposeBag)
    
    WsService.shared.error()
      .observeOn(MainScheduler.instance)
      .bind(to: self.errorSignal)
      .disposed(by: self.disposeBag)
    
    self.errorSignal
      .debounce(1.0, scheduler: MainScheduler.instance)
      .subscribe(onNext: { (_) in
        CHNotification.shared.display(
          message: CHAssets.localized("ch.toast.unstable_internet"),
          config: CHNotificationConfiguration.warningConfig
        )
      }).disposed(by: self.disposeBag)
    
//    self.interactor?.updateExternalSource()
//      .observeOn(MainScheduler.instance)
//      .debounce(1, scheduler: MainScheduler.instance)
//      .subscribe(onNext: { [weak self] (sources) in
//        let sources = LoungeExternalSourceModel.generate(
//          with: mainStore.state.channel,
//          plugin: mainStore.state.plugin,
//          thirdParties: [:])
//        self?.view?.displayExternalSources(with: sources)
//      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateGeneralInfo()
      .observeOn(MainScheduler.instance)
      .debounce(0.5, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, plugin) in
        //NOTE: check if entities have been changed
        guard let `self` = self else { return }
        let followers = mainStore.state.managersState.followingManagers
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: plugin,
          followers: followers
        )
        self.view?.displayHeader(with: headerModel)
        
        let models = userChatsSelector(state: mainStore.state, showCompleted: true)
          .map { UserChatCellModel(userChat: $0) }

        let welcome = UserChatCellModel.welcome(
          with: mainStore.state.plugin,
          guest: mainStore.state.guest,
          supportBotMessage: supportBotEntrySelector(state: mainStore.state)
        )
        
        self.view?.displayMainContent(
          activeChats: models.filter { !$0.isClosed },
          inactiveChats: models.filter { $0.isClosed },
          welcomeModel: welcome)
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateChats()
      .observeOn(MainScheduler.instance)
      .debounce(0.5, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chats) in
        guard let `self` = self else { return }
        let models = chats.map { UserChatCellModel(userChat: $0) }
        let welcome = UserChatCellModel.welcome(
          with: mainStore.state.plugin,
          guest: mainStore.state.guest,
          supportBotMessage: supportBotEntrySelector(state: mainStore.state)
        )
        
        self.view?.displayMainContent(
          activeChats: models.filter { !$0.isClosed },
          inactiveChats: models.filter { $0.isClosed },
          welcomeModel: welcome)
      }).disposed(by: self.disposeBag)
  }
  
  func fetchData() {
    self.loadHeaderInfo()
    self.loadMainContents()
    self.loadExternalSources()
  }
  
  func prepare(fetch: Bool = false) {
    if self.needToFetch || fetch {
      self.needToFetch = false
      self.fetchData()
    }
    
    //handle showUserChat
    if let chatId = chatId, let view = self.view as? UIViewController {
      self.didClickOnChat(with: chatId, animated: false, from: view)
      self.chatId = nil
    } else {
      //self.view?.displayReady()
    }
    
    if self.locale != ChannelIO.settings?.appLocale {
      self.locale = ChannelIO.settings?.appLocale
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
      .flatMap({ [weak self] (_) -> Observable<CHChannel> in
        return self?.interactor?.getChannel() ?? .empty()
      })
      .subscribe(onNext: { [weak self] (channel) in
        mainStore.dispatch(UpdateChannel(payload: channel))
        guard let `self` = self else { return }
        //update headers
        let followers = mainStore.state.managersState.followingManagers
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: mainStore.state.plugin,
          followers: followers
        )
        self.view?.displayHeader(with: headerModel)
        
        //update main
        let models = userChatsSelector(state: mainStore.state, showCompleted: true)
          .map { UserChatCellModel(userChat: $0) }
        
        let welcome = UserChatCellModel.welcome(
          with: mainStore.state.plugin,
          guest: mainStore.state.guest,
          supportBotMessage: supportBotEntrySelector(state: mainStore.state)
        )

        self.view?.displayMainContent(
          activeChats: models.filter { !$0.isClosed },
          inactiveChats: models.filter { $0.isClosed },
          welcomeModel: welcome)
      }).disposed(by: self.notiDisposeBag)
    
    Observable.combineLatest(self.headerCompletion, self.mainCompletion, self.externalCompletion)
      .subscribe(onNext: { [weak self] (_, _, _) in
        self?.view?.displayReady()
      }).disposed(by: self.disposeBag)
  }
  
  func didClickOnRefresh(for type: LoungeSectionType) {
    switch type {
    case .header:
      self.loadHeaderInfo()
    case .mainContent:
      self.loadHeaderInfo()
      self.loadMainContents()
    case .externalSource:
      self.loadExternalSources()
    }
  }
  
  func didClickOnSetting(from view: UIViewController?) {
    self.router?.pushSettings(from: view)
  }
  
  func didClickOnDismiss() {
    ChannelIO.close(animated: true)
  }
  
  func didClickOnChat(with chatId: String?, animated: Bool, from view: UIViewController?) {
    self.router?.pushChat(with: chatId, animated: animated, from: view)
  }
  
  func didClickOnNewChat(from view: UIViewController?) {
    self.router?.pushChat(with: nil, animated: true, from: view)
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
      .subscribe(onNext: { (chat) in
        mainStore.dispatch(DeleteUserChat(payload: userChat))
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
  func loadHeaderInfo() {
    guard let interactor = self.interactor else { return }
    
    Observable.zip(interactor.getChannel(), interactor.getPlugin(), interactor.getOperators())
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, pluginInfo, followers) in
        mainStore.dispatch(UpdateChannel(payload: channel))
        mainStore.dispatch(GetPlugin(plugin: pluginInfo.0, bot: pluginInfo.1))
        mainStore.dispatch(UpdateFollowingManagers(payload: followers))

        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: pluginInfo.0,
          followers: followers
        )
        self?.view?.displayHeader(with: headerModel)
        self?.headerCompletion.accept(nil)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .header)
      }).disposed(by: self.disposeBag)
  }
  
  func loadMainContents() {
    guard let interactor = self.interactor else { return }
    
    Observable.zip(interactor.getChats(), interactor.getSupportBot())
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chats, entry) in
        let models = chats.map { UserChatCellModel(userChat: $0) }
        let welcome = UserChatCellModel.welcome(
          with: mainStore.state.plugin,
          guest: mainStore.state.guest,
          supportBotMessage: supportBotEntrySelector(state: mainStore.state)
        )

        self?.view?.displayMainContent(
          activeChats: models.filter { !$0.isClosed },
          inactiveChats: models.filter { $0.isClosed },
          welcomeModel: welcome)

        self?.mainCompletion.accept(nil)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .mainContent)
      }).disposed(by: self.disposeBag)
  }
  
  func loadExternalSources() {
    guard let interactor = self.interactor else { return }
    
    interactor.getExternalSource()
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (sources) in
        let sources = LoungeExternalSourceModel.generate(
          with: mainStore.state.channel,
          plugin: mainStore.state.plugin,
          thirdParties: sources)
        self?.externalSources = sources
        self?.view?.displayExternalSources(with: sources)
        self?.externalCompletion.accept(nil)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .externalSource)
      }).disposed(by: self.disposeBag)
  }
}
