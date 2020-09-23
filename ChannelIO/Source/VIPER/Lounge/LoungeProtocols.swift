//
//  MainProtocols.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

enum LoungeSectionType {
  case header
  case mainContent
  case externalSource
}

protocol LoungeViewProtocol: class {
  var presenter: LoungePresenterProtocol? { get set }
  
  func reloadContents()
  
  func displayReady()
  func setViewVisible(_ value: Bool)
  func displayHeader(with model: LoungeHeaderViewModel)
  func displayMainContent(activeChats: [UserChatCellModel], inactiveChats: [UserChatCellModel], welcomeModel: UserChatCellModel?)
  func displayExternalSources(with models: [LoungeExternalSourceModel])
  
  func displayError()
  func showHUD()
  func dismissHUD()
}

protocol LoungePresenterProtocol: class {
  var view: LoungeViewProtocol? { get set }
  var interactor: LoungeInteractorProtocol? { get set }
  var router: LoungeRouterProtocol? { get set }
  
  var needToFetch: Bool { get set }
  
  func viewDidLoad()
  func prepare(fetch: Bool)
  func cleanup()
  
  func didClickOnDelete(chatId: String?)
  func didClickOnRefresh()
  func didClickOnSetting(from view: UIViewController?)
  func didClickOnDismiss()
  func didClickOnChat(with chatId: String?, animated:Bool, from view: UIViewController?)
  func didClickOnNewChat(from view: UIViewController?)
  func didClickOnSeeMoreChat(from view: UIViewController?)
  func didClickOnHelp(from view: UIViewController?)
  func didClickOnExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?)
  func didClickOnWatermark()
  
  func isReadyToPresentChat(chatId: String?) -> _RXSwift_Single<Any?>
}

protocol LoungeInteractorProtocol: class {
  var presenter: LoungePresenterProtocol? { get set }
  
  func subscribeDataSource()
  func unsubscribeDataSource()
  
  func updateChats() -> _RXSwift_Observable<[CHUserChat]>
  func updateGeneralInfo() -> _RXSwift_Observable<(CHChannel, CHPlugin)>
  func updateExternalSource() -> _RXSwift_Observable<[Any]>
  
  func deleteChat(userChat: CHUserChat) -> _RXSwift_Observable<CHUserChat>
  func getLounge() -> _RXSwift_Observable<LoungeResponse>
  func getChannel() -> _RXSwift_Observable<CHChannel>
  func getChats() -> _RXSwift_Observable<UserChatsResponse>
}

protocol LoungeRouterProtocol: class {
  func pushChatList(from view: UIViewController?)
  func pushChat(with chatId: String?, text: String?, isOpenChat: Bool, animated: Bool, from view: UIViewController?)
  func pushSettings(from view: UIViewController?)
  
  func presentBusinessHours(from view: UIViewController?)
  func presentExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?)
  
  static func createModule(with chatId: String?, text: String?, isOpenChat: Bool) -> LoungeView
}
