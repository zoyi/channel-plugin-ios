//
//  SettingRouter.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

class SettingRouter: SettingRouterProtocol {
  private var isPushing = false
  
  func pushLanguageSelector(from view: UIViewController?) {
    guard !isPushing else { return }
    self.isPushing = true
    let viewController = LanguageOptionViewController()
    view?.navigationController?
      .pushViewController(viewController: viewController, animated: true) { [weak self] in
      self?.isPushing = false
    }
  }
  
  func pushProfileSchemaEditor(with item: UserProfileItemModel, from view: UIViewController?) {
    guard !isPushing else { return }
    self.isPushing = true
    var type: EditFieldType
    if item.rawData.key == "mobileNumber" {
      type = .phone
    } else if item.profileType == .number {
      type = .number
    } else if item.profileType == .boolean {
      type = .boolean
    } else if item.profileType == .date {
      type = .date
    } else {
      type = .text
    }
    
    let viewController = ProfileEditorViewController(
      type: type,
      user: mainStore.state.user,
      schema: item.rawData
    )
    view?.navigationController?
      .pushViewController(viewController: viewController, animated: true)  { [weak self] in
      self?.isPushing = false
    }
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
