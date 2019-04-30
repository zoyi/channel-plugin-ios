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
  weak var presenter: LoungePresenter?
  
  let tableView = UITableView().then {
    $0.isScrollEnabled = false
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
  
  override func initialize() {
    super.initialize()
    
    self.layer.cornerRadius = 10
    self.clipsToBounds = true
    
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
    view.seeMoreLabel.isHidden = self.chats.count <= 3
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
  }
  let seeMoreLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.charcoalGrey
  }
  
  var moreSignal = PublishRelay<Any?>()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.recentLabel)
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
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(46)
    }
  }
}
