//
//  MainProtocols.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

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
  
  func displayError(for type: LoungeSectionType)
}

protocol LoungePresenterProtocol: class {
  var view: LoungeViewProtocol? { get set }
  var interactor: LoungeInteractorProtocol? { get set }
  var router: LoungeRouterProtocol? { get set }
  
  var needToFetch: Bool { get set }
  
  func isReadyToPresentChat(chatId: String?) -> Single<Any?>
  
  func viewDidLoad()
  func prepare(fetch: Bool)
  func cleanup()
  
  func didClickOnDelete(chatId: String?)
  func didClickOnRefresh(for type: LoungeSectionType)
  func didClickOnSetting(from view: UIViewController?)
  func didClickOnDismiss()
  func didClickOnChat(with chatId: String?, animated:Bool, from view: UIViewController?)
  func didClickOnNewChat(from view: UIViewController?)
  func didClickOnSeeMoreChat(from view: UIViewController?)
  func didClickOnHelp(from view: UIViewController?)
  
  func didClickOnExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?)
  func didClickOnWatermark()
}

protocol LoungeInteractorProtocol: class {
  var presenter: LoungePresenterProtocol? { get set }
  
  func subscribeDataSource()
  func unsubscribeDataSource()
  
  func updateChats() -> Observable<[CHUserChat]>
  func updateGeneralInfo() -> Observable<(CHChannel, CHPlugin)>
  func updateExternalSource() -> Observable<[Any]>
  
  func deleteChat(userChat: CHUserChat) -> Observable<CHUserChat>
  func getChannel() -> Observable<CHChannel>
  func getPlugin() -> Observable<(CHPlugin, CHBot?)>
  func getOperators() -> Observable<[CHManager]>
  func getChats() -> Observable<[CHUserChat]>
  func getSupportBot() -> Observable<CHSupportBotEntryInfo>
  func getExternalSource() -> Observable<[CHExternalSourceType:String]?>
}

protocol LoungeRouterProtocol: class {
  func pushChatList(from view: UIViewController?)
  func pushChat(with chatId: String?, animated: Bool, from view: UIViewController?)
  func pushSettings(from view: UIViewController?)
  
  func presentBusinessHours(from view: UIViewController?)
  func presentExternalSource(with source: LoungeExternalSourceModel, from view: UIViewController?)
  
  static func createModule(with chatId: String?) -> LoungeView
}
