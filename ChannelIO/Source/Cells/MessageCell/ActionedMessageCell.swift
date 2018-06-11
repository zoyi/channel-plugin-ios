//
//  ActionedMessageCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 11/06/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

class ActionedMessageCell: MessageCell {
  let actionedMessageView = TextMessageView()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.actionedMessageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.actionedMessageView.snp.makeConstraints { (make) in
      
    }
  }
  
  override func configure(_ viewModel: MessageCellModelType) {
    super.configure(viewModel)
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    let height = super.cellHeight(fits: width, viewModel: viewModel)
    return height + 20 + viewModel.selectedActionText.height(fits: width, font: UIFont.systemFont(ofSize: 15))
  }
}
