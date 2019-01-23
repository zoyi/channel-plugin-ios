//
//  ActionMessageCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class ActionMessageCell: MessageCell {
  let actionView = ActionView()
  var messageId = ""
  
  struct Metric {
    static let top = 16.f
    static let trailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.onClickFormOption(originId: self?.messageId, key: key, value: value)
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.textMessageView.snp.bottom)!).offset(Metric.top)
      
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.trailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType, presenter: ChatManager?) {
    super.configure(viewModel, presenter: presenter)
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
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
    
    height += viewModel.shouldDisplayForm ? ActionView.viewHeight(
      fits: width, inputs: viewModel.message.action?.inputs ?? []) + Metric.top : 0
    
    return height
  }
}

class ActionWebMessageCell: WebPageMessageCell {
  let actionView = ActionView()
  var messageId = ""
  
  struct Metric {
    static let top = 16.f
    static let trailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.onClickFormOption(originId: self?.messageId, key: key, value: value)
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.webView.snp.bottom)!).offset(Metric.top)
      
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.trailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType, presenter: ChatManager?) {
    super.configure(viewModel, presenter: presenter)
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + Metric.top + ActionView.viewHeight(
      fits: width, inputs: viewModel.message.action?.inputs ?? [])
  }
}


class ActionMediaMessageCell: MediaMessageCell {
  let actionView = ActionView()
  var messageId = ""
  
  struct Metric {
    static let top = 16.f
    static let trailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.onClickFormOption(originId: self?.messageId, key: key, value: value)
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.mediaView.snp.bottom)!).offset(Metric.top)
      
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.trailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType, presenter: ChatManager?) {
    super.configure(viewModel, presenter: presenter)
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + Metric.top + ActionView.viewHeight(
      fits: width, inputs: viewModel.message.action?.inputs ?? [])
  }
}


class ActionFileMessageCell: FileMessageCell {
  let actionView = ActionView()
  var messageId = ""
  
  struct Metric {
    static let top = 16.f
    static let trailing = 10.f
  }
  
  override func initialize() {
    super.initialize()
    self.contentView.superview?.clipsToBounds = false
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .subscribe(onNext: { [weak self] (key, value) in
        self?.presenter?.onClickFormOption(originId: self?.messageId, key: key, value: value)
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.fileView.snp.bottom)!).offset(Metric.top)
      
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.trailing)
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType, presenter: ChatManager?) {
    super.configure(viewModel, presenter: presenter)
    self.messageId = viewModel.message.id
    self.actionView.configure(viewModel)
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + Metric.top + ActionView.viewHeight(
      fits: width, inputs: viewModel.message.action?.inputs ?? [])
  }
}


