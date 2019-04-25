//
//  FollowNavigationTitleView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class FollowNavigationView: BaseView {
  let followerAvatarView = NavigationAvatarView()
  let followerNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 17)
    $0.textAlignment = .left
  }
  
  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.followerAvatarView.snp.makeConstraints { (make) in
      make.height.equalTo(24)
      make.width.equalTo(24)
      make.leading.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.followerNameLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(self.followerAvatarView.snp.trailing).offset(3)
      make.top.equalTo(self.followerAvatarView.snp.top).offset(2)
      make.trailing.equalToSuperview()
    }
  }
  
  override var intrinsicContentSize: CGSize {
    return UIView.layoutFittingExpandedSize
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var width = self.followerAvatarView.frame.width
    width += self.followerNameLabel.text?.width(with: UIFont.boldSystemFont(ofSize: 17)) ?? 0
    return CGSize(width: width, height: 24)
  }
}
