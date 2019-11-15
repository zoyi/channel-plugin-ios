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
import CHSlackTextViewController
import Alamofire

class UserChatView: CHMessageViewController, UserChatViewProtocol {
  struct Constant {
    static let messagePerRequest = 30
    static let messageCellMaxWidth = UIScreen.main.bounds.width
  }

  let tableView = UITableView()
  
  var presenter: UserChatPresenterProtocol? = nil

  // MARK: Properties
  var channel: CHChannel = mainStore.state.channel
  var userChatId: String?
  var userChat: CHUserChat?

  var preloadText: String = ""
  //var isFetching = false
  //var isRequstingReadAll = false

  var photoUrls = [String]()

  var messages = [CHMessage]()

  var disposeBag = DisposeBag()
  //var photoBrowser : MWPhotoBrowser? = nil
  //var chatManager : ChatManager!

  var newMessageView = NewMessageBannerView().then {
    $0.isHidden = true
  }

  var typingCell: TypingIndicatorCell!

  var titleView : ChatNavigationTitleView? = nil

  var newChatSubject = PublishSubject<Any?>()
  var profileSubject = PublishSubject<Any?>()

  deinit {
    mainStore.dispatch(RemoveMessages(payload: self.userChatId))
  }

  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.presenter?.viewDidLoad()
    
    self.edgesForExtendedLayout = UIRectEdge.bottom
    self.view.backgroundColor = UIColor.white

    self.initSLKTextView()
    self.initTypingCell()
    self.initTableView()
    self.initInputViews()
    self.initViews()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.presenter?.prepareDataSource()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.presenter?.cleanDataSource()
  }

  // MARK: - Helper methods
  fileprivate func initSLKTextView() {
    //self.leftButton.setImage(CHAssets.getImage(named: "clip"), for: .normal)
  }

  func initInputViews() {
    self.messageView.setPlaceholder(mode: .normal, text: "")
    self.messageView.setPlaceholder(mode: .highlight, text: "")
    self.messageView.setPlaceholder(mode: .disabled, text: "")

    self.messageView.setButton(inset: 10, position: .right)
    self.messageView.setButton(icon: UIImage(named: "send"), for: .normal, position: .right)
    self.messageView.addButton(target: self, action: #selector(didPressRightButton), position: .right)
    self.messageView.rightButtonTint = UIColor.black40
    self.messageView.rightButton.isEnabled = true
    self.messageView.emptyTextDisabledRightButton = false
    self.messageView.textViewInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 8)
    self.messageView.font = UIFont.systemFont(ofSize: 15)
    self.messageView.maxHeight = 184
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

  func initNavigationViews(with info: UserChatInfo, user: CHUser) {
    self.setNavItems(
      currentUserChat: info.userChat,
      user: user,
      textColor: info.textColor
    )

    self.initNavigationTitle(with: info.userChat, channel: info.channel, plugin: info.plugin)
  }
  
  func initNavigationTitle(with userChat: CHUserChat?, channel: CHChannel, plugin: CHPlugin) {
    let titleView = ChatNavigationTitleView()
    titleView.configure(channel: channel, plugin: plugin)

    titleView.translatesAutoresizingMaskIntoConstraints = false
    titleView.layoutIfNeeded()
    titleView.sizeToFit()
    titleView.translatesAutoresizingMaskIntoConstraints = true

    self.navigationItem.titleView = titleView
    self.titleView = titleView
  }

  fileprivate func initViews() {
    self.view.addSubview(self.newMessageView)
    self.newMessageView.snp.makeConstraints { make in
      make.height.equalTo(48)
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.messageView.snp.top).offset(-6)
    }
    
    self.newMessageView.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
        self?.newMessageView.hide(animated: true)
        self?.scrollToBottom(false)
      }).disposed(by: self.disposeBag)
  }

  fileprivate func setNavItems(currentUserChat: CHUserChat?, user: CHUser, textColor: UIColor) {
    let tintColor = mainStore.state.plugin.textUIColor

    let alert = (user.alert ?? 0) - (currentUserChat?.session?.alert ?? 0)
    let alertCount = alert > 99 ? "99+" : (alert > 0 ? "\(alert)" : nil)
    
    self.navigationItem.leftBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "back")?.withRenderingMode(.alwaysTemplate),
      text: alertCount,
      textColor: tintColor,
      actionHandler: { [weak self] in
        mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
        _ = self?.navigationController?.popViewController(animated: true)
    })

    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "close"),
      tintColor: tintColor,
      style: .plain,
      actionHandler: { [weak self] in
        mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
        ChannelIO.close(animated: true)
      }
    )
  }
  
  @objc func didPressRightButton() {
    //send message
  }
}

//protocol
extension UserChatView {
  func display(messages: [CHMessage]) {
    let hasNewMessage = false // self.presenter?.hasNewMessage(current: current, updated: updated)
    self.showNewMessageBannerIfNeeded(current: self.messages, updated: messages, hasNewMessage: hasNewMessage)
    self.messages = messages
    self.tableView.reloadData()
  }
  
  func display(typers: [CHEntity]) {
    let indexPath = IndexPath(row: 0, section: self.channel.canUseSDK ? 0 : 1)
    if self.tableView.indexPathsForVisibleRows?.contains(indexPath) == true, let typingCell = self.typingCell {
      typingCell.configure(typingUsers: typers)
    }
  }
  
  func display(error: Error?, visible: Bool) {

  }
  
  func displayNewBanner() {
    
  }
  
  func updateChatInfo(info: UserChatInfo) {
    self.initNavigationViews(with: info, user: mainStore.state.user)
    self.updateInputField(userChat: self.userChat, updatedUserChat: info.userChat)
    self.userChat = info.userChat
  }
  
  func updateInputField(userChat: CHUserChat?, updatedUserChat: CHUserChat?) {
    
  }
}

extension UserChatView {
  //presenter
  func showNewMessageBannerIfNeeded(current: [CHMessage], updated: [CHMessage], hasNewMessage: Bool) {
    guard let lastMessage = updated.first, !lastMessage.isMine() else {
      return
    }

    let offset = self.tableView.contentOffset.y
    if hasNewMessage && offset > UIScreen.main.bounds.height * 0.5 {
      self.newMessageView.configure(message: lastMessage)
      self.newMessageView.show(animated: true)
    }
  }

  //no need?
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
      at: .bottom,
      animated: animated
    )
  }
}


// MARK: - UIScrollViewDelegate

extension UserChatView {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //fetch messages
    let yOffset = scrollView.contentOffset.y
    let triggerPoint = yOffset + UIScreen.main.bounds.height * 1.5
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

extension UserChatView {
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
    let viewModel = MessageCellModel(message: message, previous: previousMessage)
    switch message.messageType {
    case .DateDivider:
      return DateCell.cellHeight()
    case .NewAlertMessage:
      return NewMessageDividerCell.cellHeight()
    case .Log:
      return LogCell.cellHeight(fit: tableView.frame.width, viewModel: viewModel)
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

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    if section == 0 && self.channel.blocked {
      let cell: WatermarkCell = tableView.dequeueReusableCell(for: indexPath)
      _ = cell.signalForClick().subscribe { _ in
        let channel = mainStore.state.channel
        let channelName = channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let urlString = CHUtils.getUrlForUTM(source: "plugin_watermark", content: channelName)

        if let url = URL(string: urlString) {
          url.openWithUniversal()
        }
      }
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
    if let typingCell = self.typingCell {
      typingCell.configure(typingUsers: [])
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
    case .UserMessage:
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      return cell
    case .WebPage:
      let cell: WebPageMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      cell.signalForClick().subscribe{ [weak self] _ in
        self?.presenter?.didClickOnWeb(with: message.webPage?.url, from: self)
      }.disposed(by: self.disposeBag)
      return cell
    case .Media:
      let cell: MediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      cell.signalForClick().subscribe { [weak self] _ in
        let urls = self?.messages.compactMap { $0.file?.fileUrl } ?? []
        self?.presenter?.didClickOnImage(with: message.file?.fileUrl, photoUrls: urls, from: self)
      }.disposed(by: self.disposeBag)
      return cell
    case .File:
      let cell: FileMessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      cell.signalForClick().subscribe { [weak self] _ in
        self?.presenter?.didClickOnFile(with: message, from: self)
      }.disposed(by: self.disposeBag)
      return cell
    default: //remote
      let cell: MessageCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(viewModel)
      return cell
    }
  }
}


// MARK: Clip handlers

extension UserChatView {
  func signalForProfile() -> Observable<Any?> {
    return self.profileSubject
  }

  func signalForNewChat() -> Observable<Any?> {
    return self.newChatSubject
  }
}
