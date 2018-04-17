//
//  ProfileCompletionView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 13/04/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit

class ProfileCompletionView: ProfileInputView, ProfileContentProtocol {
  let contentView = UIView()
  let contentLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = CHColors.dark
  }
  
  let completionImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "complete")
  }
  
  override var inputFieldView: UIView? {
    get {
      return self.contentView
    }
    set {
      self.inputFieldView = contentView
    }
  }
  
  override func initialize() {
    super.initialize()
    
    self.contentView.addSubview(self.contentLabel)
    self.contentView.addSubview(self.completionImageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.contentLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.completionImageView.snp.makeConstraints { [weak self] (make) in
      make.left.greaterThanOrEqualTo((self?.contentLabel.snp.right)!).offset(12)
      make.right.equalToSuperview()
      make.centerY.equalToSuperview()
      make.height.equalTo(24)
      make.width.equalTo(24)
    }
  }
  
  override func configure(model: MessageCellModelType, index: Int?, presenter: ChatManager?) {
    super.configure(model: model, index: index, presenter: presenter)
    self.indexLabel.isHidden = true
    if let index = index, let value = model.profileItems[index].value {
      self.contentLabel.text = "\(value)"
    }
  }
}
