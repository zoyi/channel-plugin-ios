//
//  UserChatBottomBlockView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 24/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

class UserChatBottomBlockView: BaseView {
  struct Metric {
    static let sideMargin = 20.f
    static let topMargin = 12.f
  }
  
  let messageLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.numberOfLines = 0
    $0.textColor = CHColors.blueyGrey
  }
  
  let topBorder = UIView().then {
    $0.backgroundColor = CHColors.dark10
  }
  
  override func initialize() {
    super.initialize()
    self.backgroundColor = CHColors.paleGrey30
    self.addSubview(self.topBorder)
    self.addSubview(self.messageLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.topBorder.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
    
    self.messageLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metric.sideMargin)
      make.top.equalToSuperview().inset(Metric.topMargin)
      make.bottom.equalToSuperview().inset(Metric.topMargin)
      make.trailing.equalToSuperview().inset(Metric.sideMargin)
    }
  }
  
  func configure(message: String) {
    self.messageLabel.attributedText = message.addLineHeight(
      height: 18,
      font: UIFont.systemFont(ofSize: 14),
      color: CHColors.blueyGrey
    )
  }
  
  func viewHeight() -> CGFloat {
    var height = 0.f
    height += self.messageLabel.attributedText?.height(
      fits: UIScreen.main.bounds.width - Metric.sideMargin * 2
    ) ?? 0
    return Metric.topMargin * 2 + height
  }
}
