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

enum ChatProcessState {
  case idle
  case infoNotLoaded
  case infoLoading
  case infoLoaded
  case chatLoading
  case chatLoaded
  case chatNotLoaded
  case chatJoining
  case chatJoined
  case waitingSocket
  case socketDisconnected
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
  
  func display(userChat: CHUserChat?, channel: CHChannel)
  func display(messages: [CHMessage], userChat: CHUserChat?, channel: CHChannel)
  func display(typers: [CHEntity])
  func display(error: String?, visible: Bool)
  func display(loadingFile: ChatFileQueueItem, waitingCount: Int)
  func display(errorFiles: [ChatFileQueueItem])
  func hideLodingFile()
  func dismissKeyboard(_ animated: Bool)
  
  func updateNavigation(userChat: CHUserChat?)
  func updateInputBar(state: MessageViewState)
  func setPreloadtext(with text: String)
  
  func showProgressHUD(progress: Float)
  func showHUD()
  func dismissHUD()
}

protocol UserChatPresenterProtocol: class {
  var view: UserChatViewProtocol? { get set }
  var interactor: UserChatInteractorProtocol? { get set }
  var router: UserChatRouterProtocol? { get set }
  
  var userChatId: String? { get set }
  var shouldRedrawProfileBot: Bool { get set }
  var isProfileFocus: Bool { get set }
  
  func viewDidLoad()
  func prepareDataSource()
  func cleanDataSource()
  func fetchMessages()
  func handleError(with error: String?, visible: Bool, state: ChatProcessState?)
  func hasNewMessage(current: [CHMessage], updated: [CHMessage]) -> Bool
  func sendTyping(isStop: Bool)
  func updateMessages(with messages: [CHMessage], userChat: CHUserChat?, channel: CHChannel)
  func profileIsFocus(focus: Bool)
  func sendFiles(fileDictionary: [String:Any]?)
  
  func didClickOnProfileUpdate(
    with message: CHMessage?,
    key: String?,
    value: Any?) -> Observable<Bool>
  func didClickOnRightNaviItem(from view: UIViewController?)
  func didClickOnClipButton(from view: UIViewController?)
  func didClickOnSendButton(text: String)
  func didClickOnActionButton(originId: String?, key: String?, value: String?)
  func didClickOnMarketingToSupportBotButton()
  func didClickOnFile(
    with message: CHMessage?,
    file: CHFile?,
    on imageView: UIImageView?,
    from view: UIViewController?)
  func didClickOnWeb(with message: CHMessage?, url: URL?, from view: UIViewController?)
  func didClickOnTranslate(for message: CHMessage?)
  func didClickOnRetry(for message: CHMessage?, from view: UIView?)
  func didClickOnNewChat(with text: String, from view: UINavigationController?)
  func didClickOnWaterMark()
  func didClickOnRetryFile(with item: ChatFileQueueItem)
  func didClickOnRemoveFile(with item: ChatFileQueueItem)
}

protocol UserChatInteractorProtocol: class {
  var presenter: UserChatPresenterProtocol? { get set }
  
  var userChat: CHUserChat? { get set }
  var userChatId: String { get set }
  
  var photoUrls: [URL] { get }
  
  func readyToPresent() -> Observable<Bool>
  func subscribeDataSource()
  func unsunbscribeDataSource()
  func updateProfileItem(
    with message: CHMessage,
    key: String,
    value: Any) -> Observable<CHMessage>
  func joinSocket()
  func leaveSocket()
  func getChannel() -> Observable<CHChannel>
  func canLoadMore() -> Bool
  func createChatIfNeeded() -> Observable<CHUserChat?>
  func createSupportBotChatIfNeeded(
    originId: String?) -> Observable<(CHUserChat?, CHMessage?)>
  func startMarketingToSupportBot() -> Observable<CHMessage>
  func fetchChat() -> Observable<CHUserChat?>
  func fetchMessages() -> Observable<ChatProcessState>
  func translate(for message: CHMessage) -> Observable<[CHMessageBlock]>
  func send(message: CHMessage?) -> Observable<CHMessage?>
  func sendTyping(isStop: Bool)
  func delete(message: CHMessage?)
  
  func upload(files: [CHFile]) -> Observable<ChatQueueKey>
}

protocol UserChatRouterProtocol: class {
  static func createModule(userChatId: String?, text: String) -> UserChatView
  
  func presentVideoPlayer(with url: URL?, from view: UIViewController?)
  func presentImageViewer(
    with url: URL?,
    photoUrls: [URL],
    imageView: UIImageView,
    from view: UIViewController?)
  func pushFileView(with url: URL?, from view: UIViewController?)
  func showNewChat(with text: String, from view: UINavigationController?)
  func showRetryActionSheet(from view: UIView?) -> Observable<Bool?>
  func showOptionActionSheet(from view: UIViewController?) -> PublishSubject<[PHAsset]>
  
}
