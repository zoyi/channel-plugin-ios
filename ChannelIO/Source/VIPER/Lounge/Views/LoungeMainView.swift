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
    static let defaultFooterHeight = 16.f
    static let newChatFooterHeight = 70.f
    static let allChatFooterHeight = 36.f
    static let tableViewCornerRadius = 16.f
  }
  
  private struct Metrics {
    static let tableViewBottom = 36.f
    static let allTop = 12.f
  }
  
  weak var presenter: LoungePresenterProtocol?
  
  private let tableView = UITableView().then {
    $0.isScrollEnabled = false
    $0.separatorStyle = .none
    $0.register(cellType: UserChatCell.self)
  }

  private let moreView = LoungeMoreView().then {
    $0.isHidden = true
  }
  
  private var errorView: LoungeMainErrorView?
  private var welcomeModel: UserChatCellModel?
  private var welcomeCellHeight: CGFloat = 0
  
  private var activeChats: [UserChatCellModel] = []
  private var inactiveChats: [UserChatCellModel] = []
  private var disposeBag = DisposeBag()
  
  private var shouldShowWelcome: Bool {
    return self.activeChats.count == 0 && welcomeModel != nil
  }
  
  private var shouldShowAllChat: Bool {
    return self.inactiveChats.count != 0 ||
      self.activeChats.count > Constants.maxNumberOfCell
  }
  
  private var otherChatCount: Int {
    let otherActiveChatCount = self.activeChats.count > Constants.maxNumberOfCell ?
      self.activeChats.count - Constants.maxNumberOfCell : 0
    return self.inactiveChats.count + otherActiveChatCount
  }
  
  private var visibleChats: [UserChatCellModel] {
    return self.activeChats.count > Constants.maxNumberOfCell ?
      Array(self.activeChats[0...2]) : self.activeChats
  }
  
  private var tableViewBottomConstraint: Constraint? = nil
  
  var chatSignal = PublishRelay<UserChatCellModel>()
  var newSignal = PublishRelay<Any?>()
  var moreSignal = PublishRelay<Any?>()
  var refreshSignal = PublishRelay<Any?>()
  
  var viewHeight: CGFloat {
    if let model = self.welcomeModel, self.shouldShowWelcome {
      self.welcomeCellHeight = UserChatCell.calculateHeight(
        fits: self.frame.width,
        viewModel: model,
        maxNumberOfLines: Constants.maxNumberOfLinesForWelcomeCell)
      
      var height = self.welcomeCellHeight +
        Constants.defaultHeaderHeight +
        Constants.newChatFooterHeight
      if self.shouldShowAllChat {
        height += Constants.allChatFooterHeight
      }
      return height
    } else {
      var height = CGFloat(min(self.visibleChats.count, Constants.maxNumberOfCell)) * Constants.defaultCellHeight
      height += Constants.headerHeight
      height += Constants.defaultFooterHeight
      if self.shouldShowAllChat {
        height += Constants.allChatFooterHeight
      }
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
    
    self.tableView.layer.cornerRadius = Constants.tableViewCornerRadius
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    self.addSubview(self.tableView)
    self.addSubview(self.moreView)
    
    self.tableView.showIndicatorTo(.content)
    self.moreView.signalForClick()
      .bind(to: self.moreSignal)
      .disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.tableView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.trailing.equalToSuperview()
      self.tableViewBottomConstraint = make.bottom.equalToSuperview()
        .inset(Metrics.tableViewBottom).constraint
    }
    
    self.moreView.snp.makeConstraints { (make) in
      make.top.equalTo(self.tableView.snp.bottom).offset(Metrics.allTop)
      make.centerX.equalToSuperview()
    }
  }
  
  override func displayError() {
    self.tableView.isHidden = true
    
    let errorView = LoungeMainErrorView()
    errorView.layer.cornerRadius = Constants.tableViewCornerRadius
    
    self.addSubview(errorView)
    errorView.refreshSignal.subscribe(onNext: { [weak self] (_) in
      self?.refreshSignal.accept(nil)
    }).disposed(by: self.disposeBag)
    
    errorView.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.errorView = errorView
  }
  
  func reloadContent() {
    self.configure(
      activeChats: self.activeChats,
      inactiveChats: self.inactiveChats,
      welcomeModel: self.welcomeModel
    )
  }
  
  func configure(
    activeChats: [UserChatCellModel],
    inactiveChats: [UserChatCellModel],
    welcomeModel: UserChatCellModel?) {
    self.activeChats = activeChats
    self.inactiveChats = inactiveChats
    self.welcomeModel = welcomeModel
    
    self.errorView?.removeFromSuperview()
    self.errorView = nil

    self.moreView.configure(moreCount: self.otherChatCount)
    self.tableViewBottomConstraint?.update(inset: self.otherChatCount != 0 ? Metrics.tableViewBottom : 0)
    
    self.tableView.isHidden = false
    self.tableView.hideIndicatorTo(.content)
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
    if self.shouldShowWelcome {
      return self.welcomeModel != nil ? 1 : 0
    }
    return min(self.activeChats.count, Constants.maxNumberOfCell)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let count = min(self.activeChats.count, Constants.maxNumberOfCell)
    if self.shouldShowWelcome {
      return Constants.defaultHeaderHeight
    } else if count != 0 {
      return Constants.headerHeight
    }
    else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let count = min(self.activeChats.count, Constants.maxNumberOfCell)
    let view = LoungeMainHeaderView()
    view.newChatSignal()
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    if self.shouldShowWelcome {
      return UIView()
    }
    return count != 0 ? view : nil
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if self.shouldShowWelcome {
      return Constants.newChatFooterHeight
    }
    return self.otherChatCount != 0 ? Constants.defaultFooterHeight : 0
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = LoungeMainFooterView()
    view.newChatSignal()
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    if self.shouldShowWelcome {
      return view
    }
    return self.otherChatCount != 0 ? UIView() : nil
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return !self.shouldShowWelcome ? Constants.defaultCellHeight : self.welcomeCellHeight
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !self.shouldShowWelcome {
      let cell: UserChatCell = tableView.dequeueReusableCell(for: indexPath)
      let model = self.activeChats[indexPath.row]
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
    if !self.shouldShowWelcome {
      let chat = self.activeChats[indexPath.row]
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
    self.presenter?.didClickOnDelete(chatId: self.activeChats[indexPath.row].chatId)
    return true
  }
}
