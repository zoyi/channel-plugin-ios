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
    static let nudgeKeepButtonBottom = 40.f
  }
  
  private struct Metrics {
    static let newButtonHeight = 46
  }
  
  private var viewBounds: CGRect = .zero
  
  var presenter: UserChatPresenterProtocol?
  
  private let tableView = UITableView().then {
    $0.estimatedRowHeight = 0
    $0.clipsToBounds = true
    $0.separatorStyle = .none
    $0.allowsSelection = false
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.isHidden = true
    
    $0.register(cellType: MediaMessageCell.self)
    $0.register(cellType: FileMessageCell.self)
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
    $0.register(cellType: WatermarkCell.self)
  }
  private var placeHolder: UIView? = nil
  private var newMessageView = NewMessageBannerView().then {
    $0.isHidden = true
  }
  private var nudgeKeepButton = CHButtonFactory.keepNudge().then {
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
  
  private var typingCell: TypingIndicatorCell = TypingIndicatorCell().then {
    $0.configure(typingUsers: [])
  }
  private var titleView : ChatNavigationTitleView? = nil
  
  private var newChatBottomConstraint: Constraint? = nil
  private var fixedInset: Bool = false
  private var shouldShowInputBar: Bool = false
  
  private var channel: CHChannel = mainStore.state.channel
  private var messages = [CHMessage]()
  private var photoUrls = [URL]()

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
      guest: mainStore.state.guest
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
    let sendActiveImage = CHAssets.getImage(
      named: "send")?.withRenderingMode(.alwaysTemplate)
    let sendDisabledImage = CHAssets.getImage(
      named: "sendDisabled")?.withRenderingMode(.alwaysTemplate)
    let clipImage = CHAssets.getImage(named: "clip")
    self.messageView.setButton(inset: 10, position: .left)
    self.messageView.setButton(inset: 13, position: .right)
    self.messageView.setButton(
      icon: clipImage,
      for: .normal,
      position: .left,
      size: CGSize(width: 30, height: 40))
    self.messageView.setButton(
      icon: sendActiveImage,
      for: .normal,
      position: .right,
      size: CGSize(width: 30, height: 40))
    self.messageView.setButton(
      icon: sendDisabledImage,
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
    self.messageView.rightButton.isEnabled = true
    self.messageView.textViewInset = UIEdgeInsets(top: 12, left: 5, bottom: 12, right: 8)
    self.messageView.font = UIFont.systemFont(ofSize: 14)
    self.messageView.maxHeight = 184
    self.messageView.rightButton.tintColor = self.messageView.text == "" ?
      .sendDisable : .cobalt400
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
    
    self.view.addSubview(self.nudgeKeepButton)
    self.nudgeKeepButton.signalForClick()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        self?.presenter?.didClickOnNudgeKeepAction()
      }).disposed(by: self.disposeBag)
    
    self.nudgeKeepButton.snp.makeConstraints { [weak self] (make) in
      self?.newChatBottomConstraint = make.bottom.equalToSuperview().inset(
        Constants.nudgeKeepButtonBottom).constraint
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
        self?.messageView.hide(animated: false)
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

  private func setNavItems(currentUserChat: CHUserChat?, guest: CHGuest) {
    let tintColor = mainStore.state.plugin.textUIColor
    
    let alert = (guest.alert ?? 0) - (currentUserChat?.session?.alert ?? 0)
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
    self.presenter?.didClickOnAssetButton(from: self)
  }
  
  private func updateInputField(userChat: CHUserChat?) {
    self.shouldShowInputBar = false
    self.nudgeKeepButton.isHidden = true
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
    } else if userChat?.fromNudge == true {
      self.nudgeKeepButton.isHidden = false
      self.adjustTableViewInset(bottomInset: 60.f)
      self.messageView.hide(animated: false)
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
      at: IndexPath(row:0, section:0),
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
      // Photo - is this scalable? or doesn't need to care at this moment?
      self.photoUrls = messages.reversed()
        .filter { $0.file?.isPreviewable == true }
        .compactMap{ $0.file?.fileUrl }
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
  
  func display(typers: [CHEntity], channel: CHChannel) {
    let indexPath = IndexPath(row: 0, section: self.channel.canUseSDK ? 0 : 1)
    if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
      self.typingCell.configure(typingUsers: typers)
    }
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
}

// MARK: - UIScrollViewDelegate
extension UserChatView {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    let triggerPoint = yOffset + self.viewBounds.height * 1.5
    if triggerPoint > scrollView.contentSize.height {
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
    return self.channel.canUseSDK ? 2 : 3
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return self.channel.canUseSDK ? self.messages.count : 1
    } else if section == 2 {
      return self.channel.canUseSDK ? 0 : self.messages.count
    }
    return 0
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    }

    if indexPath.section == 1 && !self.channel.canUseSDK {
      return 40
    }

    let message = self.messages[indexPath.row]
    let previousMessage: CHMessage? =
      indexPath.row == self.messages.count - 1 ?
        self.messages[indexPath.row] :
        self.messages[indexPath.row + 1]
    let viewModel = MessageCellModel(message: message, previous: previousMessage, indexPath: indexPath)
    switch message.messageType {
    case .DateDivider:
      return DateCell.cellHeight()
    case .NewAlertMessage:
      return NewMessageDividerCell.cellHeight()
    case .Log:
      return LogCell.cellHeight(fit: tableView.frame.width, viewModel: viewModel)
   case .Media:
    return MediaMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
    case .File:
      return FileMessageCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
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
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    if section == 0 && self.channel.blocked {
      let cell: WatermarkCell = tableView.dequeueReusableCell(for: indexPath)
      cell.signalForClick()
        .observeOn(MainScheduler.instance)
        .subscribe { [weak self] (_) in
          self?.presenter?.didClickOnWaterMark()
      }.disposed(by: self.disposeBag)
      cell.transform = tableView.transform
      return cell
    } else if section == 0 || (section == 1 && !self.channel.canUseSDK) {
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
    self.typingCell.configure(typingUsers: [])
    self.typingCell.transform = tableView.transform
    return typingCell
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
      indexPath: indexPath
    )
    
    if viewModel.shouldDisplayForm {
      switch viewModel.clipType {
      case .Image:
        let cell: ActionMediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.presenter)
        cell.mediaView.signalForClick()
          .observeOn(MainScheduler.instance)
          .subscribe { [weak self] _ in
            self?.presenter?.didClickOnImage(
              with: message.file?.fileUrl,
              photoUrls: self?.photoUrls ?? [],
              imageView: cell.mediaView.imageView,
              from: self)
          }.disposed(by: self.disposeBag)
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
        cell.fileView.signalForClick()
          .observeOn(MainScheduler.instance)
          .subscribe { [weak self] _ in
            self?.presenter?.didClickOnFile(with: message, from: self)
          }.disposed(by: self.disposeBag)
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
      cell.mediaView.signalForClick()
        .observeOn(MainScheduler.instance)
        .subscribe { [weak self] _ in
          self?.presenter?.didClickOnImage(
            with: message.file?.fileUrl,
            photoUrls: self?.photoUrls ?? [],
            imageView: cell.mediaView.imageView,
            from: self)
        }.disposed(by: self.disposeBag)
      return cell
    case .File:
      let cell: FileMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      cell.fileView.signalForClick()
        .observeOn(MainScheduler.instance)
        .subscribe { [weak self] _ in
          self?.presenter?.didClickOnFile(with: message, from: self)
        }.disposed(by: self.disposeBag)
      return cell
    default: //remote
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel, presenter: self.presenter)
      return cell
    }
  }
}
