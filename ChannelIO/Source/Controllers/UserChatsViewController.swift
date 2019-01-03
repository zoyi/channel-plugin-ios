//
//  UserChatsController.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 1. 14..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import CHDwifft
import ReSwift
import RxSwift
import SnapKit
import SVProgressHUD
import MGSwipeTableCell

class UserChatsViewController: BaseViewController {

  // MARK: Properties
  var errorToastTopConstraint: Constraint?
  var plusBottomConstraint: Constraint?
  var tableViewBottomConstraint: Constraint?
  
  var scrollOffset: CGFloat = 0.0
  var nextSeq: Int64? = 0
  var diffCalculator: SingleSectionTableViewDiffCalculator<CHUserChat>?

  var userChats = [CHUserChat]() {
    didSet {
      self.diffCalculator?.rows = self.userChats
    }
  }
  var userChat: CHUserChat? = nil
  
  let disposeBag = DisposeBag()
  
  let tableView = UITableView().then {
    $0.clipsToBounds = false
    $0.register(cellType: UserChatCell.self)
    $0.separatorStyle = .singleLine
    $0.separatorColor = CHColors.snow
    $0.separatorInset.left = 64.f
  }

  let emptyView = UserChatsEmptyView().then {
    $0.isHidden = true
  }
  
  let watermarkView = WatermarkView().then {
    $0.alpha = 0
  }
  let errorToastView = ErrorToastView().then {
    $0.isHidden = true
  }
  let plusButton = NewChatView()
  
  var showCompleted = false
  var didLoad = false
  var showNewChat = false
  var shouldHideTable = false
  var isShowingChat = false
  var goToUserChatId: String? = nil
  
  struct Metric {
    static let statusBarHeight = 64.f
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.emptyView)
    self.view.addSubview(self.watermarkView)
    self.view.addSubview(self.plusButton)
    
    self.errorToastView.topLayoutGuide = self.topLayoutGuide
    self.errorToastView.containerView = self.view
    self.view.addSubview(self.errorToastView)
    
    WsService.shared.connect()
    
    self.initTableView()
    self.initActions()
    self.initNotifications()
    self.setDefaultNavItems()
    
    self.showCompleted = mainStore.state.userChatsState.showCompletedChats
    self.fetchUserChats(isInit: true, showIndicator: true)
  }

  func initTableView() {
    self.tableView.tableFooterView = UIView()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.allowsMultipleSelectionDuringEditing = true
    
    self.diffCalculator = SingleSectionTableViewDiffCalculator<CHUserChat>(
      tableView: self.tableView, initialRows: self.userChats
    )
    self.diffCalculator?.forceOffAnimationEnabled = true
    self.diffCalculator?.insertionAnimation = .none
    self.diffCalculator?.deletionAnimation = .none
  }
  
  func initNotifications() {
    NotificationCenter.default.rx
      .notification(UIApplication.didBecomeActiveNotification)
      .subscribe(onNext: { [weak self] (_) in
        if let controller = CHUtils.getTopController(), controller == self {
          self?.fetchUserChats(isInit: true, showIndicator: false, isReload: true)
        }
      }).disposed(by: self.disposeBag)
    
    WsService.shared.error()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        self?.errorToastView.display(animated: true)
      }).disposed(by: self.disposeBag)
    
    WsService.shared.ready()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (_) in
        self?.errorToastView.dismiss(animated: true)
      }).disposed(by: self.disposeBag)
  }
  
  func initActions() {
    self.errorToastView.refreshImageView.signalForClick().subscribe { [weak self] _ in
      mainStore.dispatch(DeleteUserChatsAll())
      
      self?.errorToastView.dismiss(animated: true)
      self?.nextSeq = nil
      self?.fetchUserChats(isInit: true, showIndicator: true)
      WsService.shared.connect()
      AppManager.touch().subscribe(onNext: { (guest) in
        mainStore.dispatch(UpdateGuest(payload: guest))
      }).disposed(by: (self?.disposeBag)!)
    }.disposed(by: self.disposeBag)
    
    self.plusButton.signalForClick().subscribe { [weak self] _ in
      self?.showUserChat()
    }.disposed(by: self.disposeBag)
    
    self.watermarkView.signalForClick().subscribe{ _ in
      let channel = mainStore.state.channel
      let channelName = channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
      let urlString = CHUtils.getUrlForUTM(source: "plugin_watermark", content: channelName)
      
      if let url = URL(string: urlString) {
        url.open()
      }
    }.disposed(by: self.disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
    //in order to reload if language has been changed
    self.tableView.reloadData()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    mainStore.unsubscribe(self)
  }

  override func setupConstraints() {
    super.setupConstraints()
    self.tableView.snp.makeConstraints { [weak self] make in
      if #available(iOS 11.0, *) {
        make.top.equalTo((self?.view.safeAreaLayoutGuide.snp.top)!)
      } else {
        make.top.equalToSuperview()
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      self?.tableViewBottomConstraint = make.bottom.equalTo((self?.watermarkView.snp.top)!).constraint
    }

    self.emptyView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    self.plusButton.snp.makeConstraints { [weak self] make in
      make.right.equalToSuperview().inset(24)
      self?.plusBottomConstraint = make.bottom.equalToSuperview().inset(24).constraint
    }
    
    self.watermarkView.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      if #available(iOS 11.0, *) {
        make.bottom.equalTo((self?.view.safeAreaLayoutGuide.snp.bottom)!)
      } else {
        make.bottom.equalToSuperview()
      }
      make.height.equalTo(40)
    }
  }
  
  // MARK: - Helper methods
  fileprivate func setDefaultNavItems() {
    let tintColor = mainStore.state.plugin.textUIColor
    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "exit"),
      tintColor: tintColor,
      style: .plain,
      actionHandler: {
        ChannelIO.close(animated: true)
      })
    
    self.navigationItem.leftBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "settings"),
      tintColor: tintColor,
      style: .plain,
      actionHandler: { [weak self] in
        self?.showProfileView()
      })
  }

  fileprivate func showPlusButton() {
    self.plusBottomConstraint?.update(inset: 24)
    UIView.animate(withDuration: 0.3) { 
      self.view.layoutIfNeeded()
    }
  }
  
  fileprivate func hidePlusButton() {
    let margin = -24 - self.plusButton.frame.size.height
    self.plusBottomConstraint?.update(inset: margin)
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func showUserChat(userChatId: String? = nil, text:String = "", animated: Bool = true) {
    guard !self.isShowingChat else { return }
    self.isShowingChat = true
    
    let controller = self.prepareUserChat(userChatId: userChatId, text: text)
    let channel = mainStore.state.channel
    
    //NOTE: Make sure to call onCompleted on observable method to avoid leak
    let pluginId = mainStore.state.plugin.id
    let pluginSignal = CHPlugin.get(with: pluginId)
    let followersSignal = CHManager.getRecentFollowers()
    let supportBot = channel.canUseSupportBot ?
      CHSupportBot.getBots(with: pluginId, fetch: userChatId == nil) :
      .just([])
    
    var pluginBot: CHBot? = nil
    
    Observable.zip(pluginSignal, followersSignal, supportBot)
      .observeOn(MainScheduler.instance)
      .flatMap({ (info, managers, supportBots) -> Observable<CHSupportBotEntryInfo> in
        mainStore.dispatch(UpdateFollowingManagers(payload: managers))
        mainStore.dispatch(GetPlugin(plugin: info.0, bot: info.1))
        
        pluginBot = info.1
        mainStore.dispatch(GetSupportBots(payload: supportBots))
        //target evaluate (supportBots) -> bot? 
        //evaluation happen here later
        
        if let supportBot = supportBots.first {
          return supportBot.getEntry()
        } else {
          return .just(CHSupportBotEntryInfo(step: nil, actions: []))
        }
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (entryInfo) in
        if entryInfo.step != nil {
          mainStore.dispatch(GetSupportBotEntry(bot: pluginBot, entry: entryInfo))
        }
        
        self?.navigationController?.pushViewController(controller, animated: animated)
        self?.showNewChat = false
        self?.isShowingChat = false
        self?.shouldHideTable = false
        dlog("got following managers")
      }, onError: { [weak self] (error) in
        dlog("error getting following managers: \(error.localizedDescription)")
        self?.showNewChat = false
        self?.isShowingChat = false
        self?.errorToastView.display(animated: true)
      }).disposed(by: self.disposeBag)
  }
  
  func prepareUserChat(userChatId: String? = nil, text: String = "") -> UserChatViewController {
    let controller = UserChatViewController()
    if let userChatId = userChatId {
      controller.userChatId = userChatId
    }
    
    self.showNewChat = true
    
    controller.preloadText = text
    controller.signalForNewChat().subscribe (onNext: { [weak self] text in
      let text = text as? String ?? ""
      self?.navigationController?.popViewController(animated: true, completion: {
        self?.showUserChat(text: text, animated: true)
      })
    }).disposed(by: self.disposeBag)
    
    controller.signalForProfile().subscribe { [weak self] _ in
      self?.showProfileView()
    }.disposed(by: self.disposeBag)
    
    return controller
  }
  
  func showProfileView() {
    let controller = ProfileViewController()
    let navigation = MainNavigationController(rootViewController: controller)
    //navigation.modalPresentationStyle = .overCurrentContext
    self.navigationController?.present(navigation, animated: true, completion: nil)
  }
}

// MARK: - StoreSubscriber

extension UserChatsViewController: StoreSubscriber {

  func newState(state: AppState) {
    self.userChats = userChatsSelector(
      state: state,
      showCompleted: self.showCompleted)

    self.nextSeq = state.userChatsState.nextSeq
    self.tableView.isHidden = (self.userChats.count == 0 || !self.didLoad) || self.shouldHideTable
    self.emptyView.isHidden = self.userChats.count != 0 || !self.didLoad || self.showNewChat
    self.plusButton.isHidden = self.tableView.isHidden && self.showNewChat
    
    self.plusButton.configure(
      bgColor: state.plugin.color,
      borderColor: state.plugin.borderColor,
      tintColor: state.plugin.textColor)
   
    // fetch data
    let showCompleted = state.userChatsState.showCompletedChats
    if self.showCompleted != showCompleted {
      self.showCompleted = showCompleted
      self.nextSeq = nil
      self.fetchUserChats(isInit: true, showIndicator: true, isReload: true)
    }
    
    self.showWatermarkIfNeeded()
  }
}

// MARK: UIScrollView Delegate

extension UserChatsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    if self.scrollOffset < yOffset && self.scrollOffset > 0 &&
      yOffset < scrollView.contentSize.height - scrollView.bounds.height {
      self.hidePlusButton()
    }
    
    self.scrollOffset = yOffset
    self.showWatermarkIfNeeded()
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    let triggerPoint = scrollView.contentSize.height -
      UIScreen.main.bounds.height * 2
    
    if yOffset >= triggerPoint && self.nextSeq != 0{
      self.fetchUserChats()
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    self.showPlusButton()
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.showPlusButton()
  }
}

// MARK: - UITableViewDataSource

extension UserChatsViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.userChats.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
    let userChat = self.userChats[indexPath.row]
    let viewModel = UserChatCellModel(userChat: userChat)
    cell.configure(viewModel)
    let button = MGSwipeButton(
      title: CHAssets.localized("ch.chat.delete"),
      backgroundColor: CHColors.warmPink,
      insets: UIEdgeInsets(top: 0, left: 10, bottom: 0 , right: 10)
    )
    
    button.buttonWidth = 70
    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    cell.rightButtons = [
      button
    ]
    cell.rightSwipeSettings.transition = .drag
    cell.tintColor = CHColors.warmPink
    cell.delegate = self
    return cell
  }
}


// MARK: - UITableViewDelegate

extension UserChatsViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let userChat = self.userChats[indexPath.row]
    let viewModel = UserChatCellModel(userChat: userChat)
    return UserChatCell.height(fits: tableView.frame.size.width, viewModel: viewModel)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView.isEditing {
      self.navigationItem.rightBarButtonItem?.isEnabled = true
      return
    }
    
    tableView.deselectRow(at: indexPath, animated: true)

    let userChat = self.userChats[indexPath.row]
    self.showUserChat(userChatId: userChat.id, animated: true)
  }

  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if let count = tableView.indexPathsForSelectedRows?.count {
      self.navigationItem.rightBarButtonItem?.isEnabled = count != 0
    } else {
      self.navigationItem.rightBarButtonItem?.isEnabled = false 
    }
  }
  
  @nonobjc func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
}

extension UserChatsViewController {
  func fetchUserChats(isInit: Bool = false, showIndicator: Bool = false, isReload: Bool = false) {
    if showIndicator {
      SVProgressHUD.show()
    }
    
    UserChatPromise.getChats(since: isInit ? nil : self.nextSeq, limit: 30, showCompleted: self.showCompleted)
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (data) in
        
        self?.didLoad = true
        self?.showChatIfNeeded(data["userChats"] as? [CHUserChat], isReload: isReload)
        mainStore.dispatch(GetUserChats(payload: data))
      }, onError: { [weak self] error in
        dlog("Get UserChats error: \(error)")
        self?.errorToastView.display(animated:true)
        self?.didLoad = false

        SVProgressHUD.dismiss()
        mainStore.dispatch(FailedGetUserChats(error: error))
      }, onCompleted: {
        SVProgressHUD.dismiss()
        dlog("Get UserChats complete")
      }).disposed(by: self.disposeBag)
  }
  
  func deleteUserChat(userChat: CHUserChat) -> Observable<CHUserChat> {
    return Observable.create { subscribe in
      
      let observe = userChat.remove()
        .subscribe(onNext: { (_) in
          subscribe.onNext(userChat)
          subscribe.onCompleted()
        }, onError: { (error) in
          subscribe.onError(error)
        })
      
      return Disposables.create() {
        observe.dispose()
      }
    }
  }
  
  func showChatIfNeeded(_ userChats: [CHUserChat]?, isReload: Bool = false) {
    let allChats = userChatsSelector(state: mainStore.state) + (userChats ?? [])
    
    if self.showNewChat  {
      self.showUserChat(animated: false)
    } else if let userChatId = self.goToUserChatId {
      self.showUserChat(userChatId: userChatId, animated: false)
      self.goToUserChatId = nil
    } else if !isReload {
      if allChats.count == 0 {
        self.shouldHideTable = true
        self.showUserChat(animated: false)
      } else if let chat = allChats.first, allChats.count == 1 {
        self.shouldHideTable = true
        self.showUserChat(userChatId: chat.id, animated: false)
      }
    }
  }
}

extension UserChatsViewController {
  func showWatermarkIfNeeded() {
    if !mainStore.state.channel.notAllowToUseSDK {
      return
    }
    
    let yOffset = self.tableView.contentOffset.y
    let contentHeight = CGFloat(self.userChats.count * 84)
    if contentHeight > self.tableView.bounds.height - 40 {
      let triggerOffset = contentHeight - self.tableView.bounds.height - 40
      if yOffset > 0 && yOffset > triggerOffset {
        self.progressWatermark(yOffset - triggerOffset)
      } else {
        self.progressWatermark(0)
      }
    } else {
      self.progressWatermark(40)
    }
  }
  
  func progressWatermark(_ offset: CGFloat) {
    self.watermarkView.alpha = offset/40
  }
}

extension UserChatsViewController : MGSwipeTableCellDelegate {
  func swipeTableCell(
    _ cell: MGSwipeTableCell,
    tappedButtonAt index: Int,
    direction: MGSwipeDirection,
    fromExpansion: Bool) -> Bool {
    
    guard let indexPath = self.tableView.indexPath(for: cell) else { return true }
    
    self.deleteUserChat(userChat: self.userChats[indexPath.row])
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (userChat) in
        mainStore.dispatch(DeleteUserChat(payload: userChat))
      }, onError: { (error) in
          //on error??
      }).disposed(by: self.disposeBag)
        
    return false
  }
}
