//
//  UserChatProtocol.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import Photos

enum ChatEvent {
  case messages(obj: [CHMessage], next: String)
  case manager(obj: CHManager?)
  case session(obj: CHSession?)
  case chat(obj: CHUserChat?)
  case typing(obj: [CHEntity], animated: Bool)
  case error(obj: Error?)
  case state(_ state: ChatState)
}

enum ChatState {
  case idle
  case infoNotLoaded
  case infoLoading
  case infoLoaded
  case chatLoading
  case chatLoaded
  case chatNotLoaded
  case chatJoining
  case waitingSocket
  case messageLoading
  case messageLoaded
  case messageNotLoaded
  case chatReady
}

struct UserChatInfo {
  var userChat: CHUserChat?
  var channel: CHChannel
  var plugin: CHPlugin
  var managers: [CHManager]
  var textColor: UIColor
}

protocol UserChatViewProtocol: class {
  var presenter: UserChatPresenterProtocol? { get set }
  
  func display(messages: [CHMessage])
  func display(typers: [CHEntity])
  func display(error: Error?, visible: Bool)
  func displayNewBanner()
  
  func updateChatInfo(info: UserChatInfo)
}

protocol UserChatPresenterProtocol: class {
  var view: UserChatViewProtocol? { get set }
  var interactor: UserChatInteractorProtocol? { get set }
  var router: UserChatRouterProtocol? { get set }

  func viewDidLoad()
  func prepareDataSource()
  func cleanDataSource()
  
  func reload()
  func readyToDisplay() -> Observable<Bool>?
  func fetchMessages()
  
  func sendTyping(isStop: Bool)
  
  func didClickOnLeftButton(from view: UIViewController?)
  func didClickOnRightButton(text: String, assets: [PHAsset])
  func didClickOnFeedback(rating: String, from view: UIViewController?)
  func didClickOnActionButton(originId: String?, key: String?, value: String?)
  func didClickOnOption(from view: UIViewController?)
  func didClickOnFile(with message: CHMessage?, from view: UIViewController?)
  func didClickOnImage(with url: URL?, photoUrls: [URL], from view: UIViewController?)
  func didClickOnVideo(with url: URL?, from view: UIViewController?)
  func didClickOnWeb(with url: String?, from view: UIViewController?)
  func didClickOnTranslate(for message: CHMessage?)
  func didClickOnRetry(for message: CHMessage?, from view: UIViewController?)
  func didClickOnNewChat(with text: String, from view: UINavigationController?)
}

protocol UserChatInteractorProtocol: class {
  var presenter: UserChatPresenterProtocol? { get set }
  
  var userChat: CHUserChat? { get set }
  var userChatId: String { get set }
  var photoUrls: [URL] { get }
  
  var shouldFetchChat: Bool { get }
  var shouldRefreshChat: Bool { get }
  
  func readyToPresent() -> Observable<Bool>
  func refreshUserChat()
  func subscribeDataSource()
  func unsunbscribeDataSource()
  
  func joinSocket()
  func leaveSocket()
  
  func canLoadMore() -> Bool
  func createChat() -> Observable<CHUserChat?>
  func createNudgeChat(nudgeId:String?) -> Observable<String>
  func createSupportBotChatIfNeeded(originId: String?) -> Observable<(CHUserChat?, CHMessage?)>
  func fetchChat() -> Observable<CHUserChat?>
  func fetchMessages()
  func chatEventSignal() -> Observable<ChatEvent>
  func translate(for message: CHMessage)
  func sendFeedback(rating: String)
  
  func send(text: String, originId: String?, key: String?) -> Observable<CHMessage>
  func send(assets: [PHAsset]) -> Observable<[CHMessage]>
  func send(messages: [CHMessage]) -> Observable<Any?>
  func send(message: CHMessage?) -> Observable<CHMessage?>
  func sendTyping(isStop: Bool)
  func delete(message: CHMessage?)
}

protocol UserChatRouterProtocol: class {
  static func createModule(userChatId: String?) -> UserChatView
  
  //func presentImageViewer(with url: URL?, photoUrls: [URL], from view: UIViewController?, dataSource: MWPhotoBrowserDelegate)
  func presentVideoPlayer(with url: URL?, from view: UIViewController?)
  func presentImageViewer(with url: URL?, photoUrls: [URL], from view: UIViewController?)
  func pushFileView(with url: URL?, from view: UIViewController?)
  
  func showNewChat(with text: String, from view: UINavigationController?)
  func showRetryActionSheet(from view: UIViewController?) -> Observable<Bool?>
  func showOptionActionSheet(from view: UIViewController?) -> Observable<[PHAsset]>
  func showOptionPicker(max: Int, from view: UIViewController?) -> Observable<[PHAsset]>
}
