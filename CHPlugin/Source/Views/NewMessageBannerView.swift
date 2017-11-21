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

final class NewMessageBannerView : BaseView {
  
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
  
  let newMessageLabel = UILabel().then {
    $0.font = Font.nameLabel
    $0.textColor = Color.nameLabel
    $0.numberOfLines = Constant.nameLabelNumberOfLines
    $0.text = CHAssets.localized("New message")
  }
  
  override func initialize() {
    super.initialize()
    
//    self.layer.borderColor = CHColors.paleSkyBlue.cgColor
//    self.layer.borderWidth = 1
    self.backgroundColor = UIColor.white
    
    self.layer.cornerRadius = 24.f
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOffset = CGSize(width: 0.f, height: 3.f)
    self.layer.shadowRadius = 3.f
    self.layer.shadowOpacity = 0.3
    
    self.addSubview(self.avatarView)
    self.addSubview(self.newMessageLabel)
  }
  
  func configure(message: CHMessage) {
    if let user = message.entity {
      self.avatarView.configure(user)
    }
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.avatarView.snp.remakeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(10)
      make.size.equalTo(CGSize(width: 24, height: 24))
    }
    
    self.newMessageLabel.snp.remakeConstraints { [weak self] (make) in
      make.centerY.equalToSuperview()
      make.leading.equalTo((self?.avatarView.snp.trailing)!).offset(12)
      make.trailing.equalToSuperview().inset(20)
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
