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
import RxCocoa
import RxSwiftExt
import SnapKit
import SVProgressHUD
import MGSwipeTableCell

//TODO: refactoring VIPER
class UserChatsViewController: BaseViewController {

  // MARK: Properties
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
  var channel: CHChannel? = nil
  var plugin: CHPlugin? = nil
  
  var disposeBag = DisposeBag()
  var notiDisposeBag = DisposeBag()
  var errorSignal = PublishRelay<Any?>()
  
  let tableView = UITableView().then {
    $0.clipsToBounds = false
    $0.separatorStyle = .none
    $0.register(cellType: UserChatCell.self)
  }

  let emptyView = UserChatsEmptyView().then {
    $0.isHidden = true
  }

  let newChatButton = CHButtonFactory.newChat()
  
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
    self.view.addSubview(self.newChatButton)

    self.initTableView()
    self.initActions()
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
  
  func initObservers() {
    NotificationCenter.default.rx
      .notification(UIApplication.didBecomeActiveNotification)
      .subscribe(onNext: { [weak self] (_) in
        if let controller = CHUtils.getTopController(), controller == self {
          self?.fetchUserChats(isInit: true, showIndicator: false, isReload: true)
        }
      }).disposed(by: self.notiDisposeBag)
    
    //manual load of navigation
    if let nav = self.navigationController as? MainNavigationController {
      nav.newState(state: mainStore.state.plugin)
    }
    
    CHNotification.shared.refreshSignal
      .subscribe(onNext: { [weak self] (_) in
        guard let `self` = self else { return }
        self.nextSeq = nil
        self.fetchUserChats(isInit: true, showIndicator: true)
        WsService.shared.connect()
        _ = AppManager.touch()
          .subscribe(onNext: { (result) in
            mainStore.dispatch(GetTouchSuccess(payload: result))
          })
        
        CHNotification.shared.dismiss()
      }).disposed(by: self.notiDisposeBag)
    
    WsService.shared.error()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (_) in
        CHNotification.shared.display(
          message: CHAssets.localized("ch.toast.unstable_internet"),
          config: CHNotificationConfiguration.warningNormalConfig
        )
      }).disposed(by: self.notiDisposeBag)
    
    WsService.shared.ready()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { (_) in
        CHNotification.shared.dismiss()
      }).disposed(by: self.notiDisposeBag)
  }
  
  func removeObservers() {
    self.notiDisposeBag = DisposeBag()
  }
  
  func initActions() {
    self.newChatButton.signalForClick().subscribe { [weak self] _ in
      self?.showUserChat(hideTable: false)
    }.disposed(by: self.disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainStore.subscribe(self)
    //in order to reload if language has been changed
    self.tableView.reloadData()
    self.initObservers()
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    self.navigationController?.dropShadow()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
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

  override func setupConstraints() {
    super.setupConstraints()
    self.tableView.snp.makeConstraints { [weak self] make in
      if #available(iOS 11.0, *) {
        make.top.equalTo((self?.view.safeAreaLayoutGuide.snp.top)!)
        make.bottom.equalTo((self?.view.safeAreaLayoutGuide.snp.bottom)!)
      } else {
        make.top.equalToSuperview()
        make.bottom.equalToSuperview()
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }

    self.emptyView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    self.newChatButton.snp.makeConstraints { [weak self] make in
      make.centerX.equalToSuperview()
      make.height.equalTo(46)
      self?.plusBottomConstraint = make.bottom.equalToSuperview().inset(40).constraint
    }
  }
  
  // MARK: - Helper methods
  fileprivate func setDefaultNavItems() {
    let tintColor = mainStore.state.plugin.textUIColor
    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "closeWhite"),
      tintColor: tintColor,
      style: .plain,
      actionHandler: {
        ChannelIO.close(animated: true)
      })
    
    self.navigationItem.leftBarButtonItem = NavigationItem(
      image:  CHAssets.getImage(named: "back"),
      tintColor: mainStore.state.plugin.textUIColor,
      style: .plain,
      actionHandler: { [weak self] in
        _ = self?.navigationController?.popViewController(animated: true)
      })

    self.navigationItem.rightBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "closeWhite"),
      tintColor: mainStore.state.plugin.textUIColor,
      style: .plain,
      actionHandler: {
        ChannelIO.close(animated: true)
      })
    
    let titleView = ChatNavigationTitleView()
    titleView.configure(
      channel: mainStore.state.channel,
      plugin: mainStore.state.plugin)
    
    titleView.translatesAutoresizingMaskIntoConstraints = false
    titleView.layoutIfNeeded()
    titleView.sizeToFit()
    titleView.translatesAutoresizingMaskIntoConstraints = true
    self.navigationItem.titleView = titleView
  }

  fileprivate func showNewChatButton() {
    self.plusBottomConstraint?.update(inset: 40)
    UIView.animate(withDuration: 0.3) { 
      self.view.layoutIfNeeded()
    }
  }
  
  fileprivate func hideNewChatButton() {
    let margin = -40 - self.newChatButton.frame.size.height
    self.plusBottomConstraint?.update(inset: margin)
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func showUserChat(userChatId: String? = nil, text:String = "", hideTable: Bool = true, animated: Bool = true) {
    guard !self.isShowingChat else { return }
    self.isShowingChat = true
    self.tableView.isHidden = hideTable
    self.showNewChat = true
   
    let pluginSignal = CHPlugin.get(with: mainStore.state.plugin.id)
    let supportSignal = CHSupportBot.get(with: mainStore.state.plugin.id, fetch: userChatId == nil)
    
    Observable.zip(pluginSignal, supportSignal)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        SVProgressHUD.show()
        dlog("Error while opening chat. Attempting to open again")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (pluginInfo, supportEntry) in
        SVProgressHUD.dismiss()
        mainStore.dispatch(GetPlugin(plugin: pluginInfo.0, bot: pluginInfo.1))
        mainStore.dispatch(GetSupportBotEntry(bot: pluginInfo.1, entry: supportEntry))
        let controller = UserChatRouter.createModule(userChatId: userChatId, text: text)
        self?.navigationController?.pushViewController(controller, animated: animated)
        self?.showNewChat = false
        self?.isShowingChat = false
        self?.shouldHideTable = false
      }, onError: { [weak self] (error) in
        SVProgressHUD.dismiss()
        dlog("error getting following managers: \(error.localizedDescription)")
        self?.showNewChat = false
        self?.isShowingChat = false
        //self?.errorToastView.display(animated: true)
      }, onDisposed: {
        SVProgressHUD.dismiss()
      }).disposed(by: self.disposeBag)
  }
  
  func showProfileView() {
    let settingView = SettingRouter.createModule()
    self.navigationController?.pushViewController(settingView, animated: true)
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
    self.newChatButton.isHidden = self.tableView.isHidden && self.showNewChat
    self.newChatButton.isEnabled = state.channel.allowNewChat
    
    // fetch data
    let showCompleted = state.userChatsState.showCompletedChats
    if self.showCompleted != showCompleted {
      self.showCompleted = showCompleted
      self.nextSeq = nil
      self.fetchUserChats(isInit: true, showIndicator: true, isReload: true)
    }
    
    if (self.channel != state.channel || self.plugin != state.plugin),
      let titleView = self.navigationItem.titleView as? ChatNavigationTitleView {
      titleView.configure(channel: state.channel, plugin: state.plugin)
      self.channel = state.channel
      self.plugin = state.plugin
    }
  }
}

// MARK: UIScrollView Delegate

extension UserChatsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y
    if self.scrollOffset < yOffset && self.scrollOffset > 0 &&
      yOffset < scrollView.contentSize.height - scrollView.bounds.height {
      self.hideNewChatButton()
    }
    
    self.scrollOffset = yOffset
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
    self.showNewChatButton()
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.showNewChatButton()
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

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
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
    self.showUserChat(userChatId: userChat.id, hideTable: false, animated: true)
  }
}

extension UserChatsViewController {
  func fetchUserChats(isInit: Bool = false, showIndicator: Bool = false, isReload: Bool = false) {
    if showIndicator {
      SVProgressHUD.show()
    }
    
    UserChatPromise.getChats(since: isInit ? nil : self.nextSeq, limit: 30, showCompleted: self.showCompleted)
      .retry(.delayed(maxCount: 3, time: 3.0), shouldRetry: { error in
        dlog("Error while fetching chat data. Attempting to fetch again")
        return true
      })
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (data) in
        self?.didLoad = true
        
        mainStore.dispatch(GetUserChats(payload: data))
        self?.showChatIfNeeded(isReload: isReload)
      }, onError: { [weak self] error in
        dlog("Get UserChats error: \(error)")
        //self?.errorToastView.display(animated:true)
        self?.didLoad = false

        SVProgressHUD.dismiss()
        mainStore.dispatch(FailedGetUserChats(error: error))
      }, onCompleted: {
        SVProgressHUD.dismiss()
        dlog("Get UserChats complete")
      }, onDisposed: {
        SVProgressHUD.dismiss()
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
  
  func showChatIfNeeded(_ userChats: [CHUserChat]? = nil, isReload: Bool = false) {
    let allChats = userChatsSelector(state: mainStore.state, showCompleted: self.showCompleted)
    
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
