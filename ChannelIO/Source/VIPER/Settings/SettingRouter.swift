//
//  SettingRouter.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

class SettingRouter: SettingRouterProtocol {
  func pushLanguageSelector(from view: UIViewController?) {
    let viewController = LanguageOptionViewController()
    view?.navigationController?.pushViewController(viewController, animated: true)
  }
  
  func pushProfileSchemaEditor(with item: UserProfileItemModel, from view: UIViewController?) {
    var type: EditFieldType
    if item.rawData.key == "mobileNumber" {
      type = .phone
    } else if item.profileType == .number {
      type = .number
    } else {
      type = .text
    }
    let viewController = ProfileEditorViewController(type: type, user: mainStore.state.user, schema: item.rawData)
    view?.navigationController?.pushViewController(viewController, animated: true)
  }
  
  static func createModule() -> SettingView {
    let view = SettingView()
    let interactor = SettingInteractor()
    let router = SettingRouter()
    let presenter = SettingPresenter()
    
    presenter.view = view
    presenter.router = router
    presenter.interactor = interactor
    
    view.presenter = presenter
    interactor.presenter = presenter
    
    return view
  }
}
