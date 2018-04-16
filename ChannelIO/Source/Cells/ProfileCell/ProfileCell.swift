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

protocol ProfileInputProtocol: class {
  var view: UIView { get }
}

extension ProfileInputProtocol where Self: UIView {
  var view: UIView { return self }
}

protocol ProfileContentProtocol: class {
  var view: UIView { get }
}

extension ProfileContentProtocol where Self: UIView {
  var view: UIView { return self }
}

enum ProfileInputType {
  case text
  case email
  case mobileNumber
}


class ProfileCell : MessageCell {
  let profileExtendableView = ProfileExtendableView()

  override func initialize() {
    super.initialize()
    
    self.contentView.addSubview(self.profileExtendableView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.profileExtendableView.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.textMessageView.snp.bottom)!).offset(20)
      make.left.equalToSuperview().inset(26)
      make.right.equalToSuperview().inset(26)
      make.bottom.equalToSuperview().inset(5)
    }
  }
  
  func configure(model: MessageCellModelType) {
    super.configure(model)
    self.profileExtendableView.configure(model: model)
  }
  
  class func cellHeight(fit width: CGFloat, model: MessageCellModelType) -> CGFloat {
    let height = MessageCell.cellHeight(fits: width, viewModel: model) + 20
    return height + ProfileExtendableView.viewHeight(model: model)
  }
}
