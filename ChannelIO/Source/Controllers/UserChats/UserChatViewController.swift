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
import CHNavBar
import AVKit
import UINavigationItem_Margin

final class UserChatViewController: BaseSLKTextViewController {

  // MARK: Constants
  struct Constant {
    static let messagePerRequest = 30
    static let messageCellMaxWidth = UIScreen.main.bounds.width
  }
  
  // MARK: Properties
  var channel: CHChannel = mainStore.state.channel
  var userChatId: String?
  var userChat: CHUserChat?

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
  var currentLocale: CHLocale? = CHUtils.getLocale()
  var chatManager : ChatManager!
  
  var errorToastView = ErrorToastView().then {
    $0.isHidden = true
  }
  var newMessageView = NewMessageBannerView().then {
    $0.isHidden = true
  }
  
  var typingCell: TypingIndicatorCell!
  
  var titleView : NavigationTitleView? = nil
  
  var newChatSubject = PublishSubject<Any?>()
  var profileSubject = PublishSubject<Any?>()
  
  deinit {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
  }
  
  // MARK: View Life Cycle
  override func viewDidLoad() {
    //this has to be called before super.viewDidLoad
    //for proper layout in SlackTextViewController
    self.textInputBarLRC = 5
    self.textInputBarBC = 5
    
    super.viewDidLoad()
    self.tableView.isHidden = true
    self.edgesForExtendedLayout = UIRectEdge.bottom
    self.view.backgroundColor = UIColor.white
  
    self.initManagers()
    self.initNavigationViews()
    self.initSLKTextView()
    self.initTypingCell()
    self.initTableView()
    self.initInputViews()
    self.initViews()
    
    self.shouldShowGuide = (mainStore.state.guest.ghost == true ||
      mainStore.state.guest.mobileNumber == nil) &&
      mainStore.state.channel.requestGuestInfo
    
    //new user chat
    if self.userChatId == nil {
      self.readyToDisplay()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.chatManager.willAppear()
    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
    if isBeingDismissed || isMovingFromParentViewController {
      self.chatManager.reset()
      self.chatManager.willDisppear()
    }
  }

  fileprivate func initManagers() {
    self.chatManager = ChatManager(id: self.userChatId)
    self.chatManager.chat = userChatSelector(
      state: mainStore.state,
      userChatId: self.userChatId)
    self.chatManager.delegate = self
  }
  
  // MARK: - Helper methods
  fileprivate func initSLKTextView() {
    self.shouldScrollToBottomAfterKeyboardShows = true
    self.leftButton.setImage(CHAssets.getImage(named: "add"), for: .normal)
    self.textView.keyboardType = .default
    
    if let userChat = self.userChat, userChat.isCompleted() {
      self.alwaysEnableRightButton = true
    }
  }
  
  func initInputViews() {
    self.textView.isUserInteractionEnabled = false
    self.textView.keyboardType = .default
    self.textView.layer.borderWidth = 0
    self.textView.text = self.preloadText
    
    //default textinputbar
    self.textInputbar.barDelegate = self
    self.textInputbar.contentInset.right = 0
    self.textInputbar.autoHideRightButton = false
    self.textInputbar.signalForClick()
      .subscribe { [weak self] (_) in
      if self?.textInputbar.barState == .disabled {
        return
      }
      self?.shyNavBarManager.contract(true)
      self?.presentKeyboard(self?.menuAccesoryView == nil)
    }.disposed(by: self.disposeBag)

  }
  
  fileprivate func initTableView() {
    // TableView configuration
    self.tableView.register(cellType: MediaMessageCell.self)
    self.tableView.register(cellType: FileMessageCell.self)
    self.tableView.register(cellType: WebPageMessageCell.self)
    self.tableView.register(cellType: MessageCell.self)
    self.tableView.register(cellType: NewMessageDividerCell.self)
    self.tableView.register(cellType: DateCell.self)
    self.tableView.register(cellType: UserInfoDialogCell.self)
    self.tableView.register(cellType: SatisfactionFeedbackCell.self)
    self.tableView.register(cellType: SatisfactionCompleteCell.self)
    self.tableView.register(cellType: LogCell.self)
    self.tableView.register(cellType: TypingIndicatorCell.self)
    self.tableView.register(cellType: WatermarkCell.self)
    
    self.tableView.estimatedRowHeight = 0
    self.tableView.clipsToBounds = true
    self.tableView.separatorStyle = .none
    self.tableView.allowsSelection = false
  }

  func initTypingCell() {
    let cell = TypingIndicatorCell()
    cell.configure(typingUsers: [])
    self.typingCell = cell
  }

  // MARK: - Helper methods

  fileprivate func initDwifft() {
    self.tableView.reloadData()
    //self.tableView.scrollToBottom(false)
    self.diffCalculator = SingleSectionTableViewDiffCalculator<CHMessage>(
      tableView: self.tableView,
      initialRows: self.messages,
      sectionIndex: self.channel.servicePlan == "free" ? 2 : 1
    )
    self.diffCalculator?.forceOffAnimationEnabled = true
    self.diffCalculator?.insertionAnimation = UITableViewRowAnimation.none
    self.diffCalculator?.deletionAnimation = UITableViewRowAnimation.none
  }

  fileprivate func initNavigationViews() {
    self.userChat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
    //TODO: take this out from redux
    let userChats = userChatsSelector(
      state: mainStore.state,
      showCompleted: mainStore.state.userChatsState.showCompletedChats
    )
    
    self.setNavItems(
      showSetting: userChats.count == 0,
      currentUserChat: self.userChat,
      guest: mainStore.state.guest,
      textColor: mainStore.state.plugin.textUIColor
    )
    
    self.initNavigationTitle()
    self.initNavigationExtension()
  }
  
  func initNavigationTitle() {
    let titleView = NavigationTitleView()
    titleView.configure(
      channel: mainStore.state.channel,
      userChat: self.userChat,
      plugin: mainStore.state.plugin)
    
    titleView.translatesAutoresizingMaskIntoConstraints = false
    titleView.layoutIfNeeded()
    titleView.sizeToFit()
    titleView.translatesAutoresizingMaskIntoConstraints = true
    titleView.signalForChange().subscribe({ [weak self] (event) in
      if self?.shyNavBarManager.isExpanded() == true {
        self?.shyNavBarManager.contract(true)
      } else {
        self?.shyNavBarManager.expand(true)
        self?.dismissKeyboard(true)
      }
    }).disposed(by: self.disposeBag)
    
    self.navigationItem.titleView = titleView
    self.titleView = titleView
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  func initNavigationExtension() {
    let view: UIView!
    if self.userChat?.isOpen() == true || self.userChat == nil {
      view = ChatStatusViewFactory.createDefaultExtensionView(
        fit: self.view.bounds.width,
        userChat: self.userChat,
        channel: mainStore.state.channel,
        plugin: mainStore.state.plugin,
        managers: mainStore.state.managersState.followingManagers)
    } else {
      view = ChatStatusViewFactory.createFollowedExtensionView(
        fit: self.view.bounds.width,
        userChat: self.userChat,
        channel: mainStore.state.channel,
        plugin: mainStore.state.plugin)
    }
    
    self.shyNavBarManager.scrollView = self.tableView
    self.shyNavBarManager.stickyNavigationBar = true
    self.shyNavBarManager.fadeBehavior = .subviews
    if let state = self.userChat?.state, state != "ready" &&
      self.shyNavBarManager.extensionView == nil || !self.shyNavBarManager.isExpanded() {
      self.titleView?.isExpanded = false
      self.shyNavBarManager.hideExtension = true
    }
    
    self.shyNavBarManager.extensionView = view
    self.shyNavBarManager.delegate = self
    self.shyNavBarManager.isInverted = true
    self.shyNavBarManager.triggerExtensionAtTop = true
    self.shyNavBarManager.expansionResistance = 0
    
    view.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }

  fileprivate func initViews() {
    self.errorToastView.topLayoutGuide = self.topLayoutGuide
    self.errorToastView.containerView = self.view
    self.view.addSubview(self.errorToastView)
    
    self.errorToastView.refreshImageView.signalForClick()
      .subscribe(onNext: { [weak self] _ in
        WsService.shared.connect()
        _ = self?.resetUserChat()?.subscribe({ (event) in
          if event.element != nil  {
            self?.chatManager.fetchMessages()
          }
        })
      }).disposed(by: self.disposeBag)
    
    self.view.addSubview(self.newMessageView)
    self.newMessageView.snp.makeConstraints { [weak self] (make) in
      make.height.equalTo(48)
      make.centerX.equalToSuperview()
      make.bottom.equalTo((self?.textInputbar.snp.top)!).offset(-6)
    }
    
    self.newMessageView.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
        self?.newMessageView.hide(animated: true)
        self?.scrollToBottom(false)
      }).disposed(by: self.disposeBag)
  }
  
  fileprivate func showUserInfoGuideIfNeeded() {
    if self.shouldShowGuide && self.userChat != nil  {
      self.shouldShowGuide = false
      dispatch(delay: 1.0, execute: { [weak self] in
        if self?.view.superview == nil { return }
        mainStore.dispatch(
          CreateUserInfoGuide(payload: ["userChat": self?.userChat])
        )
      })
    }
  }

  fileprivate func setNavItems(showSetting: Bool, currentUserChat: CHUserChat?, guest: CHGuest, textColor: UIColor) {
    let tintColor = mainStore.state.plugin.textUIColor
    
    if showSetting {
      self.navigationItem.leftMargin = 0
      self.navigationItem.leftBarButtonItem = NavigationItem(
        image: CHAssets.getImage(named: "settings"),
        textColor: tintColor,
        actionHandler: { [weak self] in
          self?.profileSubject.onNext(nil)
        })
    } else {
      let alert = guest.alert - (currentUserChat?.session?.alert ?? 0)
      let alertCount = alert > 99 ? "99+" : (alert > 0 ? "\(alert)" : nil)
      
      self.navigationItem.leftMargin = 0
      self.navigationItem.leftBarButtonItem = NavigationItem(
        image: CHAssets.getImage(named: "back"),
        text: alertCount,
        textColor: tintColor,
        actionHandler: { [weak self] in
          self?.shyNavBarManager.disable = true
          mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
          _ = self?.navigationController?.popViewController(animated: true)
        })
    }

    self.navigationItem.rightMargin = 0
    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "exit"),
      textColor: tintColor,
      actionHandler: { [weak self] in
        mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
        ChannelIO.close(animated: true)
      })
  }
  
  fileprivate func resetUserChat() -> Observable<String?>? {
    self.createdFeedback = false
    self.createdFeedbackComplete = false
    
    return self.chatManager.resetUserChat()
  }
  
  fileprivate func sendMessage(userChatId: String, text: String) {
    let me = mainStore.state.guest
    var message = CHMessage(chatId: userChatId, guest: me, message: text)
    
    mainStore.dispatch(CreateMessage(payload: message))
    self.scrollToBottom(false)
    
    message.send().subscribe(onNext: { [weak self] (updated) in
      dlog("Message has been sent successfully")
      self?.chatManager.sendTyping(isStop: true)
      mainStore.dispatch(CreateMessage(payload: updated))
      self?.showUserInfoGuideIfNeeded()
    }, onError: { (error) in
      dlog("Message has been failed to send")
      message.state = .Failed
      mainStore.dispatch(CreateMessage(payload: message))
    }).disposed(by: self.disposeBag)
  }
}

// MARK: - StoreSubscriber

extension UserChatViewController: StoreSubscriber {

  func newState(state: AppState) {
    let messages = messagesSelector(state: state, userChatId: self.userChatId)
    self.showNewMessageBannerIfNeeded(current: self.messages, updated: messages)
    
    //saved contentOffset
    let offset = self.tableView.contentOffset
    let hasNewMessage = self.chatManager.hasNewMessage(current: self.messages, updated: messages)
    
    //message only needs to be replace if count is differe
    self.messages = messages
    //fixed contentOffset
    self.tableView.layoutIfNeeded()
    
    // Photo - is this scalable? or doesn't need to care at this moment?
    self.photoUrls = self.messages.reversed()
      .filter({ $0.file?.isPreviewable == true })
      .map({ (message) -> String in
        return message.file?.url ?? ""
      })
    
    let userChat = userChatSelector(state: state, userChatId: self.userChatId)
    
    self.updateNavigationIfNeeded(state: state, nextUserChat: userChat)
    self.updateInputFieldIfNeeded(userChat: self.userChat, nextUserChat: userChat)
    self.showFeedbackIfNeeded(userChat, lastMessage: messages.first)
    self.fixedOffsetIfNeeded(previousOffset: offset, hasNewMessage: hasNewMessage)
    self.showErrorIfNeeded(state: state)
    
    self.fetchWelcomeInfoIfNeeded()
    self.fetchChatIfNeeded()
    
    self.userChat = userChat
    self.chatManager.chat = userChat
    self.channel = state.channel
  }

  func updateNavigationIfNeeded(state: AppState, nextUserChat: CHUserChat?) {
    if (self.userChat?.isReadyOrOpen() == true && nextUserChat?.isReadyOrOpen() == false) ||
      self.channel.isDiff(from: state.channel) ||
      self.currentLocale != state.settings?.locale {
      self.currentLocale = state.settings?.locale
      self.initNavigationViews()
      //replace welcome with updated locale only if user chat has not been created
      if self.userChat == nil && nextUserChat == nil {
        mainStore.dispatch(InsertWelcome())
      }
    }
    
    let userChats = userChatsSelector(
      state: mainStore.state,
      showCompleted: mainStore.state.userChatsState.showCompletedChats
    )
    
    self.setNavItems(
      showSetting: userChats.count == 0,
      currentUserChat: nextUserChat,
      guest: state.guest,
      textColor: state.plugin.textUIColor
    )
  }
  
  func fetchWelcomeInfoIfNeeded() {
    if self.chatManager.needToFetchInfo() == true {
      self.chatManager.fetchForNewUserChat()
        .subscribe({ (event) in
          switch event {
          case .error(_):
            break
          case .next(_):
            mainStore.dispatchOnMain(InsertWelcome())
          default:
            break
          }
        }).disposed(by: self.disposeBag)
    }
  }
  
  func fetchChatIfNeeded() {
    if self.chatManager.needToFetchChat() == true {
      self.chatManager.fetchChat()
        .subscribe(onNext: { [weak self] (event) in
        self?.chatManager.fetchMessages()
        self?.scrollToBottom(false)
        dlog("fetched chat info")
      }, onError: { [weak self] error in
        dlog("failed to fetch chat info - \(error.localizedDescription)")
        self?.navigationController?.popViewController(animated: true)
      }).disposed(by: self.disposeBag)
    }
  }
  
  func showErrorIfNeeded(state: AppState) {
    let socketState = state.socketState.state
    
    if socketState == .reconnecting {
      self.chatManager.state = .waitingSocket
    } else if socketState == .disconnected {
      self.showError()
    } else {
      self.hideError()
    }
  }
  
  func updateInputFieldIfNeeded(userChat: CHUserChat?, nextUserChat: CHUserChat?) {
    let channel = mainStore.state.channel

    if nextUserChat?.isCompleted() == true {
      self.textInputbar.barState = .disabled
      self.textInputbar.hideLeftButton()
      self.rightButton.setImage(nil, for: .normal)
      self.rightButton.setImage(nil, for: .disabled)
      self.rightButton.setTitle(CHAssets.localized("ch.chat.start_new_chat"), for: .normal)
      self.rightButton.setTitleColor(CHColors.cobalt, for: .normal)
      self.textView.placeholder = nextUserChat?.isRemoved() == true ?
        CHAssets.localized("ch.chat.removed.title") :
        CHAssets.localized("ch.review.complete.title")
      self.textView.isEditable = false
    } else if (!self.channel.allowNewChat && !channel.allowNewChat) &&
      self.isNewChat(with: userChat, nextUserChat: nextUserChat) {
      self.textInputbar.barState = .disabled
      self.textInputbar.hideAllButtons()
      self.textView.isEditable = false
      self.textView.placeholder = CHAssets.localized("ch.message_input.placeholder.disabled_new_chat")
    } else {
      self.rightButton.setImage(CHAssets.getImage(named: "sendActive")?.withRenderingMode(.alwaysOriginal), for: .normal)
      self.rightButton.setImage(CHAssets.getImage(named: "sendDisabled")?.withRenderingMode(.alwaysOriginal), for: .disabled)
      self.rightButton.tintColor = CHColors.cobalt
      self.rightButton.setTitle("", for: .normal)
      self.leftButton.setImage(CHAssets.getImage(named: "add"), for: .normal)
      
      self.textInputbar.barState = .normal
      self.textInputbar.setButtonsHidden(false)
      
      self.textView.isEditable = true
      self.textView.placeholder = CHAssets.localized("ch.message_input.placeholder")
    }
  }
  
  func showFeedbackIfNeeded(_ userChat: CHUserChat?, lastMessage: CHMessage?) {
    guard let newUserChat = userChat else { return }
    //it only trigger once if previous state is following and new state is resolved
    if newUserChat.isResolved() &&
      //lastMessage?.log?.action == "resolve" &&
      !self.createdFeedback {
      self.createdFeedback = true
      mainStore.dispatch(CreateFeedback())
    } else if newUserChat.isClosed() &&
      !self.createdFeedbackComplete {
      self.createdFeedbackComplete = true
      mainStore.dispatch(CreateCompletedFeedback())
    }
  }
  
  func showNewMessageBannerIfNeeded(current: [CHMessage], updated: [CHMessage]) {
    guard let lastMessage = updated.first, !lastMessage.isMine() else {
        return
    }
    
    let offset = self.tableView.contentOffset.y
    if self.chatManager.hasNewMessage(current: current, updated: updated) &&
      offset > UIScreen.main.bounds.height * 0.5 {
      self.newMessageView.configure(message: lastMessage)
      self.newMessageView.show(animated: true)
    }
  }
  
  func fixedOffsetIfNeeded(previousOffset: CGPoint, hasNewMessage: Bool) {
    var offset = previousOffset
    if let lastMessage = self.messages.first, !lastMessage.isMine(),
      offset.y > UIScreen.main.bounds.height/2, hasNewMessage {
      let previous: CHMessage? = self.messages.count >= 2 ? self.messages[1] : nil
      let viewModel = MessageCellModel(message: lastMessage, previous: previous)
      if lastMessage.messageType == .WebPage {
        offset.y += WebPageMessageCell.cellHeight(fits: 0, viewModel: viewModel)
      } else if lastMessage.messageType == .Media {
        offset.y += MediaMessageCell.cellHeight(fits: 0, viewModel: viewModel)
      } else if lastMessage.messageType == .File {
        offset.y += FileMessageCell.cellHeight(fits: 0, viewModel: viewModel)
      } else {
        offset.y += MessageCell.cellHeight(fits: 0, viewModel: viewModel)
      }
      
      self.tableView.contentOffset = offset
    } else if hasNewMessage {
      self.scrollToBottom(false)
    }
  }
  
  fileprivate func scrollToBottom(_ animated: Bool) {
    self.tableView.scrollToRow(
      at: IndexPath(row:0, section:0),
      at: UITableViewScrollPosition.bottom,
      animated: animated
    )
  }
  
  private func isNewChat(with current: CHUserChat?, nextUserChat: CHUserChat?) -> Bool {
    return userChat == nil && nextUserChat == nil
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
      self.chatManager.createChat(completion: { [weak self] (userChatId) in
        if let userChatId = userChatId {
          self?.userChatId = userChatId
          self?.sendMessage(userChatId: userChatId, text: msg)
        } else {
          self?.chatManager.state = .chatNotLoaded
        }
      })
    } else {
      mainStore.dispatch(RemoveMessages(payload: userChatId))
      self.newChatSubject.onNext(self.textView.text)
    }
    self.shyNavBarManager.contract(true)
    super.didPressRightButton(sender)
  }

  override func forceTextInputbarAdjustment(for responder: UIResponder?) -> Bool {
    // TODO: check if responder is equal to our text field
    return true
  }

  private func presentPicker(
    type: DKImagePickerControllerSourceType,
    max: Int = 0,
    assetType: DKImagePickerControllerAssetType = .allAssets) {
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
          //TODO: rather create array of signal and trigger in order
          self?.chatManager.sendMessageRecursively(allMessages: messages, currentIndex: 0)
        }
        
        if let userChatId = self?.userChatId {
          uploadImage(userChatId)
        } else {
          self?.chatManager.createChat(completion: { (userChatId) in
            self?.userChatId = userChatId
            if let userChatId = userChatId {
              uploadImage(userChatId)
            } else {
              self?.chatManager.state = .chatNotLoaded
            }
          })
        }
      }
      self.present(pickerController, animated: true, completion: nil)
  }

  private func updatePhotoUrls(messages: [CHMessage]) {
    self.photoUrls = messages.filter({ $0.file?.isPreviewable == true })
      .map({ (message) -> String in
        return message.file?.url ?? ""
      })
    
    self.photoBrowser?.reloadData()
  }
  
  override func textViewDidChange(_ textView: UITextView) {
    self.chatManager.sendTyping(isStop: textView.text == "")
  }
}

// MARK: - UIScrollViewDelegate

extension UserChatViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    let triggerPoint = yOffset + UIScreen.main.bounds.height * 1.5
    if triggerPoint > scrollView.contentSize.height && self.chatManager.canLoadMore() {
      self.chatManager.fetchMessages()
    }
    
    if yOffset < 100 &&
      !self.newMessageView.isHidden {
      self.newMessageView.hide(animated: false)
    }
  }
}

// MARK: - UITableView

extension UserChatViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.channel.servicePlan == "free" ? 3 : 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return self.channel.servicePlan == "free" ? 1 : self.messages.count
    } else if section == 2 {
      return self.channel.servicePlan == "free" ? self.messages.count : 0
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    }
    
    if indexPath.section == 1 && self.channel.servicePlan == "free" {
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
      return DateCell.cellHeight()
    case .NewAlertMessage:
      return NewMessageDividerCell.cellHeight()
    case .SatisfactionFeedback:
      return SatisfactionFeedbackCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel) //158 + 16
    case .SatisfactionCompleted:
      return SatisfactionCompleteCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel) //104 + 16
    case .Log:
      return LogCell.cellHeight(fit: tableView.frame.width, viewModel: viewModel)
    case .UserInfoDialog:
      let model = DialogViewModel.model(type: message.userGuideDialogType)
      return UserInfoDialogCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: model)
    case .Media:
      return MediaMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    case .File:
      return FileMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    case .WebPage:
      return WebPageMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    default:
      let calSize = MessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
      return calSize
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    if section == 0 && self.channel.servicePlan == "free" {
      let cell: WatermarkCell = tableView.dequeueReusableCell(for: indexPath)
      _ = cell.signalForClick().subscribe { _ in
        let channel = mainStore.state.channel
        let channelName = channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let urlString = CHUtils.getUrlForUTM(source: "plugin_watermark", content: channelName)
        
        if let url = URL(string: urlString) {
          url.open()
        }
      }
      cell.transform = tableView.transform
      return cell
    } else if section == 0 || (section == 1 && self.channel.servicePlan == "free") {
      let cell = self.cellForTyping(tableView, cellForRowAt: indexPath)
      cell.transform = tableView.transform
      return cell
    } else {
      let cell = self.cellForMessage(tableView, cellForRowAt: indexPath)
      cell.transform = tableView.transform
      return cell
    }
  }
  
  func cellForTyping(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let typingCell = self.typingCell {
      typingCell.configure(typingUsers: self.chatManager.typers)
      typingCell.transform = tableView.transform
      return typingCell
    }
    return UITableViewCell()
  }
  
  func cellForMessage(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = self.messages[indexPath.row]
    let previousMessage: CHMessage? =
      indexPath.row == self.messages.count - 1 ?
        self.messages[indexPath.row] :
        self.messages[indexPath.row + 1]
    let viewModel = MessageCellModel(message: message, previous: previousMessage)
    
    switch message.messageType {
    case .NewAlertMessage:
      let cell: NewMessageDividerCell = tableView.dequeueReusableCell(for: indexPath)
      return cell
    case .DateDivider:
      let cell: DateCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(date: message.message ?? "")
      return cell
    case .Log:
      let cell: LogCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(message: message)
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
      return cell
    case .SatisfactionCompleted:
      let cell: SatisfactionCompleteCell = tableView.dequeueReusableCell(for: indexPath)
      let chat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
      cell.configure(review: chat?.review, duration: chat?.resolutionTime)
      return cell
    case .UserMessage:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      return cell
    case .WebPage:
      let cell: WebPageMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      cell.signalForClick().subscribe{ [weak self] _ in
        self?.didWebPageTapped(message: message)
      }.disposed(by: self.disposeBag)
      return cell
    case .Media:
      let cell: MediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      cell.signalForClick().subscribe { [weak self] _ in
        self?.didImageTapped(message: message)
      }.disposed(by: self.disposeBag)
      return cell
    case .File:
      let cell: FileMessageCell = tableView.dequeueReusableCell(for: indexPath, cellType: FileMessageCell.self)
      //let cell: FileMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      cell.signalForClick().subscribe { [weak self] _ in
        self?.didFileTapped(message: message)
      }.disposed(by: self.disposeBag)
      return cell
    default: //remote
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
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
    self.photoBrowser?.enableSwipeToDismiss = true
    
    let navigation = MainNavigationController(rootViewController: self.photoBrowser!)
    navigation.useDefault = true
    navigation.modalPresentationStyle = .overCurrentContext
    
    if let index = self.photoUrls.index(of: imgUrl ?? "") {
      self.dismissKeyboard(true)
      self.photoBrowser?.setCurrentPhotoIndex(UInt(index))
      
      self.present(navigation, animated: true, completion: nil)
      //_ = self.navigationController?.pushViewController(self.photoBrowser!, animated: true)
    }
  }
  
  func didFileTapped(message: CHMessage) {
    guard let url = message.file?.url else { return }
    
    if message.file?.category == "video" {
      let moviePlayer = AVPlayerViewController()
      let player = AVPlayer(url: URL(string: url)!)
      moviePlayer.player = player
      moviePlayer.modalPresentationStyle = .overFullScreen
      moviePlayer.modalTransitionStyle = .crossDissolve
      self.present(moviePlayer, animated: true, completion: nil)
      return
    }
    
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
    let shouldHandle = ChannelIO.delegate?.onClickChatLink?(url: url)
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

//extension UserChatViewController : CHNavigationDelegate {
//  func willPopViewController(willShow: UIViewController) {
//    if self.userChatId != nil {
//      self.requestReadAll()
//    }
//  }
//}

extension UserChatViewController : SLKInputBarViewDelegate {
  func barStateDidChange(_ state: SLKInputBarState) {
    self.textInputbar.layer.cornerRadius = 5
    self.textInputbar.clipsToBounds = true
    self.textInputbar.layer.borderWidth = 2
    
    if state == .disabled {
      self.textInputbar.layer.borderColor = CHColors.paleGrey.cgColor
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

extension UserChatViewController: ChatDelegate {
  func update(for element: ChatElement) {
    switch element {
    case .typing(_, _):
      let indexPath = IndexPath(row: 0, section: self.channel.servicePlan == "free" ? 1 : 0)
      if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true,
        let typingCell = self.typingCell {
        typingCell.configure(typingUsers: self.chatManager.typers)
      }
    case .photos(let urls):
      self.photoUrls = urls
      self.photoBrowser?.reloadData()
    default:
      break
    }
  }
  
  func showError() {
    if self.shyNavBarManager.isExpanded() {
      self.shyNavBarManager.contract(false)
    }
    self.chatManager.didChatLoaded = false
    self.errorToastView.show(animated: true)
  }
  
  func hideError() {
    self.errorToastView.hide(animated: true)
  }
  
  func readyToDisplay() {
    self.initDwifft()
    self.tableView.isHidden = false
  }
}

extension UserChatViewController : TLYShyNavBarManagerDelegate {
  func shyNavBarManagerTransforming(_ shyNavBarManager: TLYShyNavBarManager!, progress: CGFloat) {
    self.titleView?.expand(with: progress)
  }
  
  func shyNavBarManagerDidBecomeFullyExpanded(_ shyNavBarManager: TLYShyNavBarManager!) {
    if self.titleView?.isExpanded == false {
      self.titleView?.isExpanded = true
    }
  }
  
  func shyNavBarManagerDidBecomeFullyContracted(_ shyNavBarManager: TLYShyNavBarManager!) {
    if self.titleView?.isExpanded == true {
      self.titleView?.isExpanded = false
    }
  }
}

