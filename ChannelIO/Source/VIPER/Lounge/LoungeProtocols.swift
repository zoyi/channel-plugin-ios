//
//  MainProtocols.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

protocol LoungeViewProtocol: class {
  var presenter: LoungePresenterProtocol? { get set }
  
  func displayReady()
  func displayHeader(with model: LoungeHeaderViewModel)
  func displayMainContent(with chats: [UserChatCellModel], welcomeModel: UserChatCellModel?)
  func displayExternalSources(with model: LoungeExternalSourceViewModel)
}

protocol LoungePresenterProtocol: class {
  var view: LoungeViewProtocol? { get set }
  var interactor: LoungeInteractorProtocol? { get set }
  var router: LoungeRouterProtocol? { get set }
  
  func viewDidLoad()
  func prepare()
  func cleanup()
  
  func didClickOnSetting(from view: UIViewController?)
  func didClickOnDismiss()
  func didClickOnChat(with chatId: String?, from view: UIViewController?)
  func didClickOnNewChat(from view: UIViewController?)
  func didClickOnSeeMoreChat(from view: UIViewController?)
  
  func didClickOnExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?)
  func didClickOnWatermark()
}

protocol LoungeInteractorProtocol: class {
  var presenter: LoungePresenterProtocol? { get set }
  
  func subscribeDataSource()
  func unsubscribeDataSource()
  
  func getChannel() -> Observable<CHChannel>
  func getPlugin() -> Observable<(CHPlugin, CHBot?)>
  func getFollowers() -> Observable<[CHManager]>
  func getChats() -> Observable<[CHUserChat]>
}

protocol LoungeRouterProtocol: class {
  func pushChatList(from view: UIViewController?)
  func pushChat(with chatId: String?, from view: UIViewController?)
  func pushSettings(from view: UIViewController?)
  func presentEamilComposer(from view: UIViewController?)
  
  static func createModule(with chatId: String?) -> LoungeView
}
