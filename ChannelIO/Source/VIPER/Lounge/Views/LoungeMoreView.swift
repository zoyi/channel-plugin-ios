//
//  LoungeMoreView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 6/12/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

class LoungeMoreView: BaseView {
  private let moreLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 12)
    $0.textColor = CHColors.dark50
  }
  
  override func initialize() {
    super.initialize()
    self.backgroundColor = CHColors.dark10
    self.addSubview(self.moreLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.moreLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(10)
      make.top.equalToSuperview().inset(5)
      make.bottom.equalToSuperview().inset(5)
    }
  }
  
  func configure(moreCount: Int, hasNext: Bool) {
    self.isHidden = moreCount == 0
    let count = moreCount > 99 ? "99" : "\(moreCount)"
    self.moreLabel.text = (hasNext || moreCount > 99) ?
      String(format: CHAssets.localized("ch.lounge.show_previous_chats_more"), count) :
      String(format: CHAssets.localized("ch.lounge.show_previous_chats"), count)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.frame.height / 2
  }
}
