//
//  UserChatController.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import CHDwifft
import ReSwift
import RxSwift
import DKImagePickerController
import CHPhotoBrowser
import SVProgressHUD
import CHSlackTextViewController
import Alamofire

enum UserChatState {
  case Idle
  case UserChatLoading
  case UserChatLoaded
  case UserChatNotLoaded
  case ChatJoining
  case WaitingSocket
  case MessageLoading
  case MessageNotLoaded
  case ChatReady
}

final class UserChatViewController: BaseSLKTextViewController {

  // MARK: Constants
  struct Constant {
    static let messagePerRequest = "30"
    static let messageCellMaxWidth = UIScreen.main.bounds.width
  }
  
  // MARK: Properties
  var state: UserChatState = .Idle
  var userChatId: String?
  var userChat: CHUserChat?
  var nextSeq: String = ""
  var loaded: Bool = false
  var preloadText: String = ""
  var shouldShowGuide: Bool = false
  var isFetching = false
  var isRequstingReadAll = false
  var photoUrls = [String]()
  
  var typingManagers = [CHManager]()
  var timeStorage = [String: Timer]()

  var diffCalculator: SingleSectionTableViewDiffCalculator<CHMessage>?
  var messages = [CHMessage]() {
    didSet {
      self.diffCalculator?.rows = self.messages
    }
  }
  
  var createdFeedback = false
  var createdFeedbackComplete = false
  
  var disposeBag = DisposeBag()
  var photoBrowser : MWPhotoBrowser? = nil
  var errorToastView = ErrorToastView().then {
    $0.isHidden = true
  }
  var newMessageView = ChatBannerView().then {
    $0.isHidden = true
  }
  
  
  var newChatSubject = PublishSubject<Any?>()
  var profileSubject = PublishSubject<Any?>()
  // MARK: View Life Cycle

  override func viewDidLoad() {
    self.textInputBarLRC = 5
    self.textInputBarBC = 5
    
    super.viewDidLoad()
    self.tableView.isHidden = true
    self.edgesForExtendedLayout = UIRectEdge.bottom
    self.view.backgroundColor = UIColor.white
    
    if userChatsSelector(state: mainStore.state).count != 0 {
      //disable interactive pop if only one
      self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    }
    
    let chNavigation = self.navigationController as! MainNavigationController
    chNavigation.chDelegate = self
    
    self.initSLKTextView()
    self.initTableView()
    self.initInputViews()
    self.initViews()
    self.initLiveTyping()
    
    self.shouldShowGuide = (mainStore.state.guest.ghost == true ||
      mainStore.state.guest.mobileNumber == nil) &&
      mainStore.state.channel.requestGuestInfo
    
    //new user chat
    if self.userChatId == nil {
      self.endLoad()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let navigationController = self.navigationController as! MainNavigationController
    navigationController.useDefault = false
    
    mainStore.subscribe(self)
    if let userChatId = self.userChatId {
      self.state = .ChatJoining
      WsService.shared.join(chatId: userChatId)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
    if isBeingDismissed || isMovingFromParentViewController {
      self.resetTypingInfo()
      mainStore.dispatch(RemoveMessages(payload: self.userChatId))
    }
    self.sendTyping(isStop: true)
    if let userChatId = self.userChatId {
      //self.loaded = false
      WsService.shared.leave(chatId: userChatId)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }

  // MARK: - Helper methods
  fileprivate func initSLKTextView() {
    self.shouldScrollToBottomAfterKeyboardShows = true
    self.leftButton.setImage(CHAssets.getImage(named: "add"), for: .normal)
    self.rightButton.setTitle(CHAssets.localized("ch.chat.send"), for: .normal)
    self.rightButton.setTitleColor(CHColors.cobalt, for: .normal)
    self.textView.placeholder = CHAssets.localized("ch.message_input.placeholder")
    self.textView.keyboardType = .default
  }
  
  func initInputViews() {
    self.textView.isUserInteractionEnabled = false
    self.textView.keyboardType = .default
    self.textView.layer.borderWidth = 0
    self.textView.text = self.preloadText
    
    //default textinputbar
    self.textInputbar.barDelegate = self
    self.textInputbar.contentInset.right = 0
    self.textInputbar.signalForClick()
      .subscribe { [weak self] (_) in
      if self?.textInputbar.barState == .disabled {
        return
      }
      
      self?.presentKeyboard(self?.menuAccesoryView == nil)
    }.disposed(by: self.disposeBag)

  }
  
  fileprivate func initTableView() {
    // TableView configuration
    self.tableView.register(cellType: MessageCell.self)
    self.tableView.register(cellType: NewMessageDividerCell.self)
    self.tableView.register(cellType: DateCell.self)
    self.tableView.register(cellType: UserInfoDialogCell.self)
    self.tableView.register(cellType: SatisfactionFeedbackCell.self)
    self.tableView.register(cellType: SatisfactionCompleteCell.self)
    self.tableView.register(cellType: LogCell.self)
    self.tableView.register(cellType: TypingIndicatorCell.self)
    
    self.tableView.clipsToBounds = true
    self.tableView.separatorStyle = .none
    self.tableView.allowsSelection = false
  }

  // MARK: - Helper methods

  fileprivate func initDwifft() {
    self.tableView.reloadData()
    //self.tableView.scrollToBottom(false)
    self.diffCalculator = SingleSectionTableViewDiffCalculator<CHMessage>(
      tableView: self.tableView,
      initialRows: self.messages,
      sectionIndex: 1
    )
    self.diffCalculator?.forceOffAnimationEnabled = true
    self.diffCalculator?.insertionAnimation = UITableViewRowAnimation.none
    self.diffCalculator?.deletionAnimation = UITableViewRowAnimation.none
  }

  fileprivate func initLocalMessages() {
    let chat = userChatSelector(
      state: mainStore.state,
      userChatId: self.userChatId)
    
    let channel = mainStore.state.channel
    
    if self.userChatId == nil && channel.working {
      mainStore.dispatch(InsertWelcome())
    } else if self.userChatId == nil && !channel.working {
      mainStore.dispatch(CreateChannelClosed())
    } else if !channel.working && chat?.isActive() == true {
      mainStore.dispatch(CreateChannelClosed())
    }
  }

  fileprivate func initViews() {
    self.errorToastView.topLayoutGuide = self.topLayoutGuide
    self.errorToastView.containerView = self.view
    self.view.addSubview(self.errorToastView)
    
    self.errorToastView.refreshImageView.signalForClick()
      .subscribe(onNext: { [weak self] _ in
        WsService.shared.connect()
        self?.resetUserChat()
        self?.fetchMessages()
      }).disposed(by: self.disposeBag)
    
    self.view.addSubview(self.newMessageView)
    
    self.newMessageView.snp.makeConstraints { [weak self] (make) in
      make.height.equalTo(54)
      make.bottom.equalTo((self?.textInputbar.snp.top)!).offset(-5)
      make.leading.equalToSuperview().inset(6)
      make.trailing.equalToSuperview().inset(6)
    }
    
    self.newMessageView.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
        self?.newMessageView.hide(animated: true)
        self?.scrollToBottom(false)
      }).disposed(by: self.disposeBag)
  }
  
  fileprivate func showUserInfoGuideIfNeeded() {
    if self.shouldShowGuide && self.userChat != nil {
      self.shouldShowGuide = false
      dispatch(delay: 1.0, execute: { [weak self] in
        if self?.view.superview == nil { return }
        mainStore.dispatch(
          CreateUserInfoGuide(payload: ["userChat": (self?.userChat)!]
        ))
      })
    }
  }

  fileprivate func setNavItems(userChats: [CHUserChat], currentUserChat: CHUserChat?, guest: CHGuest, textColor: UIColor) {
    if userChats.count == 0 {
      self.navigationItem.leftBarButtonItem = NavigationItem(
        image: CHAssets.getImage(named: "exit"),
        style: .plain,
        actionHandler: { [weak self] in
          if self?.userChatId != nil {
            self?.requestReadAll()
          }
          mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
          self?.navigationController?.dismiss(animated: true, completion: {
            mainStore.dispatch(ChannelIsHidden())
          })
        }
      )
      
      self.navigationItem.rightBarButtonItem = NavigationItem(
        image: CHAssets.getImage(named: "more"),
        style: .plain,
        actionHandler: { [weak self] in
          self?.profileSubject.onNext(nil)
        })
    } else {
      let alert = guest.alert - (currentUserChat?.session?.alert ?? 0)
      let alertCount = alert > 99 ? "99+" : (alert > 0 ? "\(alert)" : nil)
      
      let tintColor = mainStore.state.plugin.textUIColor
      self.navigationItem.leftBarButtonItem = NavigationItem(
        image: CHAssets.getImage(named: "back")?.withRenderingMode(.alwaysTemplate),
        text: alertCount,
        fitToSize: alert != 0,
        alignLeft: alert == 0,
        textColor: tintColor,
        actionHandler: { [weak self] in
          if let _ = self?.userChatId {
            self?.requestReadAll()
          }
          mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
          _ = self?.navigationController?.popViewController(animated: true)
      })
      self.navigationItem.leftBarButtonItem?.tintColor = tintColor
    }
  }
  
  fileprivate func requestReadAll() {
    guard self.loaded else { return }
    guard !self.isRequstingReadAll else { return }
    
    if self.userChat?.session == nil {
      return
    }
    
    if self.userChat?.session?.unread == 0 &&
      self.userChat?.session?.alert == 0 {
      return
    }
    
    self.isRequstingReadAll = true
    
    self.userChat?.readAll()
      .subscribe(onNext: { [weak self] _ in
        self?.isRequstingReadAll = false
        self?.readAllManually()
      }).disposed(by: self.disposeBag)
  }
  
  fileprivate func fetchMessages() {
    guard let id = self.userChatId else {
      return
    }
    
    if self.isFetching {
      return
    }

    if self.nextSeq != "" {
      self.tableView.showIndicatorTo(.footer)
    }

    // TODO: show loader
    self.isFetching = true
    CHMessage.getMessages(userChatId: id,
                   since: self.nextSeq,
                   limit: Constant.messagePerRequest,
                   sortOrder: "DESC")
      .subscribe(onNext: { [weak self] (data) in
        if let nextSeq = data["next"] {
          self?.nextSeq = nextSeq as! String
        }
        mainStore.dispatch(GetMessages(payload: data))
      }, onError: { [weak self] error in
        // TODO: show error
        self?.isFetching = false
        self?.state = .MessageNotLoaded
        self?.tableView.hideIndicatorTo(.footer)
        
        self?.errorToastView.show(animated: true)
        //mainStore.dispatch(FailedGetMessages(error: error))
      }, onCompleted: { [weak self] in
        self?.isFetching = false
        self?.tableView.hideIndicatorTo(.footer)
        if self?.loaded == false {
          self?.endLoad()
          self?.requestReadAll()
        }
      }).disposed(by: self.disposeBag)
  }

  fileprivate func fetchUserChat() {
    guard let userChatId = self.userChatId else { return }
    
    CHUserChat.get(userChatId: userChatId)
      .subscribe(onNext: { (response) in
      mainStore.dispatch(GetUserChat(payload: response))
    }).disposed(by: self.disposeBag)
  }
  
  func readAllManually() {
    guard var session = self.userChat?.session else { return }
    session.unread = 0
    session.alert = 0
    mainStore.dispatch(UpdateSession(payload: session))
  }
  
  fileprivate func endLoad() {
    if !self.loaded {
      self.state = .ChatReady
      self.loaded = true
      self.initLocalMessages()
      self.initDwifft()
      //NOTE: to make more smooth transition loading message
      self.tableView.isHidden = false
    }
  }
  
  fileprivate func resetUserChat() {
    self.nextSeq = ""
    self.createdFeedback = false
    self.createdFeedbackComplete = false
    
    if let userChatId = self.userChatId {
      mainStore.dispatch(RemoveMessages(payload: userChatId))
    }
  }

}

// MARK: - StoreSubscriber

extension UserChatViewController: StoreSubscriber {

  func newState(state: AppState) {
    let messages = messagesSelector(state: state, userChatId: self.userChatId)

    self.showMessageBannerIfNeeded(current: self.messages, updated: messages)
    
    //saved contentOffset
    let offset = self.tableView.contentOffset
    let hasNewMessage = self.hasNewMessage(current: self.messages, updated: messages)
    
    self.messages = messages
    let userChat = userChatSelector(state: state, userChatId: self.userChatId)
    //feedback trigger 
    self.showFeedbackIfNeeded(userChat, lastMessage: messages.first)
    self.configureInputField(userChat)
    self.userChat = userChat
    
    //fixed scroll location if necessary
    self.fixedOffsetIfNeeded(previousOffset: offset, hasNewMessage: hasNewMessage)
    
    // Nav items
    let userChats = userChatsSelector(
      state: state,
      showCompleted: state.userChatsState.showCompletedChats
    )
    
    self.setNavItems(userChats: userChats, currentUserChat: self.userChat,
                     guest: state.guest, textColor: state.plugin.textUIColor)

    // Title
    self.title = state.channel.name
    
    // Photo - is this scalable? or doesn't need to care at this moment?
    self.photoUrls = self.messages.reversed()
      .filter({ $0.file?.isPreviewable == true })
      .map({ (message) -> String in
        return message.file?.url ?? ""
      })
    
    //if unread count is not 0, trigger read all
    let socketState = mainStore.state.socketState.state
    
    if socketState == .Joined &&
      self.state != .ChatReady &&
      self.state != .MessageLoading {
      self.state = .MessageLoading
      self.nextSeq = ""

      CHUserChat.get(userChatId: self.userChatId ?? "")
        .subscribe(onNext: { [weak self] (response) in
          mainStore.dispatch(GetUserChat(payload: response))
          self?.fetchMessages()
        }).disposed(by: self.disposeBag)
      
    } else if socketState == .Disconnected || socketState == .Reconnecting {
      self.state = .Idle
    } else if socketState == .Connected ||
      socketState == .Reconnecting {
      self.state = .WaitingSocket
    }
    
    if socketState == .Disconnected ||
      socketState == .Reconnecting ||
      self.state == .MessageNotLoaded ||
      self.state == .UserChatNotLoaded {
      self.errorToastView.show(animated: true)
    } else {
      self.errorToastView.hide(animated: false)
    }
    
    self.requestReadAll()
  }

  func configureInputField(_ userChat: CHUserChat?) {
    guard let userChat = userChat else { return }
    
    if userChat.state == "resolved" || userChat.state == "closed" {
      self.textInputbar.barState = .disabled
      self.rightButton.setTitle(CHAssets.localized("ch.chat.start_new_chat"), for: UIControlState())
      self.textInputbar.autoHideRightButton = false
      self.textView.placeholder = CHAssets.localized("ch.review.complete.preview")
      self.rightButton.isEnabled = true
      self.leftButton.isEnabled = false
      self.textView.isEditable = false
    }
  }
  
  func showFeedbackIfNeeded(_ userChat: CHUserChat?, lastMessage: CHMessage?) {
    guard let newUserChat = userChat else { return }
    
    //it only trigger once if previous state is following and new state is resolved
    if newUserChat.state == "resolved" &&
      //lastMessage?.log?.action == "resolve" &&
      !self.createdFeedback {
      self.createdFeedback = true
      mainStore.dispatch(CreateFeedback())
    } else if newUserChat.state == "closed" &&
      !self.createdFeedbackComplete {
      self.createdFeedbackComplete = true
      mainStore.dispatch(CreateCompletedFeedback())
    }
  }
  
  func showMessageBannerIfNeeded(current: [CHMessage], updated: [CHMessage]) {
    guard let lastMessage = updated.first, !isMyMessage(message: lastMessage) else {
        return
    }
    
    let offset = self.tableView.contentOffset.y
    if hasNewMessage(current: current, updated: updated) &&
      offset > UIScreen.main.bounds.height * 0.7 {
      self.newMessageView.configure(message: lastMessage)
      self.newMessageView.show(animated: true)
    }
  }
  
  func isMyMessage(message: CHMessage) -> Bool {
    let me = mainStore.state.guest
    return message.entity?.id == me.id
  }
  
  func hasNewMessage(current: [CHMessage], updated: [CHMessage]) -> Bool {
    if updated.count == 0 {
      return false
    }
    
    if current.count == 0 && updated.count != 0 {
      return true
    }
    
    if updated.count < current.count {
      return false
    }
    
    if updated.count > current.count {
      let updatedLast = updated.first!
      let currLast = current.first!
      
      if updatedLast.createdAt > currLast.createdAt {
        return true
      }
    }
    
    return false
  }
  
  func fixedOffsetIfNeeded(previousOffset: CGPoint, hasNewMessage: Bool) {
    var offset = previousOffset
    if let lastMessage = self.messages.first,
      !self.isMyMessage(message: lastMessage),
      offset.y > UIScreen.main.bounds.height/2,
      hasNewMessage {
      let previous: CHMessage? = self.messages.count >= 2 ? self.messages[1] : nil
      let viewModel = MessageCellModel(message: lastMessage, previous: previous)
      offset.y += MessageCell.measureHeight(fits: 0, viewModel: viewModel)
      self.tableView.setContentOffset(offset, animated: false)
    } else if hasNewMessage {
      self.scrollToBottom(false)
    }
  }
  
  fileprivate func scrollToBottom(_ animated: Bool) {
    self.tableView.setContentOffset(CGPoint(x:0,y:-30), animated: animated)
  }
}

// MARK: - SLKTextViewController

extension UserChatViewController {

  override func didPressLeftButton(_ sender: Any?) {
    super.didPressLeftButton(sender)

    let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
    
    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.camera"), style: .default) { [weak self] _ in
      self?.presentPicker(type: .camera)
    })
    
    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.photo.album"), style: .default) { [weak self] _ in
      self?.presentPicker(type: .photo, max: 20)
    })
    
    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in
      //nothing
    })
    
    self.navigationController?.present(alertView, animated: true, completion: nil)
  }

  override func didPressRightButton(_ sender: Any?) {
    // This little trick validates any pending auto-correction or 
    // auto-spelling just after hitting the 'Send' button
    
    self.textView.refreshFirstResponder()
    let msg = self.textView.text!
    
    if let userChat = self.userChat,
      userChat.isActive() {
      if let userChatId = self.userChatId {
        self.sendMessage(userChatId: userChatId, text: msg)
      }
    } else if self.userChat == nil {
      self.createUserChat(completion: { [weak self] (userChatId: String) in
        self?.userChatId = userChatId
        self?.sendMessage(userChatId: userChatId, text: msg)
      })
    } else {
      mainStore.dispatch(RemoveMessages(payload: userChatId))
      self.newChatSubject.onNext(self.textView.text)
    }

    super.didPressRightButton(sender)
  }

  override func forceTextInputbarAdjustment(for responder: UIResponder?) -> Bool {
    // TODO: check if responder is equal to our text field
    return true
  }

  private func presentPicker(type: DKImagePickerControllerSourceType,
                             max: Int = 0,
                             assetType: DKImagePickerControllerAssetType = .allPhotos) {
    let pickerController = DKImagePickerController()
    pickerController.sourceType = type
    pickerController.showsCancelButton = true
    pickerController.maxSelectableCount = max
    pickerController.assetType = assetType
    pickerController.didSelectAssets = { [weak self] (assets: [DKAsset]) in
      func uploadImage(_ userChatId: String) {
        let messages = assets.map({ (asset) -> CHMessage in
          return CHMessage(chatId: userChatId, guest:  mainStore.state.guest, asset: asset)
        })
        
        messages.forEach({ mainStore.dispatch(CreateMessage(payload: $0)) })
        self?.sendMessageRecursively(allMessages: messages, currentIndex: 0)
      }
      
      if let userChatId = self?.userChatId {
        uploadImage(userChatId)
      } else {
        self?.createUserChat(completion: { (userChatId) in
          self?.userChatId = userChatId
          uploadImage(userChatId)
        })
      }
    }
    self.present(pickerController, animated: true, completion: nil)
  }

  private func sendMessageRecursively(allMessages: [CHMessage], currentIndex: Int) {
    var message = allMessages.get(index: currentIndex)
    message?.send().subscribe(onNext: { [weak self] (updated) in
      message?.state = .Sent
      mainStore.dispatch(CreateMessage(payload: updated))

      if !(self?.isViewLoaded == true && self?.view.window != nil){
        let messages = messagesSelector(state: mainStore.state, userChatId: self?.userChatId)
        self?.updatePhotoUrls(messages: messages)
      }

      self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
    }, onError: { [weak self] (error) in
      message?.state = .Failed
      mainStore.dispatch(CreateMessage(payload: message!))

      if !(self?.isViewLoaded == true && self?.view.window != nil) {
        let messages = messagesSelector(state: mainStore.state, userChatId: self?.userChatId)
        self?.updatePhotoUrls(messages: messages)
      }

      self?.sendMessageRecursively(allMessages: allMessages, currentIndex: currentIndex + 1)
    }).disposed(by: self.disposeBag)
  }

  private func sendMessage(userChatId: String, text: String) {
    let me = mainStore.state.guest
    var message = CHMessage(chatId: userChatId, guest: me, message: text)
    
    mainStore.dispatch(CreateMessage(payload: message))
    self.scrollToBottom(false)
    
    message.send().subscribe(onNext: { [weak self] (updated) in
      self?.sendTyping(isStop: true)
      mainStore.dispatch(CreateMessage(payload: updated))
      self?.showUserInfoGuideIfNeeded()
    }, onError: { (error) in
      message.state = .Failed
      mainStore.dispatch(CreateMessage(payload: message))
    }).disposed(by: self.disposeBag)
  }

  private func createUserChat(completion: @escaping (String) -> Void) {
    // TODO: Show loader?
    CHUserChat.create().subscribe(onNext: { [weak self] (chatResponse) in
      guard let userChat = chatResponse.userChat,
        let session = chatResponse.session else { return }
      self?.userChatId = userChat.id
      mainStore.dispatch(CreateUserChat(payload: userChat))
      mainStore.dispatch(CreateSession(payload: session))
      WsService.shared.join(chatId: userChat.id)
      completion(userChat.id)
    }, onError: { [weak self] (error) in
      self?.errorToastView.show(animated: true)
    }).disposed(by: self.disposeBag)
  }
  
  private func updatePhotoUrls(messages: [CHMessage]) {
    self.photoUrls = messages.filter({ $0.file?.isPreviewable == true })
      .map({ (message) -> String in
        return message.file?.url ?? ""
      })
    
    self.photoBrowser?.reloadData()
  }
  
  override func textViewDidChange(_ textView: UITextView) {
    self.sendTyping(isStop: textView.text == "")
  }
}

// MARK: - UIScrollViewDelegate

extension UserChatViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    if yOffset + UIScreen.main.bounds.height > scrollView.contentHeight &&
      !self.isFetching &&
      !self.nextSeq.isEmpty {
      self.fetchMessages()
    }
    
    //let triggerPoint = UIScreen.main.bounds.height
    if yOffset < 100 &&
      !self.newMessageView.isHidden {
      self.newMessageView.hide(animated: false)
    }
  }
}

// MARK: - UITableView

extension UserChatViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return self.messages.count
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    }
    
    let message = self.messages[indexPath.row]
    let previousMessage: CHMessage? =
      indexPath.row == self.messages.count - 1 ?
        self.messages[indexPath.row] :
        self.messages[indexPath.row + 1]
    let viewModel = MessageCellModel(message: message, previous: previousMessage)
    switch message.messageType {
    case .DateDivider:
      return 40
    case .NewAlertMessage:
      return 54
    case .SatisfactionFeedback:
      return 158 + 16
    case .SatisfactionCompleted:
      return 104 + 16
    case .Log:
      return 46
    case .UserInfoDialog:
      let model = DialogViewModel.model(type: message.userGuideDialogType)
      return UserInfoDialogCell.measureHeight(fits: Constant.messageCellMaxWidth, viewModel: model)
    default:
      let calSize = MessageCell.measureHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
      return calSize
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    if section == 0 {
      return self.cellForTyping(tableView, cellForRowAt: indexPath)
    } else {
      return self.cellForMessage(tableView, cellForRowAt: indexPath)
    }
  }
  
  func cellForTyping(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TypingIndicatorCell = tableView.dequeueReusableCell(for: indexPath)
    cell.transform = tableView.transform
    cell.configure(typingUsers: self.typingManagers)
    return cell
  }
  
  func cellForMessage(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = self.messages[indexPath.row]
    
    switch message.messageType {
    case .ChannelClosed:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      let viewModel = MessageCellModel(message: message, previous: nil)
      cell.configure(viewModel)
      cell.bubbleView.actionView.signalForClick().subscribe({ [weak self] (event) in
        mainStore.dispatch(ClickBusinessHour(payload:self?.userChat))
        //self?.tableView.scrollToBottom(true)
        
        dispatch(delay: 1.0, execute: { [weak self] in
          if self?.view.superview == nil { return }
          //guard mainStore.state.userChatsState.currentUserChatId != "" else { return }
          mainStore.dispatch(AnswerBusinessHour(payload: self?.userChat))
          //self?.tableView.scrollToBottom(true)
        })
        
      }).disposed(by: self.disposeBag)
      cell.transform = self.tableView.transform
      return cell
    case .BusinessHourQuestion, .BusinessHourAnswer:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      let previousMessage: CHMessage? =
        indexPath.row == 0 ? nil : self.messages[indexPath.row - 1]
      let viewModel = MessageCellModel(message: message, previous: previousMessage)
      cell.configure(viewModel)
      cell.transform = self.tableView.transform
      return cell
    case .NewAlertMessage:
      let cell: NewMessageDividerCell = tableView.dequeueReusableCell(for: indexPath)
      cell.transform = self.tableView.transform
      return cell
    case .DateDivider:
      let cell: DateCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(date: message.message ?? "")
      cell.transform = self.tableView.transform
      return cell
    case .Log:
      let cell: LogCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(message: message)
      cell.transform = self.tableView.transform
      return cell
    case .UserInfoDialog:
      let cell: UserInfoDialogCell = tableView.dequeueReusableCell(for: indexPath)
      let model = DialogViewModel.model(type: message.userGuideDialogType)
      cell.configure(viewModel: model)
      cell.dialogView.signalForCountryCode()
        .subscribe(onNext: { [weak self] (code) in
          self?.dismissKeyboard(true)
          
          let pickerView = CountryCodePickerView(frame: (self?.view.frame)!)
          pickerView.pickedCode = code
          pickerView.showPicker(onView: (self?.navigationController?.view)!,animated: true)
          
          pickerView.signalForSubmit()
            .subscribe(onNext: { (code) in
              cell.dialogView.setCountryCodeText(code: code)
              cell.dialogView.phoneFieldView.phoneField.becomeFirstResponder()
            }).disposed(by: (self?.disposeBag)!)
        }).disposed(by: self.disposeBag)
      cell.transform = self.tableView.transform
      return cell
    case .SatisfactionFeedback:
      let cell: SatisfactionFeedbackCell = tableView.dequeueReusableCell(for: indexPath)
      cell.signalForFeedback()
        .subscribe(onNext: { [weak self] (response) in
          if let userChat = self?.userChat  {
            userChat.feedback(rating: response)
              .observeOn(MainScheduler.instance)
              .subscribe (onNext: { (response) in
                mainStore.dispatch(GetUserChat(payload: response))
              }).disposed(by: (self?.disposeBag)!)
          }
        }).disposed(by: self.disposeBag)
      cell.transform = self.tableView.transform
      return cell
    case .SatisfactionCompleted:
      let cell: SatisfactionCompleteCell = tableView.dequeueReusableCell(for: indexPath)
      let chat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
      cell.configure(
        review: chat?.review,
        duration: chat?.resolutionTime)
      cell.transform = self.tableView.transform
      return cell
    case .UserMessage:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      let previousMessage: CHMessage? =
        indexPath.row == self.messages.count - 1 ?
          self.messages[indexPath.row] :
          self.messages[indexPath.row + 1]
      let viewModel = MessageCellModel(message: message, previous: previousMessage)
      cell.configure(viewModel)
      cell.transform = self.tableView.transform
      return cell
    default: //remote
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      let previousMessage: CHMessage? =
        indexPath.row == self.messages.count - 1 ?
          self.messages[indexPath.row] :
          self.messages[indexPath.row + 1]
      let viewModel = MessageCellModel(message: message, previous: previousMessage)
      cell.configure(viewModel)
      
      cell.clipImageView.signalForClick()
        .subscribe { [weak self] _ in
          self?.didImageTapped(message: message)
        }.disposed(by: self.disposeBag)
      cell.clipWebpageView.signalForClick()
        .subscribe{ [weak self] _ in
          self?.didWebPageTapped(message: message)
        }.disposed(by: self.disposeBag)
      cell.clipFileView.signalForClick()
        .subscribe { [weak self] _ in
          self?.didFileTapped(message: message)
        }.disposed(by: self.disposeBag)
      
      cell.transform = self.tableView.transform
      return cell
    }
  }
}

// MARK: MWPhotoBrowser

extension UserChatViewController: MWPhotoBrowserDelegate {
  func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(self.photoUrls.count)
  }
  
  func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
    return MWPhoto(url: URL(string: self.photoUrls[Int(index)]))
  }
}


// MARK: Clip handlers 

extension UserChatViewController {
  func signalForProfile() -> Observable<Any?> {
    return self.profileSubject
  }
  
  func signalForNewChat() -> Observable<Any?> {
    return self.newChatSubject
  }
  
  func didImageTapped(message: CHMessage) {
    let imgUrl = message.file?.url
    self.photoBrowser = MWPhotoBrowser(delegate: self)
    
    if let index = self.photoUrls.index(of: imgUrl ?? "") {
      let navigationController = self.navigationController as! MainNavigationController
      navigationController.useDefault = true
      self.dismissKeyboard(true)
      self.photoBrowser?.setCurrentPhotoIndex(UInt(index))
      _ = self.navigationController?.pushViewController(self.photoBrowser!, animated: true)
    }
  }
  
  func didFileTapped(message: CHMessage) {
    guard let url = message.file?.url else { return }
    
    if let localUrl = message.file?.localUrl,
      message.file?.downloaded == true {
      self.showDocumentController(url: localUrl)
      return
    }

    SVProgressHUD.showProgress(0)
    
    let destination = DownloadRequest
      .suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
    
      Alamofire.download(url, to: destination)
      .downloadProgress{ (download) in
        SVProgressHUD.showProgress(Float(download.fractionCompleted))
      }
      .validate(statusCode: 200..<300)
      .response{ [weak self] (response) in
        SVProgressHUD.dismiss()
        
        let directoryURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathURL = URL(fileURLWithPath: directoryURL, isDirectory: true)
        guard let fileName = response.response?.suggestedFilename else { return }
        let fileURL = pathURL.appendingPathComponent(fileName)
        
        var message = message
        message.file?.downloaded = true
        message.file?.localUrl = fileURL
        mainStore.dispatch(UpdateMessage(payload: message))
        
        self?.showDocumentController(url: fileURL)
      }
  }
  
  func showDocumentController(url: URL) {
    let docController = UIDocumentInteractionController(url: url)
    docController.delegate = self
    
    if !docController.presentPreview(animated: true) {
      docController.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
    }
  }

  func didWebPageTapped(message: CHMessage) {
    guard let url = URL(string:message.webPage?.url ?? "") else { return }
    let shouldHandle = ChannelPlugin.delegate?.shouldHandleChatLink?(url: url)
    if shouldHandle == true || shouldHandle == nil {
      url.openWithUniversal()
    }
  }
}

// MARK: UIDocumentInteractionControllerDelegate methods

extension UserChatViewController : UIDocumentInteractionControllerDelegate {
  func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
    if let controller = CHUtils.getTopController() {
      return controller
    }
    return UIViewController()
  }
}

extension UserChatViewController : CHNavigationDelegate {
  func willPopViewController(willShow: UIViewController) {
    if self.userChatId != nil {
      self.requestReadAll()
    }
  }
}

extension UserChatViewController : SLKInputBarViewDelegate {
  func barStateDidChange(_ state: SLKInputBarState) {
    self.textInputbar.layer.cornerRadius = 5
    self.textInputbar.clipsToBounds = true
    self.textInputbar.layer.borderWidth = 2
    
    if state == .disabled {
      self.textInputbar.layer.borderColor = CHColors.darkTwo.cgColor
      self.textInputbar.backgroundColor = CHColors.snow
      self.textView.backgroundColor = UIColor.clear
      self.textView.isHidden = false
    } else {

      self.textInputbar.layer.borderColor = CHColors.paleGrey.cgColor
      self.textInputbar.backgroundColor = UIColor.white
      self.textView.backgroundColor = UIColor.clear
      self.textView.isHidden = false
    }
  }
}

extension UserChatViewController {
  func initLiveTyping() {
    WsService.shared.typingSubject
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (typingEntity) in
        guard let s = self else { return }
        if typingEntity.action == "stop" {
          if let index = s.getTypingIndex(of: typingEntity) {
            let person = s.typingManagers.remove(at: index)
            s.removeTimer(with: person)
          }
        }
        else if typingEntity.action == "start" {
          if let manager = personSelector(
            state: mainStore.state,
            personType: typingEntity.personType ?? "",
            personId: typingEntity.personId) as? CHManager {
              if s.getTypingIndex(of: typingEntity) == nil {
                s.typingManagers.append(manager)
              }
              s.addTimer(with: manager, delay: 15)
          }
        }
        
        s.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
      }).disposed(by: self.disposeBag)
    
    WsService.shared.mOnCreate()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (message) in
        guard let s = self else { return }
        
        let typing = CHTypingEntity.transform(from: message)
        if let index = s.getTypingIndex(of: typing) {
          let person = s.typingManagers.remove(at: index)
          s.removeTimer(with: person)
          s.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
        }
      }).disposed(by: self.disposeBag)
  }

  func sendTyping(isStop: Bool) {
    WsService.shared.sendTyping(
      chat: self.userChat, isStop: isStop
    )
  }
  
  func addTimer(with manager: CHManager, delay: TimeInterval) {
    let timer = Timer.scheduledTimer(
      timeInterval: delay,
      target: self,
      selector: #selector(self.expired(_:)),
      userInfo: [manager],
      repeats: false
    )
    
    if let t = self.timeStorage[manager.key] {
      t.invalidate()
    }
    
    self.timeStorage[manager.key] = timer
  }
  
  func removeTimer(with manager: CHManager?) {
    guard let manager = manager else { return }
    if let t = self.timeStorage.removeValue(forKey: manager.key) {
      t.invalidate()
    }
  }
  
  func resetTypingInfo() {
    self.timeStorage.forEach { (k, t) in
      t.invalidate()
    }
    self.typingManagers.removeAll()
    self.timeStorage.removeAll()
  }
  
  @objc func expired(_ timer: Timer) {
    guard let params = timer.userInfo as? [Any] else { return }
    guard let manager = params[0] as? CHManager else { return }
    
    timer.invalidate()
    if let index = self.typingManagers.index(where: { (m) in
      return m.id == manager.id
    }) {
      self.typingManagers.remove(at: index)
      self.timeStorage.removeValue(forKey: manager.key)
      self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
    }
  }
  
  func getTypingIndex(of typingEntity: CHTypingEntity) -> Int? {
    return self.typingManagers.index(where: {
      $0.id == typingEntity.personId
    })
  }
}
