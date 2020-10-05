//
//  CHButtons.swift
//  ChannelIO
//
//  Created by R3alFr3e on 12/12/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

struct CHButtonFactory {
  static func newChat(
    textColor: UIColor = mainStore.state.plugin.textUIColor,
    backgroundColor: UIColor? = UIColor(mainStore.state.plugin.color),
    borderColor: UIColor? = UIColor(mainStore.state.plugin.borderColor)) -> UIButton {
    let button = UIButton(type: .custom).then {
      $0.setImage(CHAssets.getImage(named: "sendDisabled")?.withRenderingMode(.alwaysTemplate), for: .normal)
      $0.setImage(CHAssets.getImage(named: "sendDisabled")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
      $0.setImage(CHAssets.getImage(named: "newChatDisabled"), for: .disabled)
      $0.setTitle(CHAssets.localized("ch.chat.start_new_chat"), for: .normal)
      
      $0.setTitleColor(textColor, for: .normal)
      $0.setTitleColor(.grey500, for: .disabled)
      $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
      $0.tintColor = textColor
      
      $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
      $0.imageEdgeInsets = UIEdgeInsets(top:0, left: -8, bottom: 0, right: 0)
      
      $0.backgroundColor = backgroundColor
      
      $0.layer.cornerRadius = 23
      
      $0.layer.shadowColor = UIColor.black10.cgColor
      $0.layer.shadowOpacity = 1
      $0.layer.shadowOffset = CGSize(width: 0, height: 4)
      $0.layer.shadowRadius = 6
    }
    
    _ = button.rx.isEnabled
      .subscribe(onNext: { (enabled) in
        button.tintColor = !enabled ? .grey500 : textColor
        button.backgroundColor = !enabled ? .grey200 : backgroundColor
        button.clipsToBounds = !enabled
      })

    _ = button.rx.isHighlighted
      .subscribe(onNext: { (highlight) in
        if highlight {
          button.imageView?.alpha = 0.3
          button.titleLabel?.alpha = 0.3
        }
        else {
          UIView.animate(withDuration: 0.2, animations: {
            button.imageView?.alpha = 1
            button.titleLabel?.alpha = 1
          })
        }
      })
    return button
  }
  
  static func messageAction() -> UIButton {
    return UIButton(type: .system).then {
      $0.setTitleColor(.cobalt400, for: .normal)
      $0.titleLabel?.numberOfLines = 1
      $0.layer.borderWidth = 3.f
      $0.layer.borderColor = UIColor.grey100.cgColor
      $0.layer.cornerRadius = 12.f
      $0.backgroundColor = .white
    }
  }
  
  static func launcher() -> UIButton {
    return UIButton(type: .custom).then {
      $0.layer.cornerRadius = 25.f
      $0.layer.shadowColor = UIColor.black.cgColor
      $0.layer.shadowOpacity = 0.2
      $0.layer.shadowOffset = CGSize(width: 0, height: 3)
      $0.layer.shadowRadius = 5
      //$0.imageEdgeInsets = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
    }
  }
  
  static func dismiss() -> UIButton {
    return UIButton(type: .custom).then {
      $0.setImage(CHAssets.getImage(named: "closeWhite"), for: .normal)
      $0.imageView?.contentMode = .scaleAspectFit
      $0.layer.cornerRadius = 15.f
      $0.clipsToBounds = true
      $0.setBackgroundColor(color: .black50, forUIControlState: .normal)
    }
  }
  
  static func errorRefresh() -> UIButton {
    return UIButton(type: .custom).then {
      $0.setImage(CHAssets.getImage(named: "refreshCell"), for: .normal)
      $0.imageView?.contentMode = .scaleAspectFit
      $0.backgroundColor = .white
      
      $0.layer.cornerRadius = 22.f

      $0.layer.borderColor = UIColor.grey200.cgColor
      $0.layer.borderWidth = 1.f
      $0.layer.shadowColor = UIColor.grey900.cgColor
      $0.layer.shadowOpacity = 0.2
      $0.layer.shadowOffset = CGSize(width: 0, height: 2)
      $0.layer.shadowRadius = 3
    }
  }
}
