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
  let actionableView = ActionableMessageView()

  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.actionableView)
    
    self.actionableView.actionView.observeAction()
      .subscribe(onNext: { [weak self] (key) in
      self?.presenter?.sendAction(messageId: "", key: key)
    }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionableView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.textMessageView.snp.bottom)!).offset(20)
      
      make.leading.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(10)
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType, presenter: ChatManager?) {
    super.configure(viewModel, presenter: presenter)
    self.actionableView.configure(viewModel: viewModel)
  }
  
  static func cellHeight(fit width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    if !viewModel.shouldDisplayActions && !viewModel.shouldDisplaySelectedAction {
      return height
    }
    return height + 20.f + ActionableMessageView.viewHeight(fit: width, viewModel: viewModel)
  }
}
