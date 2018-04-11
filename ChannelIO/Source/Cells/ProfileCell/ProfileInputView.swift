//
//  ProfileInputView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ProfileInputView: BaseView {
  let titleLabel = UILabel()
  let indexLabel = UILabel()
  var profileInputView: ProfileContentProtocol?
  let optionalFooterLabel = UILabel()
  
  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.titleLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(12)
      make.left.equalToSuperview().inset(14)
    }
    
    self.indexLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(12)
      make.left.equalTo((self?.titleLabel.snp.right)!).offset(10)
      make.right.equalToSuperview().inset(14)
    }

    self.profileInputView?.view.snp.makeConstraints({ (make) in
      make.left.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(12)
      make.top.equalToSuperview().inset(34)
      make.bottom.equalToSuperview().inset(12)
      make.height.equalTo(44)
    })
    
    self.optionalFooterLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.profileInputView?.view.snp.bottom)!).offset(12)
      make.left.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(12)
      make.bottom.equalToSuperview().inset(12)
    }
  }
  
  func configure(model: ProfileCellModelType) {
    
  }
  
  class func viewHeight() -> CGFloat {
    return 80.0 // 118 if extended
  }
}
