//
//  ProfileViewController.swift
//  CHPlugin
//
//  Created by Haeun Chung on 18/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SVProgressHUD
import SnapKit
import RxSwift
import ReSwift

private enum ProfileSection: Int {
  case action
}

private enum UserInfoRow: Int {
  case name
  case phone
}

private enum ActionRow: Int {
  case closedChats
  case soundOption
}

final class ProfileViewController: BaseViewController {
  struct Constant {
    static let sectionCount = 2
    static let userInfoCount = 2
    static let actionCount = 2
  }
  
  let tableView = UITableView()
  let footerView = UIView()
  let logoImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "channelSymbol")
    $0.contentMode = .center
  }
  let versionLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
  }
  
  let headerView = ProfileHeaderView()
  let deleteSubject = PublishSubject<Any?>()
  let disposeBag = DisposeBag()
  var userInfoModel = [String]()

  var guest: CHGuest?
  
  var panGestureRecognizer: UIPanGestureRecognizer? = nil
  var originalPosition: CGPoint?
  var currentPositionTouched: CGPoint?
  
  var userName:String = "" {
    didSet {
      if self.guest is CHVeil || self.userName != "" {
        self.userInfoModel.append("username")
      }
    }
  }
  
  var phoneNumber:String = "" {
    didSet {
      if self.guest is CHVeil || self.phoneNumber != "" {
        self.userInfoModel.append("phonenumber")
      }
    }
  }
  
  var hideOptions = false
  var showCompleted = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.setNavigation()
    self.handleActions()
    
    self.tableView.separatorStyle = .none
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.isScrollEnabled = false
    
    self.footerView.addSubview(self.versionLabel)
    self.footerView.addSubview(self.logoImageView)
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.footerView)
    
    let version = Bundle(for: ChannelPlugin.self)
      .infoDictionary?["CFBundleShortVersionString"] as! String
    self.versionLabel.text = "v\(version)"
    
    let channel = mainStore.state.channel
    let height:CGFloat = channel.homepageUrl != "" || channel.phoneNumber != "" ? 180 : 110
    self.headerView.frame = CGRect(
      x: 0, y: 0,
      width: self.tableView.width,
      height: height
    )
    self.tableView.tableHeaderView = self.headerView
    
//    TODO: drag to dismiss
//    self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dismissAction(_:)))
//    self.view.addGestureRecognizer(self.panGestureRecognizer!)
  }
  
  @objc func dismissAction(_ panGesture: UIPanGestureRecognizer) {
    let translation = panGesture.translation(in: self.navigationController?.view)
    
    if panGesture.state == .began {
      originalPosition = CGPoint(x: 0, y: 20)
      currentPositionTouched = panGesture.location(in: self.navigationController?.view)
    } else if panGesture.state == .changed {
      self.navigationController?.view.frame.origin = CGPoint(
        x: 0,
        y: translation.y > 0 ? translation.y : 0
      )
    } else if panGesture.state == .ended {
      let velocity = panGesture.velocity(in: view)
      
      if velocity.y >= 1500 || translation.y > self.view.frame.size.height * 0.2 {
        UIView.animate(withDuration: 0.2
          , animations: {
            self.navigationController?.view.frame.origin = CGPoint(
              x: 0,
              y: self.navigationController?.view.frame.size.height ?? 0
            )
        }, completion: { (isCompleted) in
          if isCompleted {
            self.dismiss(animated: false, completion: nil)
          }
        })
      } else {
        UIView.animate(withDuration: 0.2, animations: {
          self.navigationController?.view.origin = self.originalPosition!
        })
      }
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
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.tableView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.footerView.snp.makeConstraints { (make) in
      make.height.equalTo(48)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.logoImageView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
    }
    
    self.versionLabel.snp.makeConstraints { (make) in
      make.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(10)
    }
  }
  
  func setNavigation() {
    
    self.title = CHAssets.localized("ch.settings.title")
    self.navigationItem.leftBarButtonItem = NavigationItem(
      image: CHAssets.getImage(named: "exit"),
      style: .plain,
      actionHandler: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }
    )
  }
  
  func handleActions() {
    self.logoImageView.signalForClick()
      .subscribe(onNext: { _ in
        let channel = mainStore.state.channel
        let urlString = "https://channel.io/" +
          "?utm_campaign=plugin_exposure_ios" +
          "&utm_medium=plugin&utm_source=" +
          (channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")

        if let url = URL(string: urlString) {
          url.open()
        }
      }).disposed(by: self.disposeBag)
  }
  
  func signalForDelete() -> Observable<Any?> {
    return self.deleteSubject
  }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.hideOptions ? Constant.sectionCount - 1 : Constant.sectionCount
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case ProfileSection.action.rawValue:
      if self.hideOptions {
        return 0
      }
      
      return Constant.actionCount
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (ProfileSection.action.rawValue,
          ActionRow.closedChats.rawValue):
      let cell = SwitchCell()
      let isOn = mainStore.state.userChatsState.showCompletedChats
      cell.switchSignal.subscribe { event in
        PrefStore.setVisibilityOfClosedUserChat(on: event.element!)
        mainStore.dispatch(
          UpdateVisibilityOfCompletedChats(show: event.element)
        )
      }.disposed(by: self.disposeBag)
      cell.selectionStyle = .none
      cell.configure(title: CHAssets.localized("ch.settings.show_closed_chat"), isOn: isOn)
      return cell
    case (ProfileSection.action.rawValue,
          ActionRow.soundOption.rawValue):
      let cell = SwitchCell()
      let isOn = PrefStore.getPushSoundOption()
      cell.switchSignal.subscribe { event in
        if let isOn = event.element {
          PrefStore.setPushSoundOption(on: isOn)
        }
      }.disposed(by: self.disposeBag)
      cell.selectionStyle = .none
      cell.configure(title: CHAssets.localized("ch.settings.enable_chat_sound_vibrate"), isOn: isOn)
      return cell
    default:
      return  UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case ProfileSection.action.rawValue:
      return LabelCell.height()
    default:
      return 40
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case ProfileSection.action.rawValue:
      return 10
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case ProfileSection.action.rawValue:
      return UIView()
    default:
      return nil
    }
  }
}

extension ProfileViewController : StoreSubscriber {
  func newState(state: AppState) {
    self.guest = state.guest

    self.headerView.configure(
      plugin: state.plugin,
      channel: state.channel
    )

    if let guest = self.guest {
      self.userInfoModel.removeAll()
      self.userName = guest.ghost ? "" : guest.name
      self.phoneNumber = guest.mobileNumber ?? ""
    }
    
    let showCompleted = state.userChatsState.showCompletedChats
    if self.showCompleted != showCompleted {
      self.showCompleted = showCompleted
      self.fetchUserChats(showCompleted)
    }
    
    self.tableView.reloadData()
  }

  func fetchUserChats(_ showCompleted: Bool) {
    SVProgressHUD.show()
    
    UserChatPromise.getChats(
      since: nil,
      limit: 30, sortOrder: "DESC",
      showCompleted: showCompleted)
      .subscribe(onNext: { (data) in
        mainStore.dispatch(GetUserChats(payload: data))
      }, onError: { [weak self] error in
        dlog("Get UserChats error: \(error)")
        SVProgressHUD.dismiss()
        self?.tableView.reloadData()
      }, onCompleted: { [weak self] in
        dlog("Get UserChats complete")
        SVProgressHUD.dismiss()
        self?.tableView.reloadData()
      }).disposed(by: self.disposeBag)
  }
  
  func openAgreement() {
    let locale = CHUtils.getLocale() ?? "ko"
    let url = "https://channel.io/" +
      locale +
      "/terms_user?channel=" +
      (mainStore.state.channel.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
    
    guard let link = URL(string: url) else { return }
    link.open()
  }
}
