//
//  ActionMessageCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class ActionMessageCell: MessageCell {
  private let actionView = ActionView()
  private var messageId = ""

  private struct ActionMetrics {
    static let ActionViewTop = 16.f
    static let ActionViewTrailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.didClickOnActionButton(
          originId: self?.messageId,
          key: key,
          value: value
        )
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    
    self.actionView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(ActionMetrics.ActionViewTop)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(ActionMetrics.ActionViewTrailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.messageId = viewModel.id
    self.actionView.configure(viewModel)
    self.actionView.snp.remakeConstraints { make in
      if viewModel.text != nil || viewModel.showTranslation {
        make.top.equalTo(self.translateView.snp.bottom).offset(ActionMetrics.ActionViewTop)
      } else if viewModel.isContinuous {
        make.top.equalToSuperview().inset(ActionMetrics.ActionViewTop)
      } else {
        make.top.equalTo(self.usernameLabel.snp.bottom).offset(ActionMetrics.ActionViewTop)
      }
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(ActionMetrics.ActionViewTrailing)
      make.height.equalTo(ActionView.viewHeight(buttons: viewModel.action?.buttons ?? []))
      make.bottom.equalToSuperview()
    }
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height
      + ActionMetrics.ActionViewTop
      + ActionView.viewHeight(buttons: viewModel.action?.buttons ?? [])
  }
}

class ActionWebMessageCell: WebPageMessageCell {
  private let actionView = ActionView()
  private var messageId = ""
  
  private struct Metric {
    static let ActionWebTop = 16.f
    static let ActionWebTrailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.didClickOnActionButton(
          originId: self?.messageId,
          key: key,
          value: value
        )
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    self.webBottomConstraint?.deactivate()
    
    self.actionView.snp.makeConstraints { make in
      make.top.equalTo(self.webView.snp.bottom).offset(Metric.ActionWebTop)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.ActionWebTrailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.messageId = viewModel.id
    self.actionView.configure(viewModel)
    self.actionView.snp.remakeConstraints { make in
      make.top.equalTo(self.webView.snp.bottom).offset(Metric.ActionWebTop)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.ActionWebTrailing)
      make.height.equalTo(ActionView.viewHeight(buttons: viewModel.action?.buttons ?? []))
      make.bottom.equalToSuperview()
    }
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height
      + Metric.ActionWebTop
      + ActionView.viewHeight(
          buttons: viewModel.action?.buttons ?? []
        )
  }
}

class ActionMediaMessageCell: MediaMessageCell {
  private let actionView = ActionView()
  private var messageId = ""
  
  private struct Metric {
    static let ActionMediaTop = 16.f
    static let ActionMediaTrailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.didClickOnActionButton(
          originId: self?.messageId,
          key: key,
          value: value)
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.messageBottomConstraint?.deactivate()
    self.mediaViewBottomConstraint?.deactivate()
    
    self.actionView.snp.makeConstraints { make in
      make.top.equalTo(self.mediaCollectionView.snp.bottom).offset(Metric.ActionMediaTop)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.ActionMediaTrailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.messageId = viewModel.id
    self.actionView.configure(viewModel)
    self.actionView.snp.remakeConstraints { make in
      make.top.equalTo(self.mediaCollectionView.snp.bottom).offset(Metric.ActionMediaTop)
           make.leading.equalToSuperview()
           make.trailing.equalToSuperview().inset(Metric.ActionMediaTrailing)
      make.height.equalTo(ActionView.viewHeight(buttons: viewModel.action?.buttons ?? []))
      make.bottom.equalToSuperview()
    }
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height
      + Metric.ActionMediaTop
      + ActionView.viewHeight(
          buttons: viewModel.action?.buttons ?? []
        )
  }
}
