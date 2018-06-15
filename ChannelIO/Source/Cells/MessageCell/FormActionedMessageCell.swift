//
//  FormActionedMessageCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 11/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class FormActionedMessageCell: MessageCell {
  let actionedMessageView = TextMessageView()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.actionedMessageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionedMessageView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.textMessageView.snp.bottom)!).offset(16)
      make.leading.greaterThanOrEqualToSuperview().inset(65)
      make.trailing.equalToSuperview().inset(10)
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType) {
    super.configure(viewModel)
    self.actionedMessageView.configure(viewModel, text: viewModel.selectedActionText)
    self.actionedMessageView.updateConstraints()
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    let bubbleMaxWidth = width - Metric.messageCellMinMargin - Metric.cellRightPadding
    return height + 16.f + TextMessageView.viewHeight(fits: bubbleMaxWidth, text: viewModel.selectedActionText)
  }
}
