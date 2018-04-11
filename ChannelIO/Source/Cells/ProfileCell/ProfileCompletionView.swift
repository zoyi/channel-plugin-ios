//
//  ProfileCompletionView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 13/04/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit

class ProfileCompletionView: BaseView, ProfileContentProtocol {
  let contentLabel = UILabel()
  let completionImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "complete")
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.contentLabel)
    self.addSubview(self.completionImageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.contentLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().inset(14)
      make.centerY.equalToSuperview()
    }
    
    self.completionImageView.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.contentLabel.snp.right)!).offset(12)
      make.right.equalToSuperview().inset(14)
      make.centerY.equalToSuperview()
      make.height.equalTo(24)
      make.width.equalTo(24)
    }
  }
  
  func configure(text: String) {
    self.contentLabel.text = text
  }
}
