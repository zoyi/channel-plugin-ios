//
//  SettingProtocol.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

protocol SettingViewProtocol: class {
  var presenter: SettingPresenterProtocol? { get set }
  
  func displayHeader(with model: SettingHeaderViewModel)
  func displayOptions(with options: [SettingOptionModel])
  func displayProfiles(with profiles: [UserProfileItemModel])
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
  func didClickOnProfileSchema(with item: UserProfileItemModel, from view: UIViewController?)
}

protocol SettingInteractorProtocol {
  var presenter: SettingPresenterProtocol? { get set }
  
  func subscribeDataSource()
  func unsubscribeDataSource()
  
  func getChannel() -> _RXSwift_Observable<CHChannel>
  func getProfileSchemas() -> _RXSwift_Observable<[CHProfileSchema]>
  func getTranslationEnabled() -> Bool
  
  func updateGeneral() -> _RXSwift_Observable<(CHChannel, CHPlugin)>
  func updateUser() -> _RXSwift_Observable<CHUser>
  func updateOptions() -> _RXSwift_Observable<Any?>
  func updateUserUnsubscribed(with unsubscribed: Bool)
}

protocol SettingRouterProtocol {
  
  func pushLanguageSelector(from view: UIViewController?)
  func pushProfileSchemaEditor(with item: UserProfileItemModel, from view: UIViewController?)
  
  static func createModule() -> SettingView
}
