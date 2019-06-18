//
//  UserChatController.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
//import CHDwifft
import ReSwift
import RxSwift
import SVProgressHUD
import CHSlackTextViewController
import CHNavBar
import AVKit
import SnapKit
import SDWebImage

final class UserChatViewController: BaseSLKTextViewController {

  // MARK: Constants
  private struct Constants {
    static let messagePerRequest = 30
    static let messageCellMaxWidth = UIScreen.main.bounds.width
  }
  
  private struct Metrics {
    static let newButtonHeight = 46
  }
  
  var placeHolder: UIView? = nil
  var isReadyToDisplay: Bool = false
  
  // MARK: Properties
  var channel: CHChannel = mainStore.state.channel
  var userChatId: String?
  var userChat: CHUserChat?
  
  var preloadText: String = ""
  var isFetching = false
  var isRequstingReadAll = false
  
  var photoUrls = [String]()
  var typingManagers = [CHManager]()
  var timeStorage = [String: Timer]()
  var previousMaxContentHeight: CGFloat = 0.f
  
  //var diffCalculator: SingleSectionTableViewDiffCalculator<CHMessage>?
  var messages = [CHMessage]()

  var disposeBag = DisposeBag()
  var notiDisposeBag = DisposeBag()
  
  var currentLocale: CHLocaleString? = CHUtils.getLocale()
  var chatManager : ChatManager!
  
  var viewerTransitionDelegate: ZoomAnimatedTransitioningDelegate? = nil
  var chatUpdateSubject = PublishSubject<Any?>()
  var navigationUpdateSubject = PublishSubject<(AppState, CHUserChat?, Bool)>()
  var fixedInset: Bool = false
  
  var newMessageView = NewMessageBannerView().then {
    $0.isHidden = true
  }
  
  var nudgeKeepButton = CHButtonFactory.keepNudge().then {
    $0.isHidden = true
  }
  
  var newChatButton = CHButtonFactory.newChat().then {
    $0.isHidden = true
  }
  
  var chatBlockView = UserChatBottomBlockView().then {
    $0.configure(message:CHAssets.localized("ch.message_input.placeholder.disabled_new_chat"))
    $0.isHidden = true
  }
  
  var isAnimating = false
  var newChatBottomConstraint: Constraint? = nil
  
  var typingCell: TypingIndicatorCell!
  var profileCell: ProfileCell!
  
  var profileIndexPath: IndexPath?
  
  var newChatSubject = PublishSubject<Any?>()
  var profileSubject = PublishSubject<Any?>()
  
  var animatedMessages: [String:CHMessage] = [:]
  
  deinit {
    self.chatManager?.prepareToLeave()
    self.chatManager?.leave()
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
    self.initNavigationViews(with: self.userChat)
    self.initSLKTextView()
    self.initTypingCell()
    self.initTableView()
    self.initInputViews()
    self.initViews()
    self.initActionButtons()

    self.initUpdaters()
    self.showLoader()
    
    if mainStore.state.messagesState.supportBotEntry != nil && self.userChatId == nil {
      self.setTextInputbarHidden(true, animated: false)
      mainStore.dispatch(InsertSupportBotEntry())
      self.readyToDisplay()
    } else if self.userChatId == nil {
      mainStore.dispatch(InsertWelcome())
      self.readyToDisplay()
    } else if self.userChatId?.hasPrefix(CHConstants.nudgeChat) == true {
      self.readyToDisplay()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    self.navigationController?.dropShadow()
    self.initObservers()
    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let count = self.navigationController?.viewControllers.count, count == 1 {
      self.navigationController?.setNavigationBarHidden(true, animated: true)
      self.navigationController?.removeShadow()
    }
    self.removeObservers()
    mainStore.unsubscribe(self)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.navigationController?.preferredStatusBarStyle ?? .lightContent
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.adjustTableViewInset()
  }
  
  @discardableResult
  func adjustTableViewInset(bottomInset: CGFloat = 0.f) -> Bool {
    
    
    let chatViewHeight = self.tableView.frame.height
    if self.tableView.contentSize.height <= chatViewHeight {
      guard self.tableView.contentSize.height > 40 else { return false }
      var currInset = self.tableView.contentInset
      currInset.top = chatViewHeight - self.tableView.contentSize.height

      self.tableView.contentInset = currInset
      return true
    } else {
      guard !self.fixedInset else { return false }
      
      self.tableView.contentInset = UIEdgeInsets(
        top: bottomInset,
        left: 0,
        bottom: self.tableView.contentInset.bottom,
        right: 0)
      
      return false
    }
  }
  
  func initUpdaters() {
    self.navigationUpdateSubject
      .takeUntil(self.rx.deallocated)
      .debounce(0.7, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (state, chat, update) in
        self?.updateNavigationIfNeeded(state: state, nextUserChat: chat, shouldUpdate: update)
      }).disposed(by: self.disposeBag)
    
    self.chatUpdateSubject
      .takeUntil(self.rx.deallocated)
      .debounce(0.7, scheduler: ConcurrentMainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.fetchChatIfNeeded()
      }).disposed(by: self.disposeBag)
  }
  
  func initObservers() {
    NotificationCenter.default
      .rx.notification(UIResponder.keyboardDidShowNotification)
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] (event) in
        let userInfo = event.element?.userInfo
        guard let keyboardEndFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let s = self else { return }
        let keyboardFrame = s.view.convert(keyboardEndFrame, from: nil)
        let newHeight = s.view.frame.size.height - keyboardFrame.origin.y
        if newHeight < 0 || newHeight > UIScreen.main.bounds.height {
          return
        }
        self?.adjustTableViewInset()
      }.disposed(by: self.notiDisposeBag)
    
    ChannelAvailabilityChecker.shared.updateSignal
      .flatMap({ (_) -> Observable<CHChannel> in
        return ChannelPromise.getChannel()
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (channel) in
        mainStore.dispatch(UpdateChannel(payload: channel))
      }).disposed(by: self.notiDisposeBag)
  }
  
  func removeObservers(){
    self.notiDisposeBag = DisposeBag()
  }
  
  fileprivate func initManagers() {
    self.chatManager = ChatManager(id: self.userChatId)
    self.chatManager.chat = userChatSelector(
      state: mainStore.state,
      userChatId: self.userChatId)
    self.chatManager.viewController = self
    self.chatManager.delegate = self
    self.chatManager.prepareToChat()
  }
  
  fileprivate func initActionButtons() {
    self.view.addSubview(self.newChatButton)
    self.newChatButton.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
        self?.newChatSubject.onNext(nil)
      }).disposed(by: self.disposeBag)
    
    self.newChatButton.snp.makeConstraints { [weak self] (make) in
      self?.newChatBottomConstraint = make.bottom.equalToSuperview().inset(40).constraint
      make.centerX.equalToSuperview()
      make.height.equalTo(Metrics.newButtonHeight)
    }
    
    self.view.addSubview(self.nudgeKeepButton)
    self.nudgeKeepButton.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        self?.chatManager.processNudgeKeepAction()
      }).disposed(by: self.disposeBag)
    
    self.nudgeKeepButton.snp.makeConstraints { [weak self] (make) in
      self?.newChatBottomConstraint = make.bottom.equalToSuperview().inset(40).constraint
      make.centerX.equalToSuperview()
      make.height.equalTo(Metrics.newButtonHeight)
    }
  }
  
  // MARK: - Helper methods
  fileprivate func initSLKTextView() {
    self.leftButton.setImage(CHAssets.getImage(named: "add"), for: .normal)
    self.textView.keyboardType = .default
    self.setTextInputbarHidden(true, animated: false)
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
      if self?.textInputbar.barState == .disabled && self?.chatManager?.profileIsFocus == false {
        return
      }
      self?.presentKeyboard(self?.menuAccesoryView == nil)
    }.disposed(by: self.disposeBag)
    
    self.tableView.signalForClick().subscribe { [weak self] _ in
      NotificationCenter.default.post(name: Notification.Name.Channel.dismissKeyboard, object: nil)
      self?.dismissKeyboard(true)
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
    self.tableView.register(cellType: LogCell.self)
    self.tableView.register(cellType: TypingIndicatorCell.self)
    self.tableView.register(cellType: ProfileCell.self)
    self.tableView.register(cellType: ActionMessageCell.self)
    self.tableView.register(cellType: ActionWebMessageCell.self)
    self.tableView.register(cellType: ActionMediaMessageCell.self)
    self.tableView.register(cellType: ActionFileMessageCell.self)
    self.tableView.register(cellType: ButtonsMessageCell.self)
    
    self.tableView.estimatedRowHeight = 0
    self.tableView.clipsToBounds = true
    self.tableView.separatorStyle = .none
    self.tableView.allowsSelection = false
    self.tableView.showsHorizontalScrollIndicator = false
    self.tableView.showsVerticalScrollIndicator = false
  }

  func initTypingCell() {
    let cell = TypingIndicatorCell()
    cell.configure(typingUsers: [])
    self.typingCell = cell
    
    let profileCell = ProfileCell()
    self.profileCell = profileCell
  }

  // MARK: - Helper methods

  fileprivate func initNavigationViews(with userChat: CHUserChat? = nil) {
    self.userChat = userChatSelector(state: mainStore.state, userChatId: self.userChatId)
    //TODO: take this out from redux
    let userChats = userChatsSelector(
      state: mainStore.state,
      showCompleted: mainStore.state.userChatsState.showCompletedChats
    )
    
    self.setNavItems(
      showSetting: userChats.count == 0,
      currentUserChat: userChat ?? self.userChat,
      guest: mainStore.state.guest,
      textColor: mainStore.state.plugin.textUIColor
    )
    
    self.initNavigationTitle(with: userChat ?? self.userChat)

    if let nav = self.navigationController as? MainNavigationController {
      nav.newState(state: mainStore.state.plugin)
    }
  }
  
  func initNavigationTitle(with userChat: CHUserChat? = nil) {
    var navigationTitleView: UIView?
    if let userChat = userChat, let host = userChat.lastTalkedHost {
      let titleView = ChatNavigationFollowingTitleView()
      titleView.configure(host: host, plugin: mainStore.state.plugin)
      navigationTitleView = titleView
    } else {
      let titleView = ChatNavigationTitleView()
      titleView.configure(
        channel: mainStore.state.channel,
        plugin: mainStore.state.plugin
      )
      navigationTitleView = titleView
    }
    
    navigationTitleView?.translatesAutoresizingMaskIntoConstraints = false
    navigationTitleView?.layoutIfNeeded()
    navigationTitleView?.sizeToFit()
    navigationTitleView?.translatesAutoresizingMaskIntoConstraints = true
    self.navigationItem.titleView = navigationTitleView
  }

  fileprivate func initViews() {
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
    
    self.view.addSubview(self.chatBlockView)
    self.chatBlockView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      } else {
        make.bottom.equalToSuperview()
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  fileprivate func setNavItems(showSetting: Bool, currentUserChat: CHUserChat?, guest: CHGuest, textColor: UIColor) {
    let tintColor = mainStore.state.plugin.textUIColor
    
    let alert = (guest.alert ?? 0) - (currentUserChat?.session?.alert ?? 0)
    let alertCount = alert > 99 ? "99+" : (alert > 0 ? "\(alert)" : nil)
    let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    spacer.width = -16
    
    let backButton = NavigationRoundLabelBackItem(
      text: alert == 0 ? "" : alertCount,
      textColor: mainStore.state.plugin.bgColor,
      textBackgroundColor: tintColor,
      actionHandler: { [weak self] in
        _ = self?.navigationController?.popViewController(animated: true)
      })
    
    if #available(iOS 11, *) {
      self.navigationItem.leftBarButtonItems = [backButton]
    } else {
      self.navigationItem.leftBarButtonItems = [spacer, backButton]
    }
    
    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "closeWhite"),
      tintColor: mainStore.state.plugin.textUIColor,
      style: .plain,
      actionHandler: { [weak self] in
        mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
        ChannelIO.close(animated: true)
      })
  }
}

// MARK: - StoreSubscriber

extension UserChatViewController: StoreSubscriber {

  func newState(state: AppState) {
    self.userChatId = self.chatManager.chatId
    let shouldUpdate = self.channel.isDiff(from: state.channel)
    
    let messages = messagesSelector(state: state, userChatId: self.userChatId)
    self.showNewMessageBannerIfNeeded(current: self.messages, updated: messages)
    
    //saved contentOffset
    let offset = self.tableView.contentOffset
    let hasNewMessage = self.chatManager.hasNewMessage(current: self.messages, updated: messages)
    
    //message only needs to be replace if count is differe
    self.messages = messages

    let userChat = userChatSelector(state: state, userChatId: self.userChatId)
    
    self.navigationUpdateSubject.onNext((state, userChat, shouldUpdate))
    self.updateInputViewsBasedOnState(userChat: self.userChat, nextUserChat: userChat, channel: state.channel)
    self.showErrorIfNeeded(state: state)
    self.chatUpdateSubject.onNext(nil)
    
    if hasNewMessage {
      self.tableView.reloadData()
      self.tableView.layoutIfNeeded()
      
       // Photo - is this scalable? or doesn't need to care at this moment?
      self.photoUrls = messages.reversed()
        .filter({ $0.file?.isPreviewable == true })
        .map({ (message) -> String in
          return message.file?.url ?? ""
        })
    }
    
    self.fixedOffsetIfNeeded(previousOffset: offset, hasNewMessage: hasNewMessage)
    self.adjustTableViewInset()
    
    self.channel = state.channel
    self.userChat = userChat
    self.newChatButton.isEnabled = self.channel.allowNewChat
  }
  
  func updateNavigationIfNeeded(state: AppState, nextUserChat: CHUserChat?, shouldUpdate: Bool) {
    if shouldUpdate {
      self.initNavigationViews(with: nextUserChat)
    }
    else if self.userChat?.hostId != nextUserChat?.hostId {
      self.initNavigationViews(with: nextUserChat)
    }
    else if self.channel.isDiff(from: state.channel) {
      self.initNavigationViews(with: nextUserChat)
    }
    else if self.currentLocale != ChannelIO.settings?.appLocale {
      self.initNavigationViews(with: nextUserChat)
      self.currentLocale = ChannelIO.settings?.appLocale
    }
    else {
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
  }
  
  func fetchChatIfNeeded() {
    if self.chatManager.needToFetchChat() == true {
      self.chatManager.fetchChat()
        .observeOn(MainScheduler.instance)
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
  
  func updateInputViewsBasedOnState(
    userChat: CHUserChat?,
    nextUserChat: CHUserChat?,
    channel: CHChannel) {
    guard self.isReadyToDisplay else { return }
    
    if let isNudgeChat = userChat?.fromNudge, isNudgeChat {
      self.nudgeKeepButton.isHidden = false
    } else {
      self.nudgeKeepButton.isHidden = true
    }
    
    if nextUserChat?.isRemoved == true {
      _ = self.navigationController?.popViewController(animated: true)
    }
    else if nextUserChat?.isClosed == true {
      self.setTextInputbarHidden(true, animated: false)
      if !self.adjustTableViewInset(bottomInset: 60.f) {
        self.fixedInset = true
        self.scrollToBottom(false)
      }
      self.newChatButton.isHidden = false

      self.chatBlockView.isHidden = true
    }
    else if nextUserChat?.fromNudge == true {
      self.setTextInputbarHidden(true, animated: false)
      self.adjustTableViewInset(bottomInset: 60.f)
      self.chatBlockView.isHidden = true
    }
    else if channel.allowNewChat == false && self.textView.text == "" {
      self.setTextInputbarHidden(true, animated: false)
      if !self.adjustTableViewInset(bottomInset: self.chatBlockView.viewHeight()) {
        self.fixedInset = true
        self.scrollToBottom(false)
      }
      self.chatBlockView.isHidden = false
    }
    else if nextUserChat?.isSupporting == true ||
      nextUserChat?.isSolved == true ||
      (mainStore.state.messagesState.supportBotEntry != nil && nextUserChat == nil) {
      self.setTextInputbarHidden(true, animated: false)
      self.chatBlockView.isHidden = true
    }
    else if !self.chatManager.profileIsFocus {
      self.fixedInset = false
      self.adjustTableViewInset(bottomInset: 0.f)
      self.chatBlockView.isHidden = true
      self.rightButton.setImage(CHAssets.getImage(named: "sendActive")?.withRenderingMode(.alwaysOriginal), for: .normal)
      self.rightButton.setImage(CHAssets.getImage(named: "sendDisabled")?.withRenderingMode(.alwaysOriginal), for: .disabled)
      self.rightButton.setTitle("", for: .normal)
      self.leftButton.setImage(CHAssets.getImage(named: "add"), for: .normal)
      
      self.textInputbar.barState = .normal
      self.textInputbar.setButtonsHidden(false)
      
      self.textView.isEditable = true
      self.textView.placeholder = CHAssets.localized("ch.message_input.placeholder")
      self.setTextInputbarHidden(false, animated: false)
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
        offset.y += WebPageMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
      } else if lastMessage.messageType == .Media {
        offset.y += MediaMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
      } else if lastMessage.messageType == .File {
        offset.y += FileMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
      } else if lastMessage.messageType == .Profile {
        offset.y += ProfileCell.cellHeight(fits: self.tableView.frame.width, viewModel: viewModel)
      } else if viewModel.shouldDisplayForm {
        offset.y += ActionMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
      } else {
        offset.y += MessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
      }
      
      self.tableView.contentOffset = offset
    } else if hasNewMessage && self.tableView.contentSize.height > self.tableView.frame.height {
      self.scrollToBottom(false)
    }
  }
  
  fileprivate func scrollToBottom(_ animated: Bool) {
    self.tableView.scrollToRow(
      at: IndexPath(row:0, section:0),
      at: .bottom,
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
    
    let button = sender as! UIButton
    let alertView = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)

    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.camera"), style: .default) { [weak self] _ in
        self?.chatManager?.presentCameraPicker(from: self)
      })

    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.photo.album"), style: .default) { [weak self] _ in
        self?.chatManager?.presentPicker(max: 20, from: self)
      })

    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in

      })

    if let popOver = alertView.popoverPresentationController {
      popOver.sourceView = button
      popOver.sourceRect = button.bounds
      popOver.permittedArrowDirections = .down
    }
    
    self.present(alertView, animated: true, completion: nil)
  }

  override func didPressRightButton(_ sender: Any?) {
    // This little trick validates any pending auto-correction or 
    // auto-spelling just after hitting the 'Send' button
    
    self.textView.refreshFirstResponder()
    let msg = self.textView.text!
    
    self.chatManager.processSendMessage(msg: msg)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (chat) in
        self?.userChat = chat
        self?.userChatId = chat?.id
      }, onError: { (error) in
        
      }).disposed(by: self.disposeBag)
    super.didPressRightButton(sender)
  }

  override func forceTextInputbarAdjustment(for responder: UIResponder?) -> Bool {
    // TODO: check if responder is equal to our text field
    return true
  }
  
  private func updatePhotoUrls(messages: [CHMessage]) {
    self.photoUrls = messages.filter({ $0.file?.isPreviewable == true })
      .map({ (message) -> String in
        return message.file?.url ?? ""
      })
  }
  
  override func textViewDidChange(_ textView: UITextView) {
    self.chatManager.sendTyping(isStop: textView.text == "")
    
    //hide input if
    // * channel is not working
    // * away option prevent chat
    // * text become empty
    if textView.text == "" && !self.channel.working && self.channel.allowNewChat == false {
      self.setTextInputbarHidden(true, animated: false)
      self.adjustTableViewInset(bottomInset: 60.f)
    }
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
    
    if yOffset < 100 && !self.newMessageView.isHidden {
      self.newMessageView.hide(animated: false)
    } else
      
    if yOffset > 100 {
      self.hideNewChatButton()
    }
  }
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard scrollView.contentOffset.y < 100 && self.userChat?.isClosed == true else { return }
    self.showNewChatButton()
  }

  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard scrollView.contentOffset.y < 100 && self.userChat?.isClosed == true else { return }
    self.showNewChatButton()
  }
}

extension UserChatViewController {
  fileprivate func showNewChatButton() {
    guard !self.isAnimating else { return }
    self.isAnimating = true
    
    self.newChatButton.isHidden = false
    self.newChatBottomConstraint?.update(inset: 40)
    
    UIView.animate(withDuration: 0.3, animations: {
      self.view.layoutIfNeeded()
    }) { (completed) in
      self.isAnimating = false
    }
  }
  
  fileprivate func hideNewChatButton() {
    if self.newChatButton.isHidden || self.isAnimating {
      return
    }
    self.isAnimating = true
    
    self.newChatBottomConstraint?.update(inset: -40 - Metrics.newButtonHeight)
    
    UIView.animate(withDuration: 0.3, animations: {
      self.view.layoutIfNeeded()
    }) { (completed) in
      self.newChatButton.isHidden = true
      self.isAnimating = false
    }
  }
}

// MARK: - UITableView

extension UserChatViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.channel.canUseSDK ? 2 : 3
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return self.channel.canUseSDK ? self.messages.count : 1
    } else if section == 2 {
      return self.channel.canUseSDK ? 0 : self.messages.count
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    }
    
    if indexPath.section == 1 && !self.channel.canUseSDK {
      return 40
    }
    
    let message = self.messages[indexPath.row]
    let previousMessage: CHMessage? =
      indexPath.row == self.messages.count - 1 ?
        nil : self.messages[indexPath.row + 1]
    let viewModel = MessageCellModel(
      message: message,
      previous: previousMessage,
      indexPath: indexPath)
    
    switch message.messageType {
    case .DateDivider:
      return DateCell.cellHeight()
    case .NewAlertMessage:
      return NewMessageDividerCell.cellHeight()
    case .Log:
      return LogCell.cellHeight(fit: tableView.frame.width, viewModel: viewModel)
    case .Media:
      return MediaMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
    case .File:
      return FileMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
    case .WebPage:
      return WebPageMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
    case .Profile:
      return ProfileCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
    case .Action:
      return ActionMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
    case .Buttons:
      return ButtonsMessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
    default:
      return MessageCell.cellHeight(fits: Constants.messageCellMaxWidth, viewModel: viewModel)
    }
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    if section == 0 || (section == 1 && !self.channel.canUseSDK) {
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
    let viewModel = MessageCellModel(
      message: message,
      previous: previousMessage,
      indexPath: indexPath)

    if viewModel.shouldDisplayForm {
      if viewModel.clipType == .Image {
        let cell: ActionMediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        cell.mediaView.signalForClick().subscribe { [weak self] _ in
          self?.didImageTapped(message: viewModel.message, indexPath: indexPath)
          }.disposed(by: self.disposeBag)
        return cell
      } else if viewModel.clipType == .Webpage {
        let cell: ActionWebMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        cell.webView.signalForClick().subscribe{ [weak self] _ in
          self?.chatManager?.didClickOnWebPage(with: viewModel.message)
          }.disposed(by: self.disposeBag)
        return cell
      } else if viewModel.clipType == .File {
        let cell: ActionFileMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        cell.fileView.signalForClick().subscribe { [weak self] _ in
          self?.chatManager?.didClickOnFile(with: viewModel.message)
          }.disposed(by: self.disposeBag)
        return cell
      } else {
        let cell: ActionMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        return cell
      }
    }
    
    if message.messageType == .NewAlertMessage {
      let cell: NewMessageDividerCell = tableView.dequeueReusableCell(for: indexPath)
      return cell
    } else if message.messageType == .DateDivider {
      let cell: DateCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(date: message.message ?? "")
      return cell
    } else if message.messageType == .Log {
      let cell: LogCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(message: message)
      return cell
    } else if message.messageType == .Profile {
      let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.chatManager)
      return cell
    } else if message.messageType == .Buttons {
      let cell: ButtonsMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.chatManager)
      return cell
    } else if viewModel.clipType == .Image {
      let cell: MediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.chatManager)
      cell.mediaView.signalForClick().subscribe { [weak self] _ in
        self?.didImageTapped(message: message, indexPath: indexPath)
      }.disposed(by: self.disposeBag)
      return cell
    } else if viewModel.clipType == .Webpage {
      let cell: WebPageMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.chatManager)
      cell.webView.signalForClick().subscribe{ [weak self] _ in
        self?.chatManager?.didClickOnWebPage(with: message)
      }.disposed(by: self.disposeBag)
      return cell
    } else if viewModel.clipType == .File {
      let cell: FileMessageCell = tableView.dequeueReusableCell(for: indexPath, cellType: FileMessageCell.self)
      cell.configure(viewModel, presenter: self.chatManager)
      cell.fileView.signalForClick().subscribe { [weak self] _ in
        self?.chatManager?.didClickOnFile(with: message)
      }.disposed(by: self.disposeBag)
      return cell
    } else {
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.chatManager)
      return cell
    }
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
  
  func didImageTapped(message: CHMessage, indexPath: IndexPath) {
    if let urlString = message.file?.imageRedirectUrl, let url = URL(string: urlString) {
      let shouldhandle = ChannelIO.delegate?.onClickRedirect?(url: url)
      if shouldhandle == nil || shouldhandle == false {
         url.openWithUniversal()
      }
    }
    else {
      let viewer = FullScreenSlideshowViewController()
      viewer.slideshow.circular = false
      viewer.slideshow.pageIndicator = LabelPageIndicator(frame: CGRect(x:0,y:0, width: UIScreen.main.bounds.width, height: 60))
      viewer.slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .customTop(padding: 5))
      
      viewer.inputs = self.photoUrls.map { (url) -> SDWebImageSource in
        return SDWebImageSource(url: URL(string: url)!)
      }
      let index = self.photoUrls.firstIndex(of: message.file?.url ?? "")
      if let index = index {
        viewer.initialPage = index
      }
      
      let cell = self.tableView.cellForRow(at: indexPath) as? MediaMessageCell
      if let cell = cell {
        self.viewerTransitionDelegate = ZoomAnimatedTransitioningDelegate(
          imageView: cell.mediaView.imageView,
          slideshowController: viewer)
        viewer.transitioningDelegate = self.viewerTransitionDelegate
      }
      
      viewer.slideshow.currentPageChanged = { [weak self] page in
        if let cell = cell {
          self?.viewerTransitionDelegate?.referenceImageView = page != index ? nil : cell.mediaView.imageView
        }
      }
      
      //TODO: move table position based on image view?
      self.present(viewer, animated: true, completion: nil)
    }
  }
}

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
      let indexPath = IndexPath(row: 0, section: self.channel.canUseSDK ? 0 : 1)
      if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true,
        let typingCell = self.typingCell {
        typingCell.configure(typingUsers: self.chatManager.typers)
      }
    case .photos(let urls):
      self.photoUrls = urls
    case .profile(_):
      self.textView.becomeFirstResponder()
      self.tableView.reloadData()
    default:
      break
    }
  }
  
  func updateInputBar(state: SLKInputBarState){
    self.textInputbar.barState = state;
  }
  
  func showError() {
    self.chatManager?.didChatLoaded = false
    CHNotification.shared.display(
      message: CHAssets.localized("ch.toast.unstable_internet"),
      config: CHNotificationConfiguration.warningNormalConfig
    )
  }
  
  func hideError() {
    CHNotification.shared.dismiss()
  }
  
  func readyToDisplay() {
    self.hideLoader()
    self.isReadyToDisplay = true
    self.tableView.isHidden = false
    self.updateInputViewsBasedOnState(
      userChat: self.userChat,
      nextUserChat: self.userChat,
      channel: self.channel
    )
  }
}

extension UserChatViewController {
  func showLoader() {
    guard self.placeHolder == nil else { return }
    let placeHolder = UIImageView(image:CHAssets.getImage(named: "messageLoader"))
    placeHolder.contentMode = .scaleToFill
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height))

    let layer = CAGradientLayer()
    layer.colors = [CHColors.paleGrey20.cgColor, CHColors.snow.cgColor]
    layer.startPoint = CGPoint(x:0, y:0.5)
    layer.endPoint = CGPoint(x:1, y:0.5)

    layer.frame = view.frame
    view.layer.addSublayer(layer)
    
    view.addSubview(placeHolder)
    view.mask = placeHolder
    
    self.view.addSubview(view)
  
    view.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.placeHolder = view
  }
  
  func hideLoader() {
    self.placeHolder?.removeFromSuperview()
    self.placeHolder = nil
  }
}
