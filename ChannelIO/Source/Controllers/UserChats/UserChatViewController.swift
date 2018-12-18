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
import SVProgressHUD
import CHSlackTextViewController
import CHNavBar
import AVKit
import SnapKit
import Lightbox
import SDWebImage

final class UserChatViewController: BaseSLKTextViewController {

  // MARK: Constants
  struct Constant {
    static let messagePerRequest = 30
    static let messageCellMaxWidth = UIScreen.main.bounds.width
  }
  
  struct Metric {
    static let newButtonHeight = 46
  }
  
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

  var diffCalculator: SingleSectionTableViewDiffCalculator<CHMessage>?
  var messages = [CHMessage]() {
    didSet {
      self.diffCalculator?.rows = self.messages
    }
  }

  var disposeBag = DisposeBag()
  var currentLocale: CHLocaleString? = CHUtils.getLocale()
  var chatManager : ChatManager!
  
  var chatUpdateSubject = PublishSubject<Any?>()
  var navigationUpdateSubject = PublishSubject<(AppState, CHUserChat?)>()
  
  var errorToastView = ErrorToastView().then {
    $0.isHidden = true
  }
  
  var newMessageView = NewMessageBannerView().then {
    $0.isHidden = true
  }
  
  var nudgeKeepButton = CHButton.keepNudge()
  var newChatButton = CHButton.newChat()
  
  var isAnimating = false
  var newChatBottomConstraint: Constraint? = nil
  
  var typingCell: TypingIndicatorCell!
  var profileCell: ProfileCell!
  
  var profileIndexPath: IndexPath?
  
  var titleView : NavigationTitleView? = nil
  
  var newChatSubject = PublishSubject<Any?>()
  var profileSubject = PublishSubject<Any?>()
  
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
    self.initPhotoViewer()

    self.initUpdaters()
    
    if mainStore.state.messagesState.supportBotEntry != nil && self.userChatId == nil {
      self.setTextInputbarHidden(true, animated: false)
      mainStore.dispatchOnMain(InsertSupportBotEntry())
      self.readyToDisplay()
    } else if self.userChatId == nil {
      mainStore.dispatchOnMain(InsertWelcome())
      self.readyToDisplay()
    } else if self.userChatId?.hasPrefix(CHConstants.nudgeChat) == true {
      self.readyToDisplay()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }

  func initUpdaters() {
    self.navigationUpdateSubject
      .takeUntil(self.rx.deallocated)
      .debounce(1.0, scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (state, chat) in
        self?.updateNavigationIfNeeded(state: state, nextUserChat: chat)
      }).disposed(by: self.disposeBag)
    
    self.chatUpdateSubject
      .takeUntil(self.rx.deallocated)
      .debounce(0.7, scheduler: ConcurrentMainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        self?.fetchChatIfNeeded()
      }).disposed(by: self.disposeBag)
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
      if #available(iOS 11.0, *) {
        self?.newChatBottomConstraint = make.bottom.equalTo((self?.view.safeAreaLayoutGuide.snp.bottom)!).offset(-15).constraint
      } else {
        self?.newChatBottomConstraint = make.bottom.equalToSuperview().inset(15).constraint
      }
      make.centerX.equalToSuperview()
      make.height.equalTo(Metric.newButtonHeight)
    }
    
    self.view.addSubview(self.nudgeKeepButton)
    self.nudgeKeepButton.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        self?.chatManager.processNudgeKeepAction()
      }).disposed(by: self.disposeBag)
    
    self.nudgeKeepButton.snp.makeConstraints { [weak self] (make) in
      if #available(iOS 11.0, *) {
        self?.newChatBottomConstraint = make.bottom.equalTo((self?.view.safeAreaLayoutGuide.snp.bottom)!).offset(-15).constraint
      } else {
        self?.newChatBottomConstraint = make.bottom.equalToSuperview().inset(15).constraint
      }
      make.centerX.equalToSuperview()
      make.height.equalTo(Metric.newButtonHeight)
    }
  }
  
  // MARK: - Helper methods
  fileprivate func initSLKTextView() {
    self.leftButton.setImage(CHAssets.getImage(named: "add"), for: .normal)
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
    self.textInputbar.autoHideRightButton = false
    self.textInputbar.signalForClick()
      .subscribe { [weak self] (_) in
      if self?.textInputbar.barState == .disabled && self?.chatManager?.profileIsFocus == false {
        return
      }
      self?.titleView?.isExpanded = false
      self?.shyNavBarManager.contract(true)
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
    self.tableView.register(cellType: WatermarkCell.self)
    self.tableView.register(cellType: ProfileCell.self)
    self.tableView.register(cellType: FormMessageCell.self)
    self.tableView.register(cellType: FormWebMessageCell.self)
    self.tableView.register(cellType: FormMediaMessageCell.self)
    self.tableView.register(cellType: FormFileMessageCell.self)
    self.tableView.register(cellType: ButtonsMessageCell.self)
    
    self.tableView.estimatedRowHeight = 0
    self.tableView.clipsToBounds = true
    self.tableView.separatorStyle = .none
    self.tableView.allowsSelection = false
  }

  func initTypingCell() {
    let cell = TypingIndicatorCell()
    cell.configure(typingUsers: [])
    self.typingCell = cell
    
    let profileCell = ProfileCell()
    self.profileCell = profileCell
  }

  // MARK: - Helper methods

  fileprivate func initDwifft() {
    self.tableView.reloadData()
    self.diffCalculator = SingleSectionTableViewDiffCalculator<CHMessage>(
      tableView: self.tableView,
      initialRows: self.messages,
      sectionIndex: self.channel.notAllowToUseSDK ? 2 : 1
    )
    self.diffCalculator?.forceOffAnimationEnabled = true
    self.diffCalculator?.insertionAnimation = .none
    self.diffCalculator?.deletionAnimation = .none
  }

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
    self.initNavigationExtension(with: userChat ?? self.userChat)
  }
  
  func initNavigationTitle(with userChat: CHUserChat? = nil) {
    let titleView = NavigationTitleView()
    titleView.configure(
      channel: mainStore.state.channel,
      userChat: userChat,
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
    if let previousTitleView = self.titleView {
      titleView.isExpanded = previousTitleView.isExpanded
    }
    self.titleView = titleView
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  func initNavigationExtension(with userChat: CHUserChat? = nil) {
    let view: UIView!
    let userChat = userChat ?? self.userChat
    
    if userChat?.lastTalkedHost == nil {
      view = ChatStatusViewFactory.createDefaultExtensionView(
        fit: self.view.bounds.width,
        userChat: userChat,
        channel: mainStore.state.channel,
        plugin: mainStore.state.plugin,
        managers: mainStore.state.managersState.followingManagers)
    } else {
      view = ChatStatusViewFactory.createFollowedExtensionView(
        fit: self.view.bounds.width,
        userChat: userChat,
        channel: mainStore.state.channel,
        plugin: mainStore.state.plugin)
    }
    
    self.shyNavBarManager.scrollView = self.tableView
    self.shyNavBarManager.stickyNavigationBar = true
    self.shyNavBarManager.fadeBehavior = .subviews
    if let state = userChat?.state, state != .ready &&
      self.shyNavBarManager.extensionView == nil || !self.shyNavBarManager.isExpanded() {
      self.titleView?.isExpanded = false
      self.shyNavBarManager.hideExtension = true
    }
    
    self.shyNavBarManager.extensionView = view
    self.shyNavBarManager.triggerExtensionAtTop = true
    self.shyNavBarManager.delegate = self
    self.shyNavBarManager.isInverted = true
    self.shyNavBarManager.expansionResistance = 0
    
    view.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    //?
    if let expanded = self.titleView?.isExpanded, expanded {
      self.shyNavBarManager.expand(false)
    }
  }

  fileprivate func initViews() {
    self.errorToastView.topLayoutGuide = self.topLayoutGuide
    self.errorToastView.containerView = self.view
    self.view.addSubview(self.errorToastView)
    
    self.errorToastView.refreshImageView.signalForClick()
      .subscribe(onNext: { [weak self] _ in
        self?.chatManager?.reconnect()
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
  
  fileprivate func initPhotoViewer() {
    LightboxConfig.hideStatusBar = false
    LightboxConfig.loadImage = { imageView, URL, completion in
      SDWebImageManager.shared().loadImage(with: URL, options: .queryDataWhenInMemory, progress: { (m, max, url) in

      }, completed: { (image, data, error, cache, completed, url) in
        if let gif = UIImage.sd_animatedGIF(with: data), gif.isGIF() {
          imageView.image = gif
          completion?(gif)
        } else {
          imageView.image = image
          completion?(image)
        }
      })
    }
    LightboxConfig.CloseButton.text = CHAssets.localized("ch.button_close")
  }
  
  fileprivate func setNavItems(showSetting: Bool, currentUserChat: CHUserChat?, guest: CHGuest, textColor: UIColor) {
    let tintColor = mainStore.state.plugin.textUIColor
    
    if showSetting {
      self.navigationItem.leftBarButtonItem = NavigationItem(
        image: CHAssets.getImage(named: "settings"),
        tintColor: tintColor,
        style: .plain,
        actionHandler: { [weak self] in
          self?.profileSubject.onNext(nil)
        })
    } else {
      let alert = guest.alert - (currentUserChat?.session?.alert ?? 0)
      let alertCount = alert > 99 ? "99+" : (alert > 0 ? "\(alert)" : nil)

      if alert == 0 {
        self.navigationItem.leftBarButtonItem = NavigationItem(
          image: CHAssets.getImage(named: "back"),
          tintColor: tintColor,
          style: .plain,
          actionHandler: { [weak self] in
            self?.shyNavBarManager.disable = true
            mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
            _ = self?.navigationController?.popViewController(animated: true)
          })
      } else {
        self.navigationItem.leftBarButtonItem = NavigationItem(
          image: CHAssets.getImage(named: "back"),
          text: alertCount,
          fitToSize: true,
          alignment: .left,
          textColor: tintColor,
          actionHandler: { [weak self] in
            self?.shyNavBarManager.disable = true
            mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
            _ = self?.navigationController?.popViewController(animated: true)
          })
      }
    }

    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "exit"),
      tintColor: tintColor,
      style: .plain,
      actionHandler: { [weak self] in
        mainStore.dispatch(RemoveMessages(payload: self?.userChatId))
        ChannelIO.close(animated: true)
      })
    
    if #available(iOS 11, *){
      if let bar = self.navigationController?.navigationBar,
        bar.subviews[2].layoutMargins.left != 0 {
        bar.setNeedsLayout()
        bar.layoutIfNeeded()
      }
    }
  }
}

// MARK: - StoreSubscriber

extension UserChatViewController: StoreSubscriber {

  func newState(state: AppState) {
    self.userChatId = self.chatManager.chatId
    
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
    
    self.navigationUpdateSubject.onNext((state, userChat))
    self.updateViewsBasedOnState(userChat: self.userChat, nextUserChat: userChat)
    self.fixedOffsetIfNeeded(previousOffset: offset, hasNewMessage: hasNewMessage)
    self.showErrorIfNeeded(state: state)
    
    self.chatUpdateSubject.onNext(nil)
    
    if userChat?.appMessageId != self.userChat?.appMessageId {
      self.tableView.reloadData()
    }
    self.userChat = userChat
    self.channel = state.channel
    
    if let userChat = userChat, userChat.isSupporting() || userChat.isClosed() || userChat.isSolved() {
      self.setTextInputbarHidden(true, animated: false)
    }
  }
  
  func updateNavigationIfNeeded(state: AppState, nextUserChat: CHUserChat?) {
    if self.userChat?.hostId != nextUserChat?.hostId {
      self.initNavigationViews(with: nextUserChat)
    } else if self.channel.isDiff(from: state.channel) {
      self.initNavigationViews(with: nextUserChat)
    } else if self.currentLocale != state.settings?.appLocale {
      self.initNavigationViews(with: nextUserChat)
      self.currentLocale = state.settings?.appLocale
    } else {
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
  
  func updateViewsBasedOnState(userChat: CHUserChat?, nextUserChat: CHUserChat?) {
    let channel = mainStore.state.channel

    if nextUserChat?.isRemoved() == true {
      _ = self.navigationController?.popViewController(animated: true)
    }
    else if userChat?.isClosed() != true && nextUserChat?.isClosed() == true {
      self.setTextInputbarHidden(true, animated: false)
      self.tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: self.tableView.contentInset.bottom, right: 0)
      self.newChatButton.isHidden = self.tableView.contentOffset.y > 100
      self.scrollToBottom(false)
    }
    else if userChat?.isNudgeChat() == true {
      self.setTextInputbarHidden(true, animated: false)
      self.tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: self.tableView.contentInset.bottom, right: 0)
      self.nudgeKeepButton.isHidden = false
    }
    else if nextUserChat?.shouldHideInput() == true ||
      self.channel.allowNewChat == false ||
      (mainStore.state.messagesState.supportBotEntry != nil && nextUserChat == nil) {
      self.setTextInputbarHidden(true, animated: false)
    }
    else if !self.chatManager.profileIsFocus {
      self.nudgeKeepButton.isHidden = true
      self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.tableView.contentInset.bottom, right: 0)
      
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
        offset.y += WebPageMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
      } else if lastMessage.messageType == .Media {
        offset.y += MediaMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
      } else if lastMessage.messageType == .File {
        offset.y += FileMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
      } else if lastMessage.messageType == .Profile {
        offset.y += ProfileCell.cellHeight(fits: self.tableView.frame.width, viewModel: viewModel)
      } else if viewModel.shouldDisplayForm {
        offset.y += FormMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
      } else {
        offset.y += MessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
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
        self?.chatManager?.presentCameraPicker(from: self)
      })

    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.photo.album"), style: .default) { [weak self] _ in
        self?.chatManager?.presentPicker(type: .photo, max: 20, from: self)
      })

    alertView.addAction(
      UIAlertAction(title: CHAssets.localized("ch.chat.resend.cancel"), style: .cancel) { _ in

      })

    self.navigationController?.present(alertView, animated: true, completion: nil)
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
    
    self.shyNavBarManager.contract(true)
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
    guard scrollView.contentOffset.y < 100 && self.userChat?.isClosed() == true else { return }
    self.showNewChatButton()
  }

  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard scrollView.contentOffset.y < 100 && self.userChat?.isClosed() == true else { return }
    self.showNewChatButton()
  }
}

extension UserChatViewController {
  fileprivate func showNewChatButton() {
    guard !self.isAnimating else { return }
    self.isAnimating = true
    
    self.newChatButton.isHidden = false
    
    if #available(iOS 11.0, *) {
      self.newChatBottomConstraint?.update(offset: -15)
    } else {
      self.newChatBottomConstraint?.update(inset: 15)
    }
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
    
    let margin = -24 - Metric.newButtonHeight //button height
    if #available(iOS 11.0, *) {
      self.newChatBottomConstraint?.update(offset: -margin)
    } else {
      self.newChatBottomConstraint?.update(inset: margin)
    }
    
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
    return self.channel.notAllowToUseSDK ? 3 : 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return self.channel.notAllowToUseSDK ? 1 : self.messages.count
    } else if section == 2 {
      return self.channel.notAllowToUseSDK ? self.messages.count : 0
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return 40
    }
    
    if indexPath.section == 1 && self.channel.notAllowToUseSDK {
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
      return MediaMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    case .File:
      return FileMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    case .WebPage:
      return WebPageMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    case .Profile:
      return ProfileCell.cellHeight(fits: tableView.frame.width, viewModel: viewModel)
    case .Form:
      return FormMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    case .Buttons:
      return ButtonsMessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    default:
      return MessageCell.cellHeight(fits: Constant.messageCellMaxWidth, viewModel: viewModel)
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    if section == 0 && self.channel.notAllowToUseSDK {
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
    } else if section == 0 || (section == 1 && self.channel.notAllowToUseSDK) {
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
        let cell: FormMediaMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        cell.mediaView.signalForClick().subscribe { [weak self] _ in
          self?.didImageTapped(message: viewModel.message)
          }.disposed(by: self.disposeBag)
        return cell
      } else if viewModel.clipType == .Webpage {
        let cell: FormWebMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        cell.webView.signalForClick().subscribe{ [weak self] _ in
          self?.chatManager?.didClickOnWebPage(with: viewModel.message)
          }.disposed(by: self.disposeBag)
        return cell
      } else if viewModel.clipType == .File {
        let cell: FormFileMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel, presenter: self.chatManager)
        cell.fileView.signalForClick().subscribe { [weak self] _ in
          self?.chatManager?.didClickOnFile(with: viewModel.message)
          }.disposed(by: self.disposeBag)
        return cell
      } else {
        let cell: FormMessageCell = tableView.dequeueReusableCell(for: indexPath)
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
        self?.didImageTapped(message: message)
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
  
  func didImageTapped(message: CHMessage) {
    if let urlString = message.file?.imageRedirectUrl, let url = URL(string: urlString) {
      let shouldhandle = ChannelIO.delegate?.onClickRedirect?(url: url)
      if shouldhandle == nil || shouldhandle == false {
         url.openWithUniversal()
      }
    }
    else {
      let imgUrl = message.file?.url
      var startIndex = 0
      if let index = self.photoUrls.index(of: imgUrl ?? "") {
        startIndex = index
      }
      
      let images = self.photoUrls.map { (url) -> LightboxImage in
        return LightboxImage(imageURL: URL(string: url)!)
      }

      let controller = LightboxController(images:images, startIndex: startIndex)
      controller.dynamicBackground = true

      self.present(controller, animated: true, completion: nil)
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
      let indexPath = IndexPath(row: 0, section: self.channel.notAllowToUseSDK ? 1 : 0)
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
    if self.shyNavBarManager.isExpanded() {
      self.shyNavBarManager.contract(false)
    }
    self.chatManager?.didChatLoaded = false
    self.errorToastView.display(animated: true)
  }
  
  func hideError() {
    self.errorToastView.dismiss(animated: true)
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

