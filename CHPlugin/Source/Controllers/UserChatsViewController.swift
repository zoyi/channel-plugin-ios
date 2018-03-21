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
import CGFloatLiteral

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
  let errorToastView = ErrorToastView()
  let plusButton = NewChatView()
  
  var showCompleted = false
  var didLoad = false
  var showNewChat = false
  var shouldHideTable = false
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
    self.view.addSubview(self.plusButton)
    self.view.addSubview(self.watermarkView)
    
    self.errorToastView.topLayoutGuide = self.topLayoutGuide
    self.errorToastView.containerView = self.view
    self.view.addSubview(self.errorToastView)
    
    self.initTableView()
    self.initActions()
    //self.initNotifications()
    self.setDefaultNavItems()
    
    self.showCompleted = mainStore.state.userChatsState.showCompletedChats
    self.fetchUserChats(isInit: true, showIndicator: true)
  }

  func initTableView() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.allowsMultipleSelectionDuringEditing = true
    
    self.diffCalculator = SingleSectionTableViewDiffCalculator<CHUserChat>(
      tableView: self.tableView, initialRows: self.userChats
    )
    self.diffCalculator?.forceOffAnimationEnabled = true
    self.diffCalculator?.insertionAnimation = UITableViewRowAnimation.none
    self.diffCalculator?.deletionAnimation = UITableViewRowAnimation.none
  }
  
  func initNotifications() {
    NotificationCenter.default.rx
      .notification(NSNotification.Name.UIApplicationDidBecomeActive)
      .subscribe(onNext: { [weak self] (_) in
        self?.fetchUserChats(isInit: true)
      }).disposed(by: self.disposeBag)
  }
  
  func initActions() {
    self.errorToastView.refreshImageView.signalForClick()
      .subscribe { [weak self] _ in
        self?.nextSeq = nil
        self?.fetchUserChats(isInit: true, showIndicator: true)
        WsService.shared.connect()
      }.disposed(by: self.disposeBag)
    
    self.plusButton.signalForClick()
      .subscribe { [weak self] _ in
        self?.showUserChat()
      }.disposed(by: self.disposeBag)
    
    self.watermarkView.signalForClick()
      .subscribe{ _ in
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
    
    self.watermarkView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(40)
    }
  }

  // MARK: - Helper methods
  fileprivate func setDefaultNavItems() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: CHAssets.getImage(named: "exit"),
      style: .plain,
      target: self,
      action: #selector(exitMessengerButtonTapped(sender:))
    )
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: CHAssets.getImage(named: "settings"),
      style: .plain,
      target: self,
      action: #selector(moreButtonTapped(sender:))
    )
  }

  fileprivate func setEditingNavItems() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: CHAssets.localized("ch.chat.resend.cancel"),
      style: .plain,
      target: self,
      action: #selector(exitEditingMode(sender:))
    )
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: CHAssets.localized("ch.chat.delete"),
      style: .plain,
      target: self,
      action: #selector(deleteSelectedUserChats(sender:))
    )
    self.navigationItem.rightBarButtonItem?.isEnabled = false
  }

  fileprivate func showPlusButton() {
    self.plusBottomConstraint?.update(inset: 24)
    UIView.animate(withDuration: 0.3) { 
      self.view.layoutIfNeeded()
    }
  }
  
  fileprivate func hidePlusButton() {
    let margin = -24 - self.plusButton.height
    self.plusBottomConstraint?.update(inset: margin)
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func showUserChat(userChatId: String? = nil, text:String = "", animated: Bool = true) {
    let controller = UserChatViewController()
    if let userChatId = userChatId {
      controller.userChatId = userChatId
    }
    
    self.showNewChat = true
    
    controller.preloadText = text
    controller.signalForNewChat()
      .subscribe { [weak self] event in
        self?.navigationController?.popViewController(
          animated: true, completion: {
            let text = event.element as! String
            self?.showUserChat(text: text, animated: true)
        })
      }.disposed(by: self.disposeBag)
    
    controller.signalForProfile()
      .subscribe { [weak self] _ in
        self?.showProfileView()
      }.disposed(by: self.disposeBag)
    
    PluginPromise.getFollowingManagers()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext:{ [weak self] (managers) in
        mainStore.dispatch(
          UpdateFollowingManagers(payload: managers)
        )
        self?.navigationController?.pushViewController(controller, animated: animated)
        self?.showNewChat = false
        self?.shouldHideTable = false
      }).disposed(by: self.disposeBag)
  }

  func showProfileView() {
    let controller = ProfileViewController()
    let navigation = MainNavigationController(rootViewController: controller)
    navigation.modalPresentationStyle = .overCurrentContext
    self.navigationController?.present(navigation, animated: true, completion: nil)
  }
}

// MARK: Navigation actions

extension UserChatsViewController {
  @objc func exitEditingMode(sender: UIBarButtonItem) {
    self.tableView.setEditing(false, animated: true)
    self.setDefaultNavItems()
  }
  
  @objc func deleteSelectedUserChats(sender: UIBarButtonItem) {
    //delete selections
    if let selectedRows = self.tableView.indexPathsForSelectedRows {
      self.deleteUserChats(selectedRows: selectedRows)
        .subscribe(onNext: { [weak self] (deletedChatIds, indexPaths) in
          mainStore.dispatch(DeleteUserChats(payload: deletedChatIds))

          self?.tableView.setEditing(false, animated: true)
          self?.setDefaultNavItems()
      }, onError: { (error) in
        //on error??
      }).disposed(by: self.disposeBag)
    }
  }
  
  @objc func exitMessengerButtonTapped(sender: UIBarButtonItem) {
    ChannelPlugin.hide(animated: true)
  }
  
  @objc func moreButtonTapped(sender: UIBarButtonItem) {
    self.showProfileView()
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
    
    self.plusButton.configure(
      bgColor: state.plugin.color,
      borderColor: state.plugin.borderColor,
      tintColor: state.plugin.textColor)
   
    if state.socketState.state == .disconnected ||
      state.socketState.state == .reconnecting {
      self.errorToastView.show(animated: true)
    } else {
      self.errorToastView.hide(animated: true)
    }
    
    // fetch data
    let showCompleted = state.userChatsState.showCompletedChats
    if self.showCompleted != showCompleted {
      self.showCompleted = showCompleted
      self.nextSeq = nil
      self.fetchUserChats(isInit: true, showIndicator: true)
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
    } else if self.scrollOffset > yOffset &&
      self.scrollOffset < scrollView.contentSize.height {
      self.showPlusButton()
    }
    
    //if close to bottom show watermark
    //else hide
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
    return UserChatCell.height(fits: tableView.width, viewModel: viewModel)
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
  func fetchUserChats(isInit: Bool = false, showIndicator: Bool = false) {
//    if showIndicator {
//      SVProgressHUD.show()
//    }

    UserChatPromise.getChats(
      since: isInit ? nil : self.nextSeq,
      limit: 30, sortOrder: "DESC",
      showCompleted: self.showCompleted)
      .subscribe(onNext: { [weak self] (data) in
        self?.didLoad = true
        self?.showChatIfNeeded(data["userChats"] as? [CHUserChat])

        mainStore.dispatch(GetUserChats(payload: data))
        //SVProgressHUD.dismiss()
      }, onError: { [weak self] error in
        dlog("Get UserChats error: \(error)")
        self?.errorToastView.show(animated:true)
        self?.didLoad = true
        //SVProgressHUD.dismiss()
        //mainStore.dispatch(FailedGetUserChats(error: error))
      }, onCompleted: {
        //SVProgressHUD.dismiss()
        dlog("Get UserChats complete")
      }).disposed(by: self.disposeBag)
  }
  
  func deleteUserChats(selectedRows: [IndexPath]) -> Observable<([String],[IndexPath])> {
    return Observable.create { subscribe in
      var deleteUserChatIds = [String]()
      let signals =  selectedRows.map ({ (indexPath) -> Observable<Any?> in
        let userChat = self.userChats[indexPath.row]
        deleteUserChatIds.append(userChat.id)
        return userChat.remove()
      })
      
      let observe = Observable.zip(signals)
        .subscribe(onNext: { (_) in
          subscribe.onNext((deleteUserChatIds, selectedRows))
          subscribe.onCompleted()
        }, onError: { (error) in
          subscribe.onError(error)
        })
      
      return Disposables.create() {
        observe.dispose()
      }
    }
  }
  
  func showChatIfNeeded(_ userChats: [CHUserChat]?) {
    if self.showNewChat  {
      self.showUserChat(animated: false)
    } else if let userChatId = self.goToUserChatId {
      self.showUserChat(userChatId: userChatId, animated: false)
    } else if let userChats = userChats {
      if userChats.count == 0 {
        self.shouldHideTable = true
        self.showUserChat(animated: false)
      } else if userChats.count == 1 {
        self.shouldHideTable = true
        self.showUserChat(userChatId: userChats[0].id, animated: false)
      }
    } else if let userChatId = self.goToUserChatId {
      self.showUserChat(userChatId: userChatId, animated: false)
    }
  }
}

extension UserChatsViewController {
  func showWatermarkIfNeeded() {
    if !mainStore.state.channel.isBlocked {
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
    
    self.deleteUserChats(selectedRows: [indexPath])
      .subscribe(onNext: { [weak self] (deletedChatIds, indexPaths) in
        mainStore.dispatch(DeleteUserChats(payload: deletedChatIds))
        self?.setDefaultNavItems()
      }, onError: { (error) in
          //on error??
      }).disposed(by: self.disposeBag)
        
    return false
  }
}
