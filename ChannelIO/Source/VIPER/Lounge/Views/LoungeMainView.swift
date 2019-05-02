//
//  LoungeMainView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class LoungeMainView: BaseView {
  struct Metric {
    static let sectionHeaderHeight = 30.f
    static let sectionFooterHeight = 70.f
  }
  
  struct Constant {
    static let maxNumberOfCell = 3
  }
  
  weak var presenter: LoungePresenter?
  
  let tableView = UITableView().then {
    $0.isScrollEnabled = false
    $0.separatorStyle = .none
    $0.register(cellType: UserChatCell.self)
  }
  
  var welcomeModel: UserChatCellModel?
  let welcomeCell = UserChatCell().then {
    $0.messageLabel.numberOfLines = 8
  }
  var chats: [UserChatCellModel] = []
  
  var chatSignal = PublishRelay<UserChatCellModel>()
  var newSignal = PublishRelay<Any?>()
  var moreSignal = PublishRelay<Any?>()
  
  var disposeBag = DisposeBag()
  
  var welcomeCellHeight: CGFloat {
    self.welcomeCell.setNeedsLayout()
    self.welcomeCell.layoutIfNeeded()
    
    return self.welcomeCell.frame.height
  }
  
  var viewHeight: CGFloat {
    if self.chats.count == 0 && self.welcomeModel != nil {
      return self.welcomeCellHeight + Metric.sectionFooterHeight
    } else if self.chats.count < 4 {
      return CGFloat(self.chats.count * 80) + Metric.sectionFooterHeight
    } else {
      return CGFloat(Constant.maxNumberOfCell * 80) +
        Metric.sectionHeaderHeight +
        Metric.sectionFooterHeight
    }
  }
  
  override func initialize() {
    super.initialize()
    
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOffset = CGSize(width: 0.f, height: 0.f)
    self.layer.shadowRadius = 4.f
    self.layer.shadowOpacity = 0.5
    self.layer.masksToBounds = false
    
    self.tableView.layer.cornerRadius = 10
    self.tableView.delegate = self
    self.tableView.dataSource = self
  
    self.addSubview(self.tableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.tableView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  func configure(with chats: [UserChatCellModel], welcomeModel: UserChatCellModel?) {
    self.chats = chats
    self.welcomeModel = welcomeModel
    self.tableView.reloadData()
  }
}

extension LoungeMainView {
  func signalForMore() -> Observable<Any?> {
    return self.moreSignal.asObservable()
  }
  
  func signalForChat() -> Observable<UserChatCellModel> {
    return self.chatSignal.asObservable()
  }
  
  func signalForNew() -> Observable<Any?> {
    return self.newSignal.asObservable()
  }
}

extension LoungeMainView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.chats.count > 0 ? min(self.chats.count, 3) : self.welcomeModel != nil ? 1 : 0
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.chats.count > 3 ? 30 : CGFloat.leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = LoungeTableFooterView()
    view.newChatSignal
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = LoungeTableHeaderView()
    view.configure(guest: mainStore.state.guest, chatModels: self.chats)
    view.moreSignal
      .bind(to: self.moreSignal)
      .disposed(by: self.disposeBag)
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let maxWidth = UIScreen.main.bounds.width - 16
    return self.chats.count > 0 ? 80 : self.welcomeCell.height(fits: maxWidth, viewModel: self.welcomeModel)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
    let model = self.chats[indexPath.row]
    cell.configure(model)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.chats.count != 0 {
      let chat = self.chats[indexPath.row]
      self.chatSignal.accept(chat)
    } else {
      self.newSignal.accept(nil)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

class LoungeTableHeaderView: BaseView {
  let recentLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
    $0.text = "최근대화"
  }
  let alertCountLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.warmPink
  }
  let seeMoreLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.charcoalGrey
    $0.text = CHAssets.localized("전체 보기")
  }
  
  var moreSignal = PublishRelay<Any?>()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.recentLabel)
    self.addSubview(self.alertCountLabel)
    self.addSubview(self.seeMoreLabel)
    _ = self.seeMoreLabel.signalForClick().bind(to: self.moreSignal)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.recentLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(12)
    }
    
    self.seeMoreLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalTo(self.recentLabel.snp.centerY)
      make.trailing.equalToSuperview().inset(16)
    }
    
    self.alertCountLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalTo(self.recentLabel.snp.centerY)
      make.trailing.equalTo(self.seeMoreLabel.snp.leading).offset(-5)
    }
  }
  
  func configure(guest: CHGuest, chatModels: [UserChatCellModel]) {
    guard let guestAlert = guest.alert else { return }
    
    if chatModels.count > 3 {
      let displayAlertCounts = chatModels[0...2]
        .map { $0.badgeCount }
        .reduce(0) { (result, next) in
          return result + next
      }
      let restCount = guestAlert - displayAlertCounts
      
      self.seeMoreLabel.font = restCount > 0 ?
        UIFont.boldSystemFont(ofSize: 13) :
        UIFont.systemFont(ofSize: 13)
      
      self.alertCountLabel.text = "\(guestAlert - displayAlertCounts)"
      self.alertCountLabel.isHidden = restCount <= 0
    } else {
      self.seeMoreLabel.isHidden = true
      
    }

  }
}

class LoungeTableFooterView: BaseView {
  let newChatButton = CHButton.newChat()
  
  let newChatSignal = PublishRelay<Any?>()
  override func initialize() {
    super.initialize()
    self.addSubview(self.newChatButton)
    _ = self.newChatButton.signalForClick().bind(to: self.newChatSignal)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.newChatButton.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
      make.height.equalTo(46)
    }
  }
}
