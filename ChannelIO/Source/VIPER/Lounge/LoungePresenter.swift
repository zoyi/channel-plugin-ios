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
import SVProgressHUD

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
    self.updateHeaders()
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
      self.view?.setViewVisible(false)
      self.router?.pushChat(with: chatId, animated: false, from: view)
      self.chatId = nil
    } else {
      self.view?.setViewVisible(true)
      self.view?.displayReady()
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
        guard let self = self else { return }
        //update headers
        let operators = mainStore.state.managersState.followingManagers
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: mainStore.state.plugin,
          operators: operators
        )
        self.view?.displayHeader(with: headerModel)
        
        //update main
        self.updateMainContent()
      }).disposed(by: self.notiDisposeBag)
    
    self.interactor?.updateGeneralInfo()
      .observeOn(MainScheduler.instance)
      .debounce(0.5, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, plugin) in
        self?.updateHeaders()
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateChats()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chats) in
        guard let self = self else { return }
        self.updateMainContent()
      }, onError: { (error) in
          
      }).disposed(by: self.disposeBag)
  }
  
  func updateMainContent() {
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
  }
  
  func isReadyToPresentChat(chatId: String?) -> Single<Any?> {
    return Single<Any?>.create { subscriber in
      guard chatId != nil else {
        subscriber(.success(nil))
        return Disposables.create()
      }
      
      let pluginSignal = CHPlugin.get(with: mainStore.state.plugin.id)
      let supportSignal =  CHSupportBot.get(with: mainStore.state.plugin.id, fetch: true)
      
      //plugin may not need
      let signal = Observable.zip(pluginSignal, supportSignal)
        .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
          let reloadMessage = CHAssets.localized("plugin.reload.message")
          SVProgressHUD.show(withStatus: reloadMessage)
          return true
        })
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (plugin, entry) in
          mainStore.dispatch(GetSupportBotEntry(bot: plugin.1, entry: entry))
          subscriber(.success(nil))
        }, onError: { (error) in
          subscriber(.error(error))
        })
      
      return Disposables.create{
        signal.dispose()
      }
    }
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
    self.pushChat(with: chatId, animated: animated, from: view)
  }
  
  func didClickOnNewChat(from view: UIViewController?) {
    self.pushChat(with: chatId, animated: true, from: view)
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
  private func pushChat(with chatId: String?, animated: Bool, from view: UIViewController?) {
    let pluginSignal = CHPlugin.get(with: mainStore.state.plugin.id)
    let supportSignal =  CHSupportBot.get(with: mainStore.state.plugin.id, fetch: chatId == nil)
    
    //plugin may not need
    Observable.zip(pluginSignal, supportSignal)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        let reloadMessage = CHAssets.localized("plugin.reload.message")
        SVProgressHUD.show(withStatus: reloadMessage)
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (plugin, entry) in
        mainStore.dispatch(GetSupportBotEntry(bot: plugin.1, entry: entry))
        SVProgressHUD.dismiss()
        self.router?.pushChat(with: chatId, animated: animated, from: view)
        //view?.navigationController?.pushViewController(chatView, animated: animated)
      }, onError: { (error) in
        SVProgressHUD.dismiss()
      }).disposed(by: self.disposeBag)
  }
  
  private func loadHeaderInfo() {
    guard let interactor = self.interactor else { return }
    
    Observable.zip(interactor.getChannel(), interactor.getPlugin(), interactor.getOperators())
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, pluginInfo, operators) in
        mainStore.dispatch(
          UpdateLoungeInfo(
            channel: channel,
            plugin: pluginInfo.0,
            bot: pluginInfo.1,
            operators: operators
          ))
        
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: pluginInfo.0,
          operators: operators
        )
        self?.view?.displayHeader(with: headerModel)
        self?.headerCompletion.accept(nil)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .header)
      }).disposed(by: self.disposeBag)
  }
  
  private func loadMainContents() {
    guard let interactor = self.interactor else { return }
    
    Observable.zip(interactor.getChats(), interactor.getSupportBot())
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chats, entry) in
        self?.updateMainContent()
        self?.mainCompletion.accept(nil)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .mainContent)
      }).disposed(by: self.disposeBag)
  }
  
  private func loadExternalSources() {
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
