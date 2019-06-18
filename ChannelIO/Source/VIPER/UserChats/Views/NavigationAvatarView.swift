//
//  NavigationAvatarView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

class NavigationAvatarView: NeverClearView {
  
  // MARK: Properties
  
  let avatarImageView = UIImageView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 12
    $0.backgroundColor = UIColor.white
  }
  
  let onlineView = UIView().then {
    $0.layer.borderWidth = 1
    $0.layer.cornerRadius = 4.5
    $0.layer.borderColor = UIColor.white.cgColor
    $0.backgroundColor = CHColors.blueyGrey
    
  }

  // MARK: Initializing
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.avatarImageView)
    self.addSubview(self.onlineView)
    
    self.avatarImageView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.onlineView.layer.cornerRadius = 6
    self.onlineView.snp.makeConstraints { [weak self] (make) in
      make.bottom.equalTo((self?.avatarImageView.snp.bottom)!)
      make.right.equalTo((self?.avatarImageView.snp.right)!).offset(2)
      make.height.equalTo(9)
      make.width.equalTo(9)
    }
  }
  
  // MARK: Configuring
  
  func configure(_ avatar: CHManager?) {
    guard let avatar = avatar else { return }
    
    if let url = avatar.avatarUrl, url != "" {
      if url.contains("http") {
        self.avatarImageView.sd_setImage(with: URL(string:url))
      } else {
        self.avatarImageView.image = CHAssets.getImage(named: url)
      }
      self.avatarImageView.isHidden = false
    }
    
    self.onlineView.backgroundColor = avatar.online ? CHColors.shamrockGreen : CHColors.blueyGrey
  }
}
