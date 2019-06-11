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
import MGSwipeTableCell

class LoungeMainView: BaseView {
  private struct Constants {
    static let maxNumberOfCell = 3
    static let maxNumberOfLines = 2
    static let maxNumberOfLinesForWelcomeCell = 8
    static let defaultCellHeight = 80.f
    static let headerHeight = 30.f
    static let defaultHeaderHeight = 10.f
    static let newChatFooterHeight = 70.f
  }
  
  weak var presenter: LoungePresenterProtocol?
  
  private let tableView = UITableView().then {
    $0.isScrollEnabled = false
    $0.separatorStyle = .none
    $0.register(cellType: UserChatCell.self)
  }
  
  var errorView: LoungeMainErrorView?
  
  var welcomeModel: UserChatCellModel?
  var welcomeCellHeight: CGFloat = 0
  
  var chats: [UserChatCellModel] = []
  
  var chatSignal = PublishRelay<UserChatCellModel>()
  var newSignal = PublishRelay<Any?>()
  var moreSignal = PublishRelay<Any?>()
  var refreshSignal = PublishRelay<Any?>()
  
  private var disposeBag = DisposeBag()
  
  private var shouldShowNewChatButton: Bool {
    return self.chats.filter { !$0.isActive }.count == 0
  }
  
  var viewHeight: CGFloat {
    if let model = self.welcomeModel, self.chats.count == 0 {
      self.welcomeCellHeight = UserChatCell.calculateHeight(
        fits: self.frame.width,
        viewModel: model,
        maxNumberOfLines: 8)
      
      return self.welcomeCellHeight + Constants.defaultHeaderHeight + Constants.newChatFooterHeight
    } else {
      var height = CGFloat(min(self.chats.count, Constants.maxNumberOfCell)) * Constants.defaultCellHeight +
        Constants.headerHeight

      height += Constants.newChatFooterHeight
      return height
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
  
  func reloadContent() {
    self.configure(with: self.chats, welcomeModel: self.welcomeModel)
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
    return self.chats.count > 0 ? min(self.chats.count, Constants.maxNumberOfCell) : self.welcomeModel != nil ? 1 : 0
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return self.chats.count != 0 ? Constants.headerHeight : Constants.defaultHeaderHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = LoungeMainHeaderView()
    view.configure(guest: mainStore.state.guest, chatModels: self.chats)
    view.moreSignal
      .bind(to: self.moreSignal)
      .disposed(by: self.disposeBag)
    return self.chats.count != 0 ? view : UIView()
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = LoungeMainFooterView()
    view.newChatButton.isEnabled = mainStore.state.channel.allowNewChat
    view.newChatSignal
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    return view
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return Constants.newChatFooterHeight
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.chats.count > 0 ? Constants.defaultCellHeight : self.welcomeCellHeight
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.chats.count > 0 {
      let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
      let model = self.chats[indexPath.row]
      cell.configure(model)
      cell.messageLabel.numberOfLines = Constants.maxNumberOfLines
      
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
    
    if let welcomeModel = self.welcomeModel {
      let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
      cell.configure(welcomeModel)
      cell.messageLabel.numberOfLines = Constants.maxNumberOfLinesForWelcomeCell
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

extension LoungeMainView: MGSwipeTableCellDelegate {
  func swipeTableCell(
    _ cell: MGSwipeTableCell,
    tappedButtonAt index: Int,
    direction: MGSwipeDirection,
    fromExpansion: Bool) -> Bool {
    
    guard let indexPath = self.tableView.indexPath(for: cell) else { return true }
    self.presenter?.didClickOnDelete(chatId: self.chats[indexPath.row].chatId)
    return true
  }
}

