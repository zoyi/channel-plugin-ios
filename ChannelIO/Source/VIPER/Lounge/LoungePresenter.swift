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
  
  var once = false
  var two = false
  
  func viewDidLoad() {
    self.fetchData()
    
    NotificationCenter.default.rx
      .notification(UIApplication.willEnterForegroundNotification)
      .takeUntil(self.rx.deallocated)
      .subscribe(onNext: { [weak self] (_) in
        self?.needToFetch = true
      }).disposed(by: self.disposeBag)
  }
  
  func fetchData() {
    self.loadHeaderInfo()
    self.loadChats()
    self.loadExternalSources()
  }
  
  func prepare() {
    if self.needToFetch {
      self.fetchData()
    }
  }
  
  func cleanup() {
    
  }
  
  func didClickOnRefresh(for type: LoungeSectionType) {
    switch type {
    case .header:
      self.loadHeaderInfo()
    case .chats:
      self.loadHeaderInfo()
      self.loadChats()
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
  
  func didClickOnExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?) {
    self.router?.presentExternalSource(with: source, from: view)
  }
  
  func didClickOnWatermark() {
    //open url?
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
      .subscribe(onNext: { [weak self] (channel, pluginInfo, followers) in
        if self?.once == false {
          self?.once = true
          self?.view?.displayError(for: .header)
          return
        }
        
        mainStore.dispatchOnMain(GetPlugin(plugin: pluginInfo.0, bot: pluginInfo.1))
        mainStore.dispatchOnMain(UpdateFollowingManagers(payload: followers))

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
  
  func loadChats() {
    guard let interactor = self.interactor else { return }
    
    interactor.getChats()
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .subscribe(onNext: { [weak self] (chats) in
        if self?.two == false {
          self?.two = true
          self?.view?.displayError(for: .chats)
          return
        }
        
        let models = chats.map { UserChatCellModel(userChat: $0) }
        self?.view?.displayMainContent(
          with: models,
          welcomeModel: UserChatCellModel.welcome(
            with: mainStore.state.channel,
            guest: mainStore.state.guest
          ))
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .chats)
      }).disposed(by: self.disposeBag)
  }
  
  func loadExternalSources() {
    guard let interactor = self.interactor else { return }
    
    interactor.getExternalSource()
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .subscribe(onNext: { [weak self] (sources) in
        self?.view?.displayError(for: .externalSource)
        //
        //    let sources = LoungeExternalSourceModel
        //      .generate(with: mainStore.state.channel, thirdparties: [])
        //    self?.view?.displayExternalSources(with: sources)
      }, onError: { [weak self] (error) in
        self?.view?.displayError(for: .externalSource)
      }).disposed(by: self.disposeBag)
  }
}
