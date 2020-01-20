//
//  ButtonsMessageCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 07/12/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class ButtonsMessageCell: MessageCell {
  let buttonView = ButtonsMessageView()
  
  var rightConstraint: Constraint? = nil
  var leftConstraint: Constraint? = nil
  
  var topConstraint: Constraint? = nil
  var topToTimeConstraint: Constraint? = nil
  var topToTextConstraint: Constraint? = nil
  
  override func initialize() {
    super.initialize()
    self.contentView.addSubview(self.buttonView)
    
    self.buttonView.observeClickEvents()
      .subscribe(onNext: { [weak self] (url) in
        self?.presenter?.didClickOnRedirectUrl(with: url)
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.buttonView.snp.makeConstraints { (make) in
      self.topConstraint = make.top.equalToSuperview().inset(5).priority(850).constraint
      self.topToTimeConstraint = make.top.equalTo(self.timestampLabel.snp.bottom).offset(3).priority(750).constraint
      self.topToTextConstraint = make.top.equalTo(self.textBlocksView.snp.bottom).offset(3).constraint
      self.rightConstraint = make.right.equalToSuperview().inset(Metric.messageRightMinMargin).constraint
      self.leftConstraint = make.left.equalToSuperview().inset(Metric.bubbleLeftMargin).constraint
      make.bottom.equalToSuperview()
    }
  }
  
  override func configure(
    _ viewModel: MessageCellModelType,
    dataSource: (UITableViewDataSource & UITableViewDelegate),
    presenter: UserChatPresenterProtocol? = nil,
    row: Int = 0) {
    super.configure(viewModel, dataSource: dataSource, presenter: presenter, row: row)
    self.buttonView.configure(model: viewModel)
  }
  
  override class func cellHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    var height = super.cellHeight(fits: width, viewModel: viewModel)
    height += 5 + ButtonsMessageView.viewHeight(fits: width, viewModel: viewModel)
    return height
  }
}
