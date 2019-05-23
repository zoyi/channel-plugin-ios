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
    static let maxNumberOfLinesForWelcomeCell = 8
    static let defaultCellHeight = 80.f
    static let headerHeight = 30.f
    static let footerHeight = 70.f
  }
  
  weak var presenter: LoungePresenter?
  
  let tableView = UITableView().then {
    $0.isScrollEnabled = false
    $0.separatorStyle = .none
    $0.register(cellType: UserChatCell.self)
  }
  
  var footerView: LoungeTableFooterView = LoungeTableFooterView()
  var errorView: LoungeMainErrorView?
  
  var welcomeModel: UserChatCellModel?
  var welcomeCellHeight: CGFloat = 0
  
  var chats: [UserChatCellModel] = []
  
  var chatSignal = PublishRelay<UserChatCellModel>()
  var newSignal = PublishRelay<Any?>()
  var moreSignal = PublishRelay<Any?>()
  var refreshSignal = PublishRelay<Any?>()
  
  var disposeBag = DisposeBag()
  

  var viewHeight: CGFloat {
    if let model = self.welcomeModel, self.chats.count == 0 {
      self.welcomeCellHeight = UserChatCell.calculateHeight(
        fits: self.frame.width,
        viewModel: model,
        maxNumberOfLines: 8)
      
      return self.welcomeCellHeight + Metric.sectionFooterHeight
    } else {
      return CGFloat(min(self.chats.count, Constant.maxNumberOfCell)) * Constant.defaultCellHeight +
        Metric.sectionHeaderHeight +
        Metric.sectionFooterHeight
    }
  }
  
  override func initialize() {
    super.initialize()
    
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOffset = CGSize(width: 0.f, height: 0.f)
    self.layer.shadowRadius = 4.f
    self.layer.shadowOpacity = 0.2
    self.layer.masksToBounds = false
    
    self.tableView.layer.cornerRadius = 16
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.footerView.newChatSignal
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    
    self.addSubview(self.tableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.tableView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  override func displayError() {
    self.tableView.isHidden = true
    
    let errorView = LoungeMainErrorView()
    errorView.layer.cornerRadius = 10
    
    self.addSubview(errorView)
    errorView.refreshSignal.subscribe(onNext: { [weak self] (_) in
      errorView.startAnimation()
      self?.refreshSignal.accept(nil)
    }).disposed(by: self.disposeBag)
    
    errorView.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.errorView = errorView
  }
  
  func configure(with chats: [UserChatCellModel], welcomeModel: UserChatCellModel?) {
    self.chats = chats
    self.welcomeModel = welcomeModel
    
    self.errorView?.stopAnimation()
    self.errorView?.removeFromSuperview()
    self.errorView = nil
    
    self.tableView.isHidden = false
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
    return self.chats.count > 0 ? min(self.chats.count, Constant.maxNumberOfCell) : self.welcomeModel != nil ? 1 : 0
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.chats.count != 0 ? Constant.headerHeight : CGFloat.leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    self.footerView.newChatButton.isEnabled = mainStore.state.channel.working
    return self.footerView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return Constant.footerHeight
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
    return self.chats.count > 0 ? Constant.defaultCellHeight : self.welcomeCellHeight
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.chats.count > 0 {
      let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
      let model = self.chats[indexPath.row]
      cell.configure(model)
      return cell
    }
    
    if let welcomeModel = self.welcomeModel {
      let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(welcomeModel)
      cell.messageLabel.numberOfLines = Constant.maxNumberOfLinesForWelcomeCell
      return cell
    }
    
    return UITableViewCell()
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
    $0.text = CHAssets.localized("ch.lounge.recent_chat")
  }
  let alertCountLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.warmPink
  }
  let seeMoreLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.charcoalGrey
    $0.text = CHAssets.localized("ch.lounge.see_all")
  }
  
  var moreSignal = PublishRelay<Any?>()
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.recentLabel)
    self.addSubview(self.alertCountLabel)
    self.addSubview(self.seeMoreLabel)
    self.seeMoreLabel.signalForClick()
      .bind(to: self.moreSignal)
      .disposed(by: self.disposeBag)
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
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.newChatButton)
    
    self.newChatButton.signalForClick()
      .bind(to: self.newChatSignal)
      .disposed(by: self.disposeBag)
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
