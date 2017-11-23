//
//  ChatStatusFollowedView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 23/11/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit
import SnapKit

class ChatStatusFollowedView : BaseView {
  let avatarView = AvatarView()
  let managerDescLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.numberOfLines = 1
    //text color depends on plugin color
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.avatarView)
    self.addSubview(self.managerDescLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.avatarView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.height.equalTo(44)
      make.width.equalTo(44)
      make.centerX.equalToSuperview()
    }
    
    self.managerDescLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.avatarView.snp.bottom)!).offset(7)
      make.centerX.equalToSuperview()
      make.leading.equalToSuperview().inset(30)
      make.trailing.equalToSuperview().inset(30)
      make.bottom.equalToSuperview().inset(20)
    }
  }
  
  func configure(manager: CHManager, plugin: CHPlugin) {
    self.avatarView.configure(manager)
    self.managerDescLabel.text = "매니저 디스크립션"
    self.managerDescLabel.textColor = plugin.textUIColor
  }
  
  static func viewHeight(data: Any) -> CGFloat {
    return 94.0
  }
}
