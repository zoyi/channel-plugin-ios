//
//  AvatarView.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import SDWebImage

class AvatarView: NeverClearView {

  // MARK: Constants

  struct Metric {
    static let borderWidth = 2.f
  }

  struct Color {
    static let initialLabel = CHColors.white
    static let border = CHColors.white.cgColor
  }

  // MARK: Properties
  let avatarImageView = SDAnimatedImageView().then {
    $0.clipsToBounds = true
    $0.backgroundColor = UIColor.white
    $0.contentMode = .scaleAspectFill
  }
  
  let onlineView = UIView().then {
    $0.isHidden = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.white.cgColor
    $0.backgroundColor = CHColors.shamrockGreen
  }
  
  var avatarSize : CGFloat = 0
  var showOnline : Bool = false {
    didSet {
      if self.showOnline {
        self.clipsToBounds = false
      } else {
        self.clipsToBounds = true
      }
    }
  }
  
  var showBorder : Bool {
    set {
      if self.showOnline {
        self.avatarImageView.layer.borderWidth = newValue ? Metric.borderWidth : 0
      } else {
        self.layer.borderWidth = newValue ? Metric.borderWidth : 0
        if self.isRound {
          self.layer.cornerRadius = newValue ? self.avatarSize / 2 : 0
        }
      }
    }
    get {
      return self.avatarImageView.layer.borderWidth != 0
    }
  }
  
  var borderColor : UIColor? = nil {
    didSet {
      if self.showOnline {
        self.avatarImageView.layer.borderColor = self.borderColor?.cgColor
        self.onlineView.layer.borderColor = self.borderColor?.cgColor
      } else {
        self.layer.borderColor = self.borderColor?.cgColor
      }
    }
  }
  
  var isRound: Bool = true
  
  // MARK: Initializing

  override func initialize() {
    super.initialize()

    self.addSubview(self.avatarImageView)
    self.addSubview(self.onlineView)
    
    self.avatarImageView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.onlineView.layer.cornerRadius = 4
    self.onlineView.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.avatarImageView.snp.bottom)
      make.right.equalTo(self.avatarImageView.snp.right).offset(2)
      make.height.equalTo(8)
      make.width.equalTo(8)
    }
  }

  // MARK: Configuring

  func configure(_ avatar: CHEntity?) {
    guard let avatar = avatar else { return }
    
    if let url = avatar.avatarUrl, url != "" {
      if url.contains("http") {
        self.avatarImageView.sd_setImage(with: URL(string:url))
      } else {
        self.avatarImageView.image = CHAssets.getImage(named: url)
      }
      self.avatarImageView.isHidden = false
    } else {
      self.avatarImageView.isHidden = true
    }
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = !self.showOnline ? self.frame.size.height / 2 : 0
    if isRound {
      self.avatarImageView.layer.cornerRadius = (self.frame.size.height) / 2
    }
  }
}
