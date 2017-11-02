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
  case userInfo
  case action
}

private enum UserInfoRow: Int {
  case name
  case phone
}

private enum ActionRow: Int {
  case closedChats
  case soundOption
  case deleteChat
}

final class ProfileViewController: BaseViewController {
  struct Constant {
    static let sectionCount = 2
    static let userInfoCount = 2
    static let actionCount = 3
  }
  
  let tableView = UITableView()
  let footerView = UIView()
  let logoImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "channelSymbol")
    $0.contentMode = .center
  }
  
  let headerView = ProfileHeaderView()
  let deleteSubject = PublishSubject<Any?>()
  let disposeBag = DisposeBag()
  var userInfoModel = [String]()
  
  var guest: CHGuest?
  
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
  
  var chatCount = 0 {
    didSet {
      self.canDelete = self.chatCount != 0
    }
  }
  
  var hideOptions = false
  var canDelete = false
  var showCompleted = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.setNavigation()
    self.handleActions()
    self.tableView.separatorStyle = .none
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.isScrollEnabled = false
    
    self.footerView.addSubview(self.logoImageView)
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.footerView)
    
    let channel = mainStore.state.channel
    self.headerView.frame = CGRect(
      x: 0, y: 0,
      width: self.tableView.width,
      height: channel.phoneNumber != "" ? 142 : 114
    )
    self.tableView.tableHeaderView = self.headerView
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
    
    self.tableView.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.footerView.snp.remakeConstraints { (make) in
      make.height.equalTo(48)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.logoImageView.snp.remakeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
    }
  }
  
  func setNavigation() {
    
    self.title = CHAssets.localized("ch.settings.title")
    self.navigationItem.rightBarButtonItem = NavigationItem(
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
    case ProfileSection.userInfo.rawValue:
      if self.guest is CHVeil {
        return Constant.userInfoCount
      } else if self.guest is CHUser {
        return self.userInfoModel.count
      }
      
      return Constant.userInfoCount
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
    case (ProfileSection.userInfo.rawValue,_):
      let model = self.userInfoModel[indexPath.row]
      if model == "username" {
        let cell = TextInputCell()
        cell.textField.text = self.guest?.ghost == true ? "" : self.userName
        cell.textField.isUserInteractionEnabled = false
        cell.textField.placeholder = CHAssets.localized("ch.settings.name_placeholder")
        cell.isEditable = self.guest is CHVeil
        return cell
      } else if model == "phonenumber" {
        let cell = TextInputCell()
        cell.textField.text = self.phoneNumber
        cell.textField.isUserInteractionEnabled = false
        cell.textField.placeholder = CHAssets.localized("ch.settings.phone_number_placeholder")
        cell.isEditable = self.guest is CHVeil
        return cell
      }
      return UITableViewCell()
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
      cell.configure(title: CHAssets.localized("ch.settings.resolved_chat"), isOn: isOn)
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
      cell.configure(title: CHAssets.localized("ch.settings.enable_sound_vibrate"), isOn: isOn)
      return cell
    case (ProfileSection.action.rawValue,
          ActionRow.deleteChat.rawValue):
      let cell = LabelCell()
      cell.disabled = !self.canDelete
      cell.isUserInteractionEnabled = self.canDelete
      cell.titleLabel.text = CHAssets.localized("ch.settings.close_chat")
      return cell
    default:
      return  UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case ProfileSection.userInfo.rawValue:
      return TextInputCell.height()
    case ProfileSection.action.rawValue:
      return LabelCell.height()
    default:
      return 40
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (ProfileSection.userInfo.rawValue,
          UserInfoRow.name.rawValue):
      if self.guest is CHUser {
        break
      }
      let controller = ProfileEditViewController(
        type: .name, text: self.userName)
      self.navigationController?.pushViewController(controller, animated: true)
      break
    case (ProfileSection.userInfo.rawValue,
          UserInfoRow.phone.rawValue):
      if self.guest is CHUser {
        break
      }
      let controller = ProfileEditViewController(
        type: .phone, text: self.phoneNumber)
      self.navigationController?.pushViewController(controller, animated: true)
      break
    //case (ProfileSection.action.rawValue,
    //      ActionRow.closeChat.rawValue):
      
    //  break
    case (ProfileSection.action.rawValue,
          ActionRow.deleteChat.rawValue):
      if self.canDelete {
        self.deleteSubject.onNext(nil)
      }
      break
    default:
      break
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case ProfileSection.userInfo.rawValue:
      let view = UIView()
      let label = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = CHColors.blueyGrey
        $0.text = CHAssets.localized("ch.settings.my_info")
      }
      view.addSubview(label)
      
      label.snp.makeConstraints({ (make) in
        make.leading.equalToSuperview().inset(16)
        make.trailing.equalToSuperview().inset(16)
        make.bottom.equalToSuperview().inset(6)
      })
      
      return view
    default:
      let view = UIView()
      let divider = UIView().then {
        $0.backgroundColor = CHColors.stale10
      }
      view.addSubview(divider)
      
      divider.snp.remakeConstraints({ (make) in
        make.height.equalTo(1)
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
        make.centerY.equalToSuperview()
      })
      
      return view
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case ProfileSection.userInfo.rawValue:
      return 38
    case ProfileSection.action.rawValue:
      return self.hideOptions ? 0 : 17
    default:
      return 0
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
    
    let userChats = userChatsSelector(
      state: state,
      showCompleted: state.userChatsState.showCompletedChats
    )
    self.chatCount = userChats.count
    
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
}
