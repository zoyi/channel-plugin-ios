//
//  ProfileCell.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit
import Reusable
import SnapKit

class ProfileCell : MessageCell {
  let profileExtendableView = ProfileExtendableView()
  
  override func initialize() {
    super.initialize()
    
    self.contentView.addSubview(self.profileExtendableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.profileExtendableView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.textMessageView.snp.bottom)!).offset(3)
      make.left.equalToSuperview().inset(26)
      make.right.equalToSuperview().inset(26)
      make.bottom.equalToSuperview()
    }
  }
  
  func configure(model: ProfileCellModelType) {
    super.configure(model)
    self.profileExtendableView.configure(model: model)
  }
  
  class func cellHeight(model: ProfileCellModelType) -> CGFloat {
    return ProfileExtendableView.viewHeight(model: model)
  }
}
