//
//  ActionableMessageCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class ActionableMessageCell: MessageCell {
  let actionView = ActionView()
  var messageId = ""
  
  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.actionView)
    
    self.actionView.observeAction()
      .subscribe(onNext: { [weak self] (key) in
      self?.presenter?.sendAction(messageId: self?.messageId, key: key)
    }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.textMessageView.snp.bottom)!).offset(16)
      
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview().inset(10)
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
    if !viewModel.shouldDisplayActions && !viewModel.shouldDisplaySelectedAction {
      return height
    }
    return height + 16.f + ActionView.viewHeight(fits: width, inputs: viewModel.message.form?.inputs ?? [])
  }
}
