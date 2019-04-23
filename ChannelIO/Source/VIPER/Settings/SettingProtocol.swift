//
//  SettingProtocol.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingViewProtocol: class {
  var presenter: SettingPresenterProtocol? { get set }
  
  func displayHeader(with model: SettingHeaderViewModel)
  func displayOptions(with options: [SettingOptionModel])
  func displayProfiles(with profiles: [GuestProfileItemModel])
  func displayVersion(version: String)
}

protocol SettingPresenterProtocol: class {
  var view: SettingViewProtocol? { get set }
  var interactor: SettingInteractorProtocol? { get set }
  var router: SettingRouterProtocol? { get set }
  
  func viewDidLoad()
  func prepare()
  func cleanup()
  
  func didClickOnOption(item: SettingOptionModel, nextValue: Any?, from view: UIViewController?)
  func didClickOnProfileSchema(with item: GuestProfileItemModel, from view: UIViewController?)
}

protocol SettingInteractorProtocol {
  var presenter: SettingPresenterProtocol? { get set }
  
  func subscribeDataSource()
  func unsubscribeDataSource()
  
  func getChannel() -> Observable<CHChannel>
  func getProfileSchemas() -> Observable<[CHProfileSchema]>
  func getCurrentLocale() -> CHLocale?
  func getTranslationEnabled() -> Bool
}

protocol SettingRouterProtocol {
  
  func pushLanguageSelector(from view: UIViewController?)
  func pushProfileSchemaEditor(with item: GuestProfileItemModel, from view: UIViewController?)
  
  static func createModule() -> SettingView
}
