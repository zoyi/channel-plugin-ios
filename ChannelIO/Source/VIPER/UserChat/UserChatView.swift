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
  private struct Constants {
    static let newMessageViewHeight = 48.f
    static let newMessageViewBottom = -6.f
    static let newChatButtonBottom = 40.f
    static let typerCellHeight = 40.f
    static let fileStatusCellHeight = 60.f
    static let MediaMessageCellLeading = 40.f
    static let MediaMessageCellTrailing = 75.f
  }
  
  private struct Sections {
    static let loadingFile = 0
    static let errorFiles = 1
    static let typer = 2
    static let messages = 3
  }
  
  private struct Metrics {
    static let newButtonHeight = 46
  }
  
  private var viewBounds: CGRect = .zero
  
  var presenter: UserChatPresenterProtocol?
  
  private let tableView = UITableView().then {
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
    $0.register(cellType: ProfileCell.self)
    $0.register(cellType: ActionMessageCell.self)
    $0.register(cellType: ActionWebMessageCell.self)
    $0.register(cellType: ActionMediaMessageCell.self)
    $0.register(cellType: ActionFileMessageCell.self)
    $0.register(cellType: ButtonsMessageCell.self)
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
  
  private var typers = [CHEntity]()
  
  private var newChatBottomConstraint: Constraint? = nil
  private var fixedInset: Bool = false
  private var shouldShowInputBar: Bool = false
  
  private var channel: CHChannel = mainStore.state.channel
  private var messages = [CHMessage]()
  var videoRecords = [CHFile: Double]()
  
  private var isLoadingFile = false
  private var errorFiles: [ChatFileQueueItem] = []
  private var loadingFile: ChatFileQueueItem?
  private var initialFileCount: Int = 0

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.viewBounds = self.view.bounds
    self.edgesForExtendedLayout = UIRectEdge.bottom
    self.view.backgroundColor = UIColor.white
    self.view.addSubview(self.tableView)
    
    self.initViews()
    self.initTableView()
    self.initMessageView()
    self.setup(scrollView: self.tableView)
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.adjustTableViewInset()
  }
  
  override func textDidChange(text: String) {
    super.textDidChange(text: text)
    self.presenter?.sendTyping(isStop: text == "")
    
    if text == "" && !self.channel.working && !self.channel.allowNewChat {
      self.messageView.hide(animated: false)
      self.adjustTableViewInset(bottomInset: 60.f)
    }
  }
  
  private func initNavigationViews(with userChat: CHUserChat?) {
    self.setNavItems(
      currentUserChat: userChat,
      user: mainStore.state.user
    )
    self.initNavigationTitle(with: userChat)
    
    //NOTE: iOS 10 >= doesn't properly call navigationBar frame change rx method
    //hance it doesn't apply proper navigation tint when it comes from lounge (where navigation is hidden)
    //Remove this when iOS 10 is not supported
    if let nav = self.navigationController as? MainNavigationController {
      nav.newState(state: mainStore.state.plugin)
    }
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
    self.messageView.hide(animated: false)
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
    self.messageView.setButton(inset: 13, position: .right)
    self.messageView.setButton(
      icon: clipImage,
      for: .normal,
      position: .left,
      size: CGSize(width: 30, height: 40))
    self.messageView.setButton(
      icon: sendImage,
      for: .normal,
      position: .right,
      size: CGSize(width: 30, height: 40))
    self.messageView.setButton(
      icon: sendImage,
      for: .disabled,
      position: .right,
      size: CGSize(width: 30, height: 40))
    self.messageView.addButton(
      target: self,
      action: #selector(self.didPressAssetButton),
      position: .left)
    self.messageView.addButton(
      target: self,
      action: #selector(self.didPressSendButton),
      position: .right)
    self.messageView.rightButton.isEnabled = false
    self.messageView.textViewInset = UIEdgeInsets(top: 12, left: 5, bottom: 12, right: 8)
    self.messageView.font = UIFont.systemFont(ofSize: 14)
    self.messageView.maxHeight = 184
    self.messageView.rightButton.tintColor = self.messageView.shouldEnabledSend ?
      .cobalt400: .sendDisable
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
    
    self.newChatButton.snp.makeConstraints { [weak self] (make) in
      self?.newChatBottomConstraint = make.bottom.equalToSuperview().inset(
        Constants.newChatButtonBottom).constraint
      make.centerX.equalToSuperview()
      make.height.equalTo(Metrics.newButtonHeight)
    }
  }

  private func initTableView() {
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
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
    self.chatBlockView.snp.makeConstraints { [weak self] (make) in
      guard let self = self else { return }
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      } else {
        make.bottom.equalToSuperview()
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
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
      self.messageView.show(animated: false)
    }
  }
  
  @objc private func didPressSendButton() {
    guard self.messageView.text != "" else { return }
    self.presenter?.didClickOnSendButton(text: self.messageView.text)
    self.messageView.text = ""
  }
  
  @objc private func didPressAssetButton() {
    self.presenter?.didClickOnClipButton(from: self)
  }
  
  private func updateInputField(userChat: CHUserChat?) {
    self.shouldShowInputBar = false
    self.chatBlockView.isHidden = true
    
    self.paintSafeAreaBottomInset(with: nil)
    
    if userChat?.isRemoved == true {
      _ = self.navigationController?.popViewController(animated: true)
    } else if userChat?.isClosed == true {
      self.messageView.hide(animated: false)
      if !self.adjustTableViewInset(bottomInset: 60.f) {
        self.fixedInset = true
        self.scrollToBottom(false)
      }
      self.newChatButton.isHidden = false
    } else if !self.channel.allowNewChat && self.messageView.text == "" {
      if !self.adjustTableViewInset(bottomInset: self.chatBlockView.viewHeight()) {
        self.fixedInset = true
        self.scrollToBottom(false)
      }
      self.chatBlockView.isHidden = false
      self.paintSafeAreaBottomInset(with: .grey200)
      self.messageView.hide(animated: false)
    } else if userChat?.isSupporting == true ||
      userChat?.isSolved == true ||
      (mainStore.state.messagesState.supportBotEntry != nil && userChat == nil) {
      self.messageView.hide(animated: false)
    } else if self.presenter?.isProfileFocus != true {
      self.fixedInset = false
      self.adjustTableViewInset(bottomInset: 0.f)
      self.placeHolder != nil ?
        self.shouldShowInputBar = true : self.messageView.show(animated: false)
    }
  }
  
  @discardableResult
  private func adjustTableViewInset(bottomInset: CGFloat = 0.f) -> Bool {
    let chatViewHeight = self.tableView.frame.height
    if self.tableView.contentSize.height <= chatViewHeight {
      guard self.tableView.contentSize.height > 40 else { return false }
      var currInset = self.tableView.contentInset
      let newInset = chatViewHeight - self.tableView.contentSize.height
      currInset.top = newInset < bottomInset ? bottomInset : newInset
      
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
    self.tableView.scrollToRow(
      at: IndexPath(row: 0, section: Sections.messages),
      at: .bottom,
      animated: animated
    )
  }
}

extension UserChatView {
  func display(userChat: CHUserChat?, channel: CHChannel) {
    self.channel = channel
    self.initNavigationViews(with: userChat)
    self.tableView.isHidden = false
    self.fixedInset = false
    self.updateInputField(userChat: userChat)
    self.hideLoader()
  }
  
  func display(messages: [CHMessage], userChat: CHUserChat?, channel: CHChannel) {
    self.channel = channel
    let hasNewMessage = self.presenter?.hasNewMessage(
      current: self.messages,
      updated: messages) ?? false
    
    self.showNewMessageBannerIfNeeded(current: self.messages, updated: messages)
    self.messages = messages
    self.updateInputField(userChat: userChat)
    
    if hasNewMessage {
      self.tableView.reloadData()
      self.tableView.layoutIfNeeded()
    }
    
    self.adjustTableViewInset()
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
    self.tableView.reloadData()
  }
  
  func display(loadingFile: ChatFileQueueItem, count: Int) {
    self.isLoadingFile = true
    self.loadingFile = loadingFile
    self.initialFileCount = count
    self.tableView.reloadData()
  }
  
  func display(errorFiles: [ChatFileQueueItem]) {
    self.errorFiles = errorFiles
    self.tableView.reloadData()
  }
  
  func hideLodingFile() {
    self.isLoadingFile = false
    self.tableView.reloadData()
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
  
  func reloadTableView() {
    self.messageView.becomeResponder()
    self.tableView.reloadData()
    self.tableView.layoutIfNeeded()
  }
  
  func dismissKeyboard(_ animated: Bool) {
    self.messageView.resignResponder(animated: animated)
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

// MARK: - UITableView
extension UserChatView : UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case Sections.loadingFile:
      return self.isLoadingFile ? 1 : 0
    case Sections.errorFiles:
      return self.errorFiles.count
    case Sections.typer:
      return 1
    case Sections.messages:
      return self.messages.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case Sections.loadingFile:
      return Constants.fileStatusCellHeight
    case Sections.errorFiles:
      return Constants.fileStatusCellHeight
    case Sections.typer:
      return Constants.typerCellHeight
    case Sections.messages:
      let message = self.messages[indexPath.row]
      let previousMessage: CHMessage? =
        indexPath.row == self.messages.count - 1 ?
          self.messages[indexPath.row] :
          self.messages[indexPath.row + 1]
      let viewModel = MessageCellModel(
        message: message,
        previous: previousMessage,
        indexPath: indexPath
      )
      switch message.messageType {
      case .DateDivider:
        return DateCell.cellHeight()
      case .NewAlertMessage:
        return NewMessageDividerCell.cellHeight()
      case .Log:
        return LogCell.cellHeight(fit: tableView.frame.width, viewModel: viewModel)
      case .Media:
        return MediaMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      case .WebPage:
        return WebPageMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      case .Profile:
        return ProfileCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      case .Action:
        return ActionMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      case .Buttons:
        return ButtonsMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
      default:
        let calSize = MessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
        return calSize
      }
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case Sections.loadingFile:
      let cell = self.cellForLoading(tableView, cellForRowAt: indexPath)
      cell.transform = tableView.transform
      return cell
    case Sections.errorFiles:
      let cell = self.cellForErrorFiles(tableView, cellForRowAt: indexPath)
      cell.transform = tableView.transform
      return cell
    case Sections.typer:
      let cell = self.cellForTyping(tableView, cellForRowAt: indexPath)
      cell.transform = tableView.transform
      return cell
    case Sections.messages:
      let cell = self.cellForMessage(tableView, cellForRowAt: indexPath)
      cell.transform = tableView.transform
      return cell
    default:
      return UITableViewCell()
    }
  }

  private func cellForTyping(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: TypingIndicatorCell = tableView.dequeueReusableCell(for: indexPath)
    cell.configure(typingUsers: self.typers)
    cell.transform = tableView.transform
    return cell
  }
  
  private func cellForLoading(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: FileStatusCell = tableView.dequeueReusableCell(for: indexPath)
    if let loadingFile = self.loadingFile {
      cell.configure(item: loadingFile, count: self.initialFileCount)
    }
    cell.signalForRemove()
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        guard let item = self?.loadingFile else { return }
        self?.presenter?.didClickOnRemoveFile(with: item)
      }.disposed(by: self.disposeBag)
    cell.transform = tableView.transform
    return cell
  }
  
  private func cellForErrorFiles(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: FileStatusCell = tableView.dequeueReusableCell(for: indexPath)
    cell.configure(item: self.errorFiles[indexPath.row], count: 0)
    cell.signalForRemove()
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        guard let item = self?.errorFiles[indexPath.row] else { return }
        self?.presenter?.didClickOnRemoveFile(with: item)
      }.disposed(by: self.disposeBag)
    cell.signalForRetry()
      .observeOn(MainScheduler.instance)
      .subscribe { [weak self] _ in
        guard let item = self?.errorFiles[indexPath.row] else { return }
        self?.presenter?.didClickOnRetryFile(with: item)
      }.disposed(by: self.disposeBag)
    cell.transform = tableView.transform
    
    return cell
  }

  private func cellForMessage
    (_ tableView: UITableView,
     cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let message = self.messages[indexPath.row]
    let previousMessage: CHMessage? =
      indexPath.row == self.messages.count - 1 ?
        self.messages[indexPath.row] :
        self.messages[indexPath.row + 1]
    let viewModel = MessageCellModel(
      message: message,
      previous: previousMessage,
      indexPath: indexPath
    )
    
    if viewModel.shouldDisplayForm {
      switch viewModel.clipType {
      case .Image:
        let cell: ActionMediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.presenter)
        return cell
      case .Webpage:
        let cell: ActionWebMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.presenter)
        cell.webView.signalForClick()
          .observeOn(MainScheduler.instance)
          .subscribe{ [weak self] _ in
            self?.presenter?.didClickOnWeb(with: message.webPage?.url, from: self)
          }.disposed(by: self.disposeBag)
        return cell
      case .File:
        let cell: ActionFileMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.presenter)
        return cell
      default:
        let cell: ActionMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.presenter)
        return cell
      }
    }

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
    case .Profile :
      let cell: ProfileCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      return cell
    case .UserMessage:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      return cell
    case .Buttons:
      let cell: ButtonsMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      return cell
    case .WebPage:
      let cell: WebPageMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      cell.webView.signalForClick()
        .observeOn(MainScheduler.instance)
        .subscribe{ [weak self] _ in
          self?.presenter?.didClickOnWeb(with: message.webPage?.url, from: self)
        }.disposed(by: self.disposeBag)
      return cell
    case .Media:
      let cell: MediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      cell.setDataSource(self, at: indexPath.row)
      return cell
    default: //remote
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      return cell
    }
  }
}

extension UserChatView: UICollectionViewDelegate,
                       UICollectionViewDelegateFlowLayout,
                       UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
    return self.messages[collectionView.tag].files.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {
    let files = self.messages[collectionView.tag].sortedFiles
    let file = files[indexPath.row]
    let contentWidth = self.tableView.frame.width
      - Constants.MediaMessageCellLeading
      - Constants.MediaMessageCellTrailing
    if file.type == .video {
      return file.thumbSize
    } else if file.type == .image {
      let side = (contentWidth - 8) / 2
      return files.filter { $0.type == .image }.count > 1 ?
        CGSize(width: side, height: side ) : file.thumbSize
    } else {
      return CGSize(
        width: contentWidth,
        height: 70
      )
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    didEndDisplaying cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {
    if let cell = cell as? MediaCollectionViewCell {
      cell.videoView.pause()
      cell.videoView.didHide(from: self)
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {
    if let cell = cell as? MediaCollectionViewCell {
      cell.videoView.willDisplay(in: self)
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let files = self.messages[collectionView.tag].sortedFiles
    let file = files[indexPath.row]
    if file.type == .video || file.type == .image {
      let cell: MediaCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.rxForClick().subscribe(onNext: { [weak self] _ in
        self?.presenter?.didClickOnFile(
          with: file,
          on: cell.imageView,
          path: indexPath,
          from: self
        )
      }).disposed(by: self.disposeBag)
      cell.videoView.signalForPlay()
        .subscribe(onNext: { [weak self] play, seconds in
          if !play {
            self?.videoRecords[file] = seconds
          }
        }).disposed(by: self.disposeBag)
      cell.configure(with: FileCellModel(file, seconds: self.videoRecords[file]))
      return cell
    } else {
      let cell: FileCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
      cell.rxForClick().subscribe(onNext: { [weak self] _ in
        self?.presenter?.didClickOnFile(
          with: file,
          on: nil,
          path: indexPath,
          from: self
        )
      }).disposed(by: self.disposeBag)
      cell.configure(with: file)
      return cell
    }
  }
}
