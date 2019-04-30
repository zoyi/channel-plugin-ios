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
  
  var chatId: String?
  
  var disposeBag = DisposeBag()
  
  func viewDidLoad() {
    self.fetchData()
    
    NotificationCenter.default.rx
      .notification(UIApplication.didBecomeActiveNotification)
      .takeUntil(self.rx.deallocated)
      .subscribe(onNext: { [weak self] (_) in
        self?.fetchData()
      }).disposed(by: self.disposeBag)
  }
  
  func fetchData() {
    guard let interactor = interactor else { return }
    let pluginSignal = interactor.getPlugin()
    let channelSignal = interactor.getChannel()
    let followersSignal = interactor.getFollowers()
    let chatSignal = interactor.getChats()
    
    Observable.zip(channelSignal, pluginSignal, followersSignal, chatSignal)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching data... retrying.. in 3 seconds")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, plugin, followers, chats) in
        let headerModel = LoungeHeaderViewModel(
          chanenl: channel,
          plugin: plugin,
          followers: followers
        )
        let sources = LoungeExternalSourceViewModel()
        let models = chats.map { UserChatCellModel(userChat: $0) }
        
        self?.view?.displayHeader(with: headerModel)
        self?.view?.displayMainContent(
          with: models,
          welcomeModel: UserChatCellModel.welcome(
            with: mainStore.state.channel,
            guest: mainStore.state.guest
          )
        )

        self?.view?.displayExternalSources(with: sources)
        self?.view?.displayReady()
      }).disposed(by: self.disposeBag)
  }
  
  func prepare() {
    
  }
  
  func cleanup() {
    
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
    //?
  }
  
  func didClickOnWatermark() {
    //open url?
  }
}
