//
//  SettingPresenter.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

class SettingPresenter: NSObject, SettingPresenterProtocol {
  weak var view: SettingViewProtocol?
  var interactor: SettingInteractorProtocol?
  var router: SettingRouterProtocol?
  
  var schemas: [CHProfileSchema] = []
  
  var disposeBag = _RXSwift_DisposeBag()
  
  func viewDidLoad() {
    if let version = CHUtils.getSdkVersion() {
      self.view?.displayVersion(version: "v\(version)")
    }
    
    self.interactor?.updateGeneral()
      .observeOn(_RXSwift_MainScheduler.instance)
      .subscribe(onNext: { [weak self] (channel, plugin) in
        let headerModel = SettingHeaderViewModel(channel: channel, plugin: plugin)
        self?.view?.displayHeader(with: headerModel)
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateOptions()
      .debounce(.seconds(1), scheduler: _RXSwift_MainScheduler.instance)
      .observeOn(_RXSwift_MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        let settingOptions = SettingOptionModel.generate(
          options: [.language, .closeChatVisibility, .translation, .marketingUnsubscribed])
        self?.view?.displayOptions(with: settingOptions)
      }).disposed(by: self.disposeBag)
    
    self.interactor?.updateUser()
      .observeOn(_RXSwift_MainScheduler.instance)
      .subscribe(onNext: { [weak self] (user) in
        let profiles = mainStore.state.user.profile
        let models = UserProfileItemModel.generate(
          from: profiles,
          schemas: self?.schemas ?? []
        )
        self?.view?.displayProfiles(with: models)
      }).disposed(by: self.disposeBag)
    
    self.interactor?.getProfileSchemas()
      .observeOn(_RXSwift_MainScheduler.instance)
      .subscribe(onNext: { [weak self] (schemas) in
        let profiles = mainStore.state.user.profile
        let models = UserProfileItemModel.generate(
          from: profiles,
          schemas: schemas
        )
        self?.schemas = schemas
        self?.view?.displayProfiles(with: models)
      }, onError: { (error) in
          
      }).disposed(by: self.disposeBag)
  }
  
  func prepare() {
    let settingOptions = SettingOptionModel.generate(options: [.language, .closeChatVisibility, .translation, .marketingUnsubscribed])
    self.view?.displayOptions(with: settingOptions)

    self.interactor?.subscribeDataSource()
  }
  
  func cleanup() {
    self.interactor?.unsubscribeDataSource()
  }
  
  func didClickOnOption(item: SettingOptionModel, nextValue: Any?, from view: UIViewController?) {
    if item.type == .language {
      self.router?.pushLanguageSelector(from: view)
    }
    else if item.type == .translation, let nextValue = nextValue as? Bool {
      mainStore.dispatch(UpdateVisibilityOfTranslation(show: nextValue))
    }
    else if item.type == .closeChatVisibility, let nextValue = nextValue as? Bool {
      mainStore.dispatch(UpdateVisibilityOfCompletedChats(show: nextValue))
    }
    else if item.type == .marketingUnsubscribed, let nextValue = nextValue as? Bool {
      self.interactor?.updateUserUnsubscribed(with: nextValue)
    }
  }
  
  func didClickOnProfileSchema(with item: UserProfileItemModel, from view: UIViewController?) {
    self.router?.pushProfileSchemaEditor(with: item, from: view)
  }
}
