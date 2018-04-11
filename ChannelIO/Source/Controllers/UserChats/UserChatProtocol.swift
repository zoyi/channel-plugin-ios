//
//  UserChatProtocol.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController
import CHPhotoBrowser

enum ChatEvent {
  case messages(obj: [CHMessage], next: String)
  case manager(obj: CHManager?)
  case session(obj: CHSession?)
  case chat(obj: CHUserChat?)
  case typing(obj: [CHEntity]?, animated: Bool)
  case error(obj: Error?)
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

protocol UserChatViewProtocol: class {
  var presenter: UserChatPresenterProtocol? { get set }
  
  func display(messages: [CHMessage])
  func display(typers: [CHEntity])
  func display(error: Error?, visible: Bool)
  func displayNewBanner()
  
  func updateInputField(userChat: CHUserChat?, updatedUserChat: CHUserChat?)
  
  func configureNavigation(with userChat: CHUserChat?, unread: Int)
  func setChatInfo(info: UserChatInfo)
}

protocol UserChatPresenterProtocol: class {
  weak var view: UserChatViewProtocol? { get set }
  var interactor: UserChatInteractorProtocol? { get set }
  var router: UserChatRouterProtocol? { get set }
  
  func fetchMessages()
  
  func send(text: String, assets: [DKAsset])
  func sendTyping(isStop: Bool)
  
  func didClickOnFeedback(rating: String, from view: UIViewController?)
  
  func didClickOnOption(from view: UIViewController?)
  func didClickOnManager(from view: UIViewController?)
  func didClickOnFile(with message: CHMessage?, from view: UIViewController?)
  func didClickOnImage(with url: URL?, from view: UIViewController?)
  func didClickOnWeb(with url: String?, from view: UIViewController?)
  func didClickOnTranslate(for message: CHMessage?)
  func didClickOnRetry(for message: CHMessage?, from view: UIViewController?)
  
  func viewDidLoad()
  func prepareDataSource()
  func cleanDataSource()
}

protocol UserChatInteractorProtocol: class {
  weak var presenter: UserChatPresenterProtocol? { get set }
  
  var userChat: CHUserChat? { get set }
  var userChatId: String { get set }
  var photoUrls: [URL] { get }
  
  var shouldFetchChat: Bool { get }
  var shouldRefreshChat: Bool { get }
  
  func refreshUserChat()
  func subscribeDataSource()
  func unsunbscribeDataSource()
  
  func joinSocket()
  func leaveSocket()
  
  func canLoadMore() -> Bool
  func createChat() -> Observable<CHUserChat>
  func fetchChat() -> Observable<CHUserChat>
  func fetchMessages()
  func chatEventSignal() -> Observable<ChatEvent>
  func translate(for message: CHMessage)
  func sendFeedback(rating: String)
  
  func send(text: String, assets:[DKAsset])
  func send(message: CHMessage?)
  func sendTyping(isStop: Bool)
  func delete(message: CHMessage?)
}

protocol UserChatRouterProtocol: class {
  static func createModule(userChatId: String?) -> UserChatView
  
  func showImageViewer(with url: URL?, photoUrls: [URL], from view: UIViewController?, dataSource: MWPhotoBrowserDelegate)
  func showRetryActionSheet(from view: UIViewController?) -> Observable<Bool?>
  func showOptionActionSheet(from view: UIViewController?) -> Observable<[DKAsset]> 
  func showOptionPicker(
    type: DKImagePickerControllerSourceType,
    max: Int,
    assetType: DKImagePickerControllerAssetType,
    from view: UIViewController?) -> Observable<[DKAsset]>
}

struct UserChatInfo {
  var userChat: CHUserChat?
  var channel: CHChannel
  var plugin: CHPlugin
  var managers: [CHManager]
  var showSettings: Bool
  var textColor: UIColor
}
