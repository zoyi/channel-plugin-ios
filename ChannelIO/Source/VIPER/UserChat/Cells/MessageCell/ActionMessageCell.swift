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
  
  var topConstraint: Constraint?
  var topToTextViewConstraint: Constraint?
  
  private struct Metric {
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
    self.actionView.snp.makeConstraints { make in
      self.topConstraint = make.top.equalToSuperview()
        .inset(Metric.ActionViewTop).constraint
      self.topToTextViewConstraint = make.top.equalTo(self.textView.snp.bottom)
        .offset(Metric.ActionViewTop).priority(750).constraint
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.ActionViewTrailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.messageId = viewModel.message.id
    
    if viewModel.text != nil {
      self.topConstraint?.activate()
      self.topToTextViewConstraint?.deactivate()
    } else {
      self.topConstraint?.deactivate()
      self.topToTextViewConstraint?.activate()
    }
    
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    var height = 0.f
    
    if viewModel.clipType == .File {
      height = FileMessageCell.cellHeight(fits: width, viewModel: viewModel)
    } else if viewModel.clipType == .Webpage {
      height = WebPageMessageCell.cellHeight(fits: width, viewModel: viewModel)
    } else if viewModel.clipType == .Image {
      height = MediaMessageCell.cellHeight(fits: width, viewModel: viewModel)
    } else {
      height = super.cellHeight(fits: width, viewModel: viewModel)
    }
    
    height += viewModel.shouldDisplayForm ?
      ActionView.viewHeight(
        fits: width,
        buttons: viewModel.message.action?.buttons ?? []
      ) + Metric.ActionViewTop : 0
    
    return height
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
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + Metric.ActionWebTop + ActionView.viewHeight(
      fits: width, buttons: viewModel.message.action?.buttons ?? [])
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
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + Metric.ActionMediaTop + ActionView.viewHeight(
      fits: width, buttons: viewModel.message.action?.buttons ?? [])
  }
}


class ActionFileMessageCell: FileMessageCell {
  private let actionView = ActionView()
  private var messageId = ""
  
  private struct Metric {
    static let ActionFileTop = 16.f
    static let ActionFileTrailing = 10.f
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
    
    self.actionView.snp.makeConstraints { make in
      make.top.equalTo(self.fileView.snp.bottom).offset(Metric.ActionFileTop)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.ActionFileTrailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + Metric.ActionFileTop + ActionView.viewHeight(
      fits: width, buttons: viewModel.message.action?.buttons ?? [])
  }
}


