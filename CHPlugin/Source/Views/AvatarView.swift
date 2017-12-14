//
//  AvatarView.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 2. 6..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

import ManualLayout

class AvatarView: NeverClearView {

  // MARK: Constants

  struct Metric {
    static let borderWidth = 2.f
  }

  struct Font {
    static let initialLabel = UIFont.boldSystemFont(ofSize: 15)
  }

  struct Color {
    static let initialLabel = CHColors.white
    static let border = CHColors.white.cgColor
  }

  // MARK: Properties

  let initialLabel = UILabel().then {
    $0.font = Font.initialLabel
    $0.textColor = Color.initialLabel
    $0.textAlignment = .center
    $0.layer.masksToBounds = true
  }

  let avatarImageView = UIImageView().then {
    $0.clipsToBounds = true
    $0.backgroundColor = UIColor.white
  }
  
  let onlineView = UIView().then {
    $0.isHidden = true
    $0.layer.borderWidth = 2
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
        self.layer.cornerRadius = newValue ? self.avatarSize / 2 : 0
      }
      
      self.setNeedsLayout()
      self.layoutIfNeeded()
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
  
  // MARK: Initializing

  override func initialize() {
    super.initialize()

    self.addSubview(self.initialLabel)
    self.addSubview(self.avatarImageView)
    self.addSubview(self.onlineView)
  }

  // MARK: Configuring

  func configure(_ avatar: CHEntity) {
    if let url = avatar.avatarUrl, url != "" {
      if url.contains("http") {
        self.avatarImageView.sd_setImage(with: URL(string:url))
      } else {
        self.avatarImageView.image = CHAssets.getImage(named: url)
      }
      self.avatarImageView.isHidden = false
      self.initialLabel.isHidden = true
    } else {
      self.initialLabel.backgroundColor = UIColor(avatar.color)
      self.initialLabel.text = avatar.initial
      self.avatarImageView.isHidden = true
      self.initialLabel.isHidden = false
    }
    
    if let manager = avatar as? CHManager, manager.online && self.showOnline {
      self.onlineView.isHidden = false
    } else {
      self.onlineView.isHidden = true
    }
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.layer.cornerRadius =  !self.showOnline ? self.height / 2 : 0
    
    self.initialLabel.top = 0
    self.initialLabel.left = 0
    self.initialLabel.width = self.width
    self.initialLabel.height = self.height
    self.initialLabel.layer.cornerRadius = self.height / 2
    
    self.avatarImageView.top = 0
    self.avatarImageView.left = 0
    self.avatarImageView.width = self.width
    self.avatarImageView.height = self.height
    self.avatarImageView.layer.cornerRadius = self.height / 2
    
    self.onlineView.bottom = self.avatarImageView.bottom
    self.onlineView.right = self.avatarImageView.right + 2
    self.onlineView.width = 12
    self.onlineView.height = 12
    self.onlineView.layer.cornerRadius = 6
  }
}
