//
//  CHButtons.swift
//  ChannelIO
//
//  Created by R3alFr3e on 12/12/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct CHButton {
  static func newChat() -> UIButton {
    return UIButton(type: .system).then {
      $0.setImage(CHAssets.getImage(named: "newChatPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
      $0.setTitle(CHAssets.localized("ch.chat.start_new_chat"), for: .normal)
      $0.setTitleColor(mainStore.state.plugin.textUIColor, for: .normal)
      $0.tintColor = mainStore.state.plugin.textUIColor
      
      $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 20)
      $0.imageEdgeInsets = UIEdgeInsets(top:0, left: -14, bottom: 0, right: 0)
      
      $0.backgroundColor = UIColor(mainStore.state.plugin.color)
      
      $0.layer.borderColor = UIColor(mainStore.state.plugin.borderColor)?.cgColor
      $0.layer.cornerRadius = 23
      $0.layer.shadowColor = CHColors.dark.cgColor
      $0.layer.shadowOpacity = 0.2
      $0.layer.shadowOffset = CGSize(width: 0, height: 2)
      $0.layer.shadowRadius = 3
      $0.layer.borderWidth = 1
      $0.isHidden = true
    }
  }
  
  static func keepNudge() -> UIButton {
    return UIButton(type: .system).then {
      $0.setTitle("👍 좋아요", for: .normal)
      $0.setTitleColor(CHColors.pumpkinOrange, for: .normal)
      
      $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
      $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 30)
      $0.backgroundColor = .white
      
      $0.layer.cornerRadius = 23
      $0.layer.shadowColor = CHColors.dark.cgColor
      $0.layer.shadowOpacity = 0.2
      $0.layer.shadowOffset = CGSize(width: 0, height: 2)
      $0.layer.shadowRadius = 3
      $0.isHidden = true
    }
  }
  
  static func messageAction() -> UIButton {
    return UIButton(type: .system).then {
      $0.setTitleColor(CHColors.azure, for: .normal)
      $0.titleLabel?.numberOfLines = 1
      $0.layer.borderWidth = 3.f
      $0.layer.borderColor = CHColors.paleGrey.cgColor
      $0.layer.cornerRadius = 12.f
      $0.backgroundColor = .white
    }
  }
  
  static func launcher() -> UIButton {
    return  UIButton(type: .custom).then {
      $0.layer.cornerRadius = 27.f
      $0.layer.shadowColor = UIColor.black.cgColor
      $0.layer.shadowOpacity = 0.3
      $0.layer.shadowOffset = CGSize(width: 0, height: 3)
      $0.layer.shadowRadius = 5
      $0.layer.borderWidth = 1
    }
  }
}
