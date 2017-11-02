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
  }

  let avatarImageView = UIImageView()
  
  var showBorder : Bool {
    set {
      self.layer.borderWidth = newValue ? Metric.borderWidth : 0
      self.setNeedsLayout()
      self.layoutIfNeeded()
    }
    get {
      return self.layer.borderWidth != 0
    }
  }
  
  // MARK: Initializing

  override func initialize() {
    super.initialize()
    self.clipsToBounds = true
    self.layer.borderWidth = Metric.borderWidth
    self.layer.borderColor = Color.border
    self.addSubview(self.initialLabel)
    self.addSubview(self.avatarImageView)
  }

  // MARK: Configuring

  func configure(_ avatar: CHEntity) {
    if let url = avatar.avatarUrl {
      if url.contains("http") {
        self.avatarImageView.sd_setImage(with: URL(string:url))
      } else {
        self.avatarImageView.image = CHAssets.getImage(named: url)
      }
      
      self.avatarImageView.isHidden = false
      self.initialLabel.isHidden = true
    } else {
      self.backgroundColor = UIColor(avatar.color)
      self.initialLabel.text = avatar.initial
      self.avatarImageView.isHidden = true
      self.initialLabel.isHidden = false
    }
  }

  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.layer.cornerRadius = self.height / 2

    self.initialLabel.sizeToFit()
    self.initialLabel.centerX = self.width / 2
    self.initialLabel.centerY = self.height / 2

    self.avatarImageView.top = 0
    self.avatarImageView.left = 0
    self.avatarImageView.width = self.width
    self.avatarImageView.height = self.height
  }
}
