//
//  LoungePresenter.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import RxSwift
import RxSwiftExt

class LoungePresenter: NSObject, LoungePresenterProtocol {
  weak var view: LoungeViewProtocol?
  var interactor: LoungeInteractorProtocol?
  var router: LoungeRouterProtocol?
  
  var needToFetch = false
  var chatId: String?
  
  var disposeBag = DisposeBag()
  var notiDisposeBag = DisposeBag()
  var errorSignal = PublishSubject<Any?>()
  
  func viewDidLoad() {
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
    
    self.interactor?.updateExternalSource()
      .observeOn(MainScheduler.instance)
      .debounce(1, scheduler: MainScheduler.instance)
      .subscribe(onNext: { (sources) in
        //
        //    let sources = LoungeExternalSourceModel
        //      .generate(with: mainStore.state.channel, thirdparties: [])
        //    self?.view?.displayExternalSources(with: sources)
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateGeneralInfo()
      .observeOn(MainScheduler.instance)
      .debounce(1, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, plugin) in
        //NOTE: check if entities have been changed
        let followers = mainStore.state.managersState.followingManagers
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: plugin,
          followers: followers
        )
        self?.view?.displayHeader(with: headerModel)
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateChats()
      .observeOn(MainScheduler.instance)
      .debounce(1, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chats) in
        guard let `self` = self else { return }
        //guard !chats.elementsEqual(self.chats) else { return }
        //userchat has been change
        //welcome message has been changed
        let models = chats.map { UserChatCellModel(userChat: $0) }
        self.view?.displayMainContent(
          with: models,
          welcomeModel: UserChatCellModel.welcome(
            with: mainStore.state.channel,
            guest: mainStore.state.guest,
            supportBotMessage: supportBotEntrySelector(state: mainStore.state)
          ))
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
    self.interactor?.subscribeDataSource()
  }
  
  func cleanup() {
    self.interactor?.unsubscribeDataSource()
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
  
  func didClickOnChat(with chatId: String?, from view: UIViewController?) {
    self.router?.pushChat(with: chatId, from: view)
  }
  
  func didClickOnNewChat(from view: UIViewController?) {
    self.router?.pushChat(with: nil, from: view)
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
    
    Observable.zip(interactor.getChannel(), interactor.getPlugin(), interactor.getFollowers())
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, pluginInfo, followers) in
        mainStore.dispatch(GetPlugin(plugin: pluginInfo.0, bot: pluginInfo.1))
        mainStore.dispatch(UpdateFollowingManagers(payload: followers))

        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: pluginInfo.0,
          followers: followers
        )
        self?.view?.displayHeader(with: headerModel)
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
        self?.view?.displayMainContent(
          with: models,
          welcomeModel: UserChatCellModel.welcome(
            with: mainStore.state.channel,
            guest: mainStore.state.guest,
            supportBotMessage: supportBotEntrySelector(state: mainStore.state)
          ))
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
        let sources = LoungeExternalSourceModel
          .generate(with: mainStore.state.channel, thirdParties: sources)
        self?.view?.displayExternalSources(with: sources)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .externalSource)
      }).disposed(by: self.disposeBag)
  }
}
