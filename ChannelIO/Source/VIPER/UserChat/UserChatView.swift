//
//  UserChatView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 26/03/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import ReSwift
import RxSwift
import SVProgressHUD
import SnapKit
import Alamofire

class UserChatView: CHMessageViewController, UserChatViewProtocol {
  internal struct Constants {
    static let newMessageViewHeight = 48.f
    static let newMessageViewBottom = -6.f
    static let newChatButtonBottom = 40.f
    static let typerCellHeight = 40.f
    static let fileStatusCellHeight = 60.f
    static let MediaMessageCellLeading = 40.f
    static let MediaMessageCellTrailing = 74.f
    static let mediaMinWidth = 56.f
    static let mediaMinHeight = 56.f
    static let chatStartViewBottom = 9.f
    static let chatStartViewSide = 6.f
    static let chatBotStartViewHeight = 45.f
  }
  
  internal struct Sections {
    static let loadingFile = 0
    static let errorFiles = 1
    static let typer = 2
    static let messages = 3
  }
  
  internal struct Metrics {
    static let newButtonHeight = 46
  }
  
  private var viewBounds: CGRect = .zero
  private var tableViewOriginBottomInset: CGFloat = 0.f
  private var userChat: CHUserChat?
  
  var presenter: UserChatPresenterProtocol?
  
  internal let tableView = UITableView().then {
    $0.clipsToBounds = true
    $0.separatorStyle = .none
    $0.allowsSelection = false
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.isHidden = true
    
    $0.register(cellType: MediaMessageCell.self)
    $0.register(cellType: WebPageMessageCell.self)
    $0.register(cellType: MessageCell.self)
    $0.register(cellType: NewMessageDividerCell.self)
    $0.register(cellType: DateCell.self)
    $0.register(cellType: LogCell.self)
    $0.register(cellType: TypingIndicatorCell.self)
    $0.register(cellType: ProfileMessageCell.self)
    $0.register(cellType: ProfileWebMessageCell.self)
    $0.register(cellType: ProfileMediaMessageCell.self)
    $0.register(cellType: ActionMessageCell.self)
    $0.register(cellType: ActionWebMessageCell.self)
    $0.register(cellType: ActionMediaMessageCell.self)
    $0.register(cellType: FileStatusCell.self)
  }
  private var placeHolder: UIView? = nil
  private var newMessageView = NewMessageBannerView().then {
    $0.isHidden = true
  }
  private var newChatButton = CHButtonFactory.newChat().then {
    $0.isHidden = true
  }
  private var chatBlockView = UserChatBottomBlockView().then {
    $0.configure(
      message:CHAssets.localized("ch.message_input.placeholder.disabled_new_chat")
    )
    $0.isHidden = true
  }
  
  var currentPlayingVideo: VideoPlayerView?
  private var chatBotStartView = ChatBotStartView().then {
    $0.isHidden = true
  }
  
  internal var typers = [CHEntity]()
  
  private var fixedInset: Bool = false
  private var shouldShowInputBar: Bool = false
  
  internal var channel: CHChannel = mainStore.state.channel
  internal var messages = [CHMessage]()
  var videoRecords = [CHFile: Double]()
  
  internal var isLoadingFile = false
  internal var errorFiles: [ChatFileQueueItem] = []
  internal var loadingFile: ChatFileQueueItem?
  internal var waitingFileCount: Int = 0

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.viewBounds = self.view.bounds
    self.edgesForExtendedLayout = UIRectEdge.bottom
    self.view.backgroundColor = UIColor.white
    self.view.addSubview(self.tableView)
    
    // TODO: because of issue that swipe dissmiss while scroll to up
    if #available(iOS 13.0, *) {
      self.isModalInPresentation = true
    }
    
    self.initViews()
    self.initTableView()
    self.initMessageView()
    self.initNavigationViews(with: userChatSelector(
      state: mainStore.state, userChatId: self.presenter?.userChatId)
    )
    self.setup(scrollView: self.tableView)
    self.observeKeyboardChange()
    self.initActionButtons()
    self.showLoader()
    
    self.presenter?.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    self.navigationController?.dropShadow()
    self.presenter?.prepareDataSource()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if let count = self.navigationController?.viewControllers.count, count == 1 {
      self.navigationController?.setNavigationBarHidden(true, animated: true)
      self.navigationController?.removeShadow()
    }
    self.presenter?.cleanDataSource()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return self.navigationController?.preferredStatusBarStyle ?? .lightContent
  }
  
  override func textDidChange(text: String) {
    super.textDidChange(text: text)
    self.presenter?.sendTyping(isStop: text == "")
    
    if text == "" && !self.channel.working && !self.channel.allowNewChat {
      self.hideMessageView()
    }
  }
  
  private func observeKeyboardChange() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(keyboardChange(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(keyboardChange(notification:)),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(keyboardChange(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    notificationCenter.addObserver(
      self,
      selector: #selector(keyboardChange(notification:)),
      name: UIResponder.keyboardDidHideNotification,
      object: nil)
    notificationCenter.addObserver(
      self,
      selector: #selector(keyboardChange(notification:)),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
  }
  
  private func initNavigationViews(with userChat: CHUserChat?) {
    self.setNavItems(
      currentUserChat: userChat,
      user: mainStore.state.user
    )
    self.initNavigationTitle(with: userChat)
  }
  
  private func initNavigationTitle(with userChat: CHUserChat? = nil) {
    var navigationTitleView: UIView?
    if let userChat = userChat, let assignee = userChat.assignee {
      let titleView = ChatNavigationFollowingTitleView()
      titleView.configure(host: assignee, plugin: mainStore.state.plugin)
      navigationTitleView = titleView
    } else {
      let titleView = ChatNavigationTitleView()
      titleView.configure(
        channel: self.channel,
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
  
  private func initMessageView() {
    self.messageView.delegate = self
    self.hideMessageView()
    self.messageView.setPlaceholder(
      mode: .normal,
      text: CHAssets.localized("ch.message_input.placeholder"))
    self.messageView.setPlaceholder(
      mode: .disabled,
      text: CHAssets.localized("ch.message_input.placeholder"))
    self.messageView.mode = .normal
    let sendImage = CHAssets.getImage(
      named: "send")?.withRenderingMode(.alwaysTemplate)
    let clipImage = CHAssets.getImage(named: "clip")
    self.messageView.setButton(inset: 10, position: .left)
    self.messageView.setButton(inset: 10, position: .right)
    self.messageView.setButton(
      icon: clipImage,
      for: .normal,
      position: .left,
      size: CGSize(width: 30, height: self.messageView.height))
    self.messageView.setButton(
      icon: sendImage,
      for: .normal,
      position: .right,
      size: CGSize(width: 30, height: self.messageView.height))
    self.messageView.setButton(
      icon: sendImage,
      for: .disabled,
      position: .right,
      size: CGSize(width: 30, height: self.messageView.height))
    self.messageView.addButton(
      target: self,
      action: #selector(self.didPressAssetButton),
      position: .left)
    self.messageView.addButton(
      target: self,
      action: #selector(self.didPressSendButton),
      position: .right)
    self.messageView.rightButtonIsEnable = false
    self.messageView.textViewInset = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 20)
    self.messageView.font = UIFont.systemFont(ofSize: 14)
    self.messageView.maxHeight = 184
    self.messageView.textContainerView
      .signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        self.messageView.becomeResponder(
          mode: .normal,
          animated: !self.isAccessoryViewVisible)
    }).disposed(by: self.disposeBag)
  }

  private func initActionButtons() {
    self.view.addSubview(self.newChatButton)
    self.newChatButton.signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnNewChat(with: "", from: self?.navigationController)
    }).disposed(by: self.disposeBag)
    
    self.newChatButton.snp.makeConstraints { (make) in
      make.bottom.equalToSuperview().inset(Constants.newChatButtonBottom)
      make.centerX.equalToSuperview()
      make.height.equalTo(Metrics.newButtonHeight)
    }
  }

  private func initTableView() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableViewOriginBottomInset = self.tableView.contentInset.bottom
    self.tableView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.bottom.equalTo(self.messageView.snp.top)
      make.left.equalToSuperview()
      make.right.equalToSuperview()
    }
  }

  private func initViews() {
    self.view.addSubview(self.newMessageView)
    self.newMessageView.snp.makeConstraints { (make) in
      make.height.equalTo(Constants.newMessageViewHeight)
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.messageView.snp.top)
        .offset(Constants.newMessageViewBottom)
    }
    
    self.newMessageView.signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (event) in
        self?.scrollToBottom(false)
      }).disposed(by: self.disposeBag)
    
    self.view.addSubview(self.chatBlockView)
    self.chatBlockView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      } else {
        make.bottom.equalToSuperview()
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    self.view.addSubview(self.chatBotStartView)
    self.chatBotStartView.snp.makeConstraints { [weak self] (make) in
      guard let self = self else { return }
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
          .inset(Constants.chatStartViewBottom)
      } else {
        make.bottom.equalToSuperview().inset(Constants.chatStartViewBottom)
      }
      make.leading.equalToSuperview().inset(Constants.chatStartViewSide)
      make.trailing.equalToSuperview().inset(Constants.chatStartViewSide)
      make.height.equalTo(Constants.chatBotStartViewHeight)
    }
    self.chatBotStartView.signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnMarketingToSupportBotButton()
      }).disposed(by: self.disposeBag)
  }

  private func setNavItems(currentUserChat: CHUserChat?, user: CHUser) {
    let tintColor = mainStore.state.plugin.textUIColor
    
    let alert = (user.alert ?? 0) - (currentUserChat?.session?.alert ?? 0)
    let alertCount = alert > 99 ? "99+" : (alert > 0 ? "\(alert)" : nil)
    let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    spacer.width = -8
    
    let backButton = NavigationRoundLabelBackItem(
      text: alert == 0 ? "" : alertCount,
      textColor: mainStore.state.plugin.bgColor,
      textBackgroundColor: tintColor,
      actionHandler: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
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
        self?.presenter?.didClickOnRightNaviItem(from: self)
      })
  }
  
  private func showLoader() {
    guard self.placeHolder == nil else { return }
    let placeHolder = UIImageView(image:CHAssets.getImage(named: "messageLoader"))
    placeHolder.contentMode = .scaleToFill
    
    let view = UIView(frame: CGRect(
      x: 0,
      y: 0,
      width: self.tableView.frame.size.width,
      height: self.tableView.frame.size.height
    ))

    let layer = CAGradientLayer()
    layer.colors = [CHColors.paleGrey20.cgColor, CHColors.snow.cgColor]
    layer.startPoint = CGPoint(x:0, y:0.5)
    layer.endPoint = CGPoint(x:1, y:0.5)
    
    layer.frame = view.frame
    view.layer.addSublayer(layer)
    
    view.addSubview(placeHolder)
    view.mask = placeHolder
    view.backgroundColor = .grey200
    
    self.view.addSubview(view)

    view.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.placeHolder = view
  }
  
  private func hideLoader() {
    guard self.placeHolder != nil else { return }
    self.placeHolder?.removeFromSuperview()
    self.placeHolder = nil
    if self.shouldShowInputBar {
      self.showMessageView()
    }
  }
  
  @objc private func didPressSendButton() {
    guard self.messageView.text != "" else { return }
    self.presenter?.didClickOnSendButton(text: self.messageView.text)
    self.messageView.text = ""
  }
  
  @objc private func didPressAssetButton() {
    self.dismissKeyboard(true)
    self.presenter?.didClickOnClipButton(from: self)
  }
  
  private func updateInputField(userChat: CHUserChat?) {
    let needToSupportBot = userChat?.lastMessage?.marketing?.enableSupportBot == true
    let isSupportBotEntry = mainStore.state.messagesState.supportBotEntry != nil
    
    self.shouldShowInputBar = false
    self.chatBlockView.isHidden = true
    self.chatBotStartView.isHidden = true
    
    if userChat?.isRemoved == true {
      _ = self.navigationController?.popViewController(animated: true)
    } else if userChat?.isClosed == true {
      self.hideMessageView()
      self.newChatButton.isHidden = false
    } else if needToSupportBot && isSupportBotEntry {
      self.hideMessageView()
      self.chatBotStartView.isHidden = false
    } else if userChat?.isSupporting == true ||
      userChat?.isSolved == true ||
      (isSupportBotEntry && userChat == nil) {
      self.hideMessageView()
    } else if !self.channel.allowNewChat && self.messageView.text == "" {
      self.hideMessageView()
      self.chatBlockView.isHidden = false
    } else if self.presenter?.isProfileFocus != true {
      self.placeHolder != nil ? self.shouldShowInputBar = true : self.showMessageView()
    }
  }
  
  private func adjustTableViewInsetIfneeded(userChat: CHUserChat?) {
    let needToSupportBot = userChat?.lastMessage?.marketing?.enableSupportBot == true
    let isSupportBotEntry = mainStore.state.messagesState.supportBotEntry != nil
    self.paintSafeAreaBottomInset(with: nil)

    if userChat?.isClosed == true {
      if !self.adjustTableViewInset(bottomInset: 60.f) {
        self.fixedInset = true
        self.scrollToBottom(false)
      }
    } else if needToSupportBot && isSupportBotEntry {
      self.adjustTableViewInset(bottomInset: 60.f)
    } else if userChat?.isSupporting == true ||
      userChat?.isSolved == true ||
      (isSupportBotEntry && userChat == nil) {
     self.adjustTableViewInset(bottomInset: 60.f)
    } else if !self.channel.allowNewChat && self.messageView.text == "" {
      let bottomInset = self.chatBlockView.viewHeight(width: self.tableView.frame.width)
      if !self.adjustTableViewInset(bottomInset: bottomInset) {
        self.fixedInset = true
        self.scrollToBottom(false)
      }
      self.paintSafeAreaBottomInset(with: .grey200)
    } else if self.presenter?.isProfileFocus != true {
      self.adjustTableViewInset()
    }
    self.tableView.layoutIfNeeded()
  }
  
  @discardableResult
    private func adjustTableViewInset(bottomInset: CGFloat = 0.f) -> Bool {
      let chatViewHeight = self.tableView.frame.height
      if self.tableView.contentSize.height <= chatViewHeight {
        guard self.tableView.contentSize.height > 40 else { return false }

        var currInset = self.tableView.contentInset
        let newInset = chatViewHeight - self.tableView.contentSize.height
        currInset.top = newInset < bottomInset ? bottomInset: newInset
        currInset.bottom = self.tableViewOriginBottomInset

        self.tableView.contentInset = currInset
        return true
      } else {
        guard !self.fixedInset else { return false }

        self.tableView.contentInset = UIEdgeInsets(
          top: bottomInset,
          left: 0,
          bottom: self.tableViewOriginBottomInset,
          right: 0)
        return false
      }
  }
  
  private func showNewMessageBannerIfNeeded(current: [CHMessage], updated: [CHMessage]) {
    guard
      let currentLastMessage = current.first,
      let newLastMessage = updated.first,
      currentLastMessage != newLastMessage,
      !newLastMessage.isMine() else { return }
    
    let offset = self.tableView.contentOffset.y
    if let hasNew = self.presenter?.hasNewMessage(current: current, updated: updated),
      hasNew && offset > self.viewBounds.height * 0.5 {
      self.newMessageView.configure(message: newLastMessage)
      self.newMessageView.show(animated: true)
    }
  }
  
  private func scrollToBottom(_ animated: Bool) {
    guard self.tableView.numberOfRows(inSection: Sections.messages) > 0 else {
      return
    }
    
    dispatch {
      self.tableView.scrollToRow(
        at: IndexPath(row: 0, section: Sections.messages),
        at: .bottom,
        animated: animated
      )
    }
  }
  
  private func hideMessageView() {
    self.setMessageView(hidden: true, animated: false)
    self.dismissKeyboard(true)
  }
  
  private func showMessageView() {
    self.setMessageView(hidden: false, animated: false)
  }
}

extension UserChatView {
  func display(userChat: CHUserChat?, channel: CHChannel) {
    self.channel = channel
    self.userChat = userChat
    self.initNavigationViews(with: userChat)
    self.tableView.isHidden = false
    self.fixedInset = false
    self.updateInputField(userChat: userChat)
    self.adjustTableViewInsetIfneeded(userChat: userChat)
    self.hideLoader()
  }
  
  func display(messages: [CHMessage], userChat: CHUserChat?, channel: CHChannel) {
    guard messages.count > 0 else { return }
    self.channel = channel
    self.userChat = userChat
    let hasNewMessage = self.presenter?.hasNewMessage(
      current: self.messages,
      updated: messages) ?? false
    self.showNewMessageBannerIfNeeded(current: self.messages, updated: messages)
    self.messages = messages
    self.updateInputField(userChat: userChat)
    
    if hasNewMessage{
      self.tableView.reloadData()
    }
    
    // layoutIfNeeded need because of view flickering
    self.tableView.layoutIfNeeded()
    self.adjustTableViewInsetIfneeded(userChat: userChat)
    
    self.newChatButton.isEnabled = self.channel.allowNewChat
  }
  
  func updateNavigation(userChat: CHUserChat?) {
    self.initNavigationViews(with: userChat)
  }
  
  func updateInputBar(state: MessageViewState) {
    self.messageView.mode = state
  }
  
  func setPreloadtext(with text: String) {
    guard text != "" else { return }
    self.messageView.text = text
  }
  
  func display(typers: [CHEntity]) {
    self.typers = typers
    self.tableView.reloadSections([Sections.typer], with: .none)
  }
  
  func display(loadingFile: ChatFileQueueItem, waitingCount: Int) {
    self.isLoadingFile = true
    self.loadingFile = loadingFile
    self.waitingFileCount = waitingCount
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()
  }
  
  func display(errorFiles: [ChatFileQueueItem]) {
    self.errorFiles = errorFiles
    self.tableView.reloadData()
  }
  
  func hideLodingFile() {
    self.isLoadingFile = false
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()
  }
  
  func display(error: String?, visible: Bool) {
    guard visible == true, let errorMessage = error else {
      CHNotification.shared.dismiss()
      return
    }
    CHNotification.shared.display(
      message: errorMessage,
      config: CHNotificationConfiguration.warningNormalConfig
    )
  }
  
  func dismissKeyboard(_ animated: Bool) {
    self.messageView.resignResponder(animated: animated)
  }
  
  @objc internal func keyboardChange(notification: Notification) {
    self.adjustTableViewInsetIfneeded(userChat: self.userChat)
  }
}

// MARK: - UIScrollViewDelegate
extension UserChatView {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    let triggerPoint: CGFloat = scrollView.contentSize.height - self.tableView.bounds.height
    if yOffset >= triggerPoint && triggerPoint > 0 {
      self.presenter?.fetchMessages()
    }

    if yOffset < 100 &&
      !self.newMessageView.isHidden {
      self.newMessageView.hide(animated: false)
    }
  }
}
