//
//  ChatBannerView.swift
//  ch-desk-ios
//
//  Created by Haeun Chung on 06/07/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class ChatBannerView : BaseView {
  
  struct Font {
    static let messageLabel = UIFont.systemFont(ofSize: 14)
    static let nameLabel = UIFont.boldSystemFont(ofSize: 13)
  }
  
  struct Color {
    static let initialLabel = UIColor.white
    static let messageLabel = CHColors.deepDark
    static let nameLabel = CHColors.deepDark
  }
  
  struct Constant {
    static let titleLabelNumberOfLines = 1
    static let messageLabelNumberOfLines = 1
    static let nameLabelNumberOfLines = 1
  }
  
  let avatarView = AvatarView().then {
    $0.showBorder = false
  }
  
  let messageLabel = UILabel().then {
    $0.font = Font.messageLabel
    $0.textColor = Color.messageLabel
    $0.numberOfLines = Constant.messageLabelNumberOfLines
  }
  
  let nameLabel = UILabel().then {
    $0.font = Font.nameLabel
    $0.textColor = Color.nameLabel
    $0.numberOfLines = Constant.nameLabelNumberOfLines
  }
  
  let goToButton = UIImageView().then {
    $0.image = CHAssets.getImage(named: "chevronDown")
    $0.contentMode = UIViewContentMode.center
  }
  
  override func initialize() {
    super.initialize()
    
    self.backgroundColor = CHColors.iceBlue
    
    self.layer.borderColor = CHColors.paleSkyBlue.cgColor
    self.layer.borderWidth = 1
    
    self.layer.cornerRadius = 5.f
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOffset = CGSize(width: 0.f, height: 4.f)
    self.layer.shadowRadius = 3.f
    self.layer.shadowOpacity = 0.3
    
    self.addSubview(self.avatarView)
    self.addSubview(self.nameLabel)
    self.addSubview(self.messageLabel)
    self.addSubview(self.goToButton)
  }
  
  func configure(message: CHMessage) {
    if let user = message.entity {
      self.avatarView.configure(user)
      self.nameLabel.text = user.name
      self.messageLabel.text = message.message
    }
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.avatarView.snp.remakeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(10)
      make.size.equalTo(CGSize(width: 32, height: 32))
    }
    
    self.nameLabel.snp.remakeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(10)
      make.leading.equalTo((self?.avatarView.snp.trailing)!).offset(8)
    }
    
    self.messageLabel.snp.remakeConstraints { [weak self] (make) in
      make.top.equalTo((self?.nameLabel.snp.bottom)!).offset(2)
      make.leading.equalTo((self?.avatarView.snp.trailing)!).offset(8)
    }
    
    self.goToButton.snp.remakeConstraints { [weak self] (make) in
      make.leading.greaterThanOrEqualTo((self?.nameLabel.snp.trailing)!).offset(8)
      make.leading.greaterThanOrEqualTo((self?.messageLabel.snp.trailing)!).offset(8)
      make.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
  }
  
  func show(animated: Bool) {
    if !self.isHidden {
      return
    }
    
    self.isHidden = false
    if animated {
      self.alpha = 0
      UIView.animate(withDuration: 0.3) { [weak self] in
        self?.alpha = 1
      }
    }
  }
  
  func hide(animated: Bool) {
    if self.isHidden {
      return
    }
    
    if animated {
      self.alpha = 1
      UIView.animate(withDuration: 0.3, animations: { [weak self] in
        self?.alpha = 0
        }, completion: { [weak self] (completed) in
          self?.isHidden = true
      })
    } else {
      self.isHidden = true
    }
  }
  
}
