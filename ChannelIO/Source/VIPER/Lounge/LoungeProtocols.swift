//
//  MainProtocols.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

protocol LoungeViewProtocol : class {
  var presenter: LoungePresenterProtocol? { get set }
  
  func displayHeader()
  func displayMainContent()
  func displayExternalSources()
}

protocol LoungePresenterProtocol {
  var view: LoungeViewProtocol? { get set }
  var interactor: LoungeInteractorProtocol? { get set }
  var router: LoungeRouterProtocol? { get set }
}

protocol LoungeInteractorProtocol {
  var presenter: LoungePresenterProtocol? { get set }
}

protocol LoungeRouterProtocol {
  func pushChat(with chat: CHUserChat?, from view: UIViewController?)
  func presentSettings(from view: UIViewController?)
}
