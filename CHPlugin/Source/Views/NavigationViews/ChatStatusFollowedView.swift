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
  let avatarView = AvatarView().then {
    $0.showBorder = false
    $0.showOnline = true
  }
  
  let managerDescLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.numberOfLines = 1
    //text color depends on plugin color
  }
  
  var bottomContraint: Constraint? = nil
  
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
      self?.bottomContraint = make.bottom.equalToSuperview().inset(20).constraint
    }
  }
  
  func configure(lastTalkedPerson: CHEntity?, channel: CHChannel, plugin: CHPlugin) {
    self.backgroundColor = UIColor(plugin.color)
    
    if let person = lastTalkedPerson {
      self.avatarView.configure(person)
      //if manager.desc == "" {
      //  self.bottomContraint?.deactivate()
      //} else {
      self.bottomContraint?.activate()
      self.bottomContraint?.update(inset: 20)
      //}
    } else {
      self.avatarView.configure(channel)
      self.bottomContraint?.deactivate()
    }
    
    //self.managerDescLabel.text = manager?.desc ?? ""
    self.managerDescLabel.textColor = plugin.textUIColor
  }
  
  static func viewHeight(manager: CHManager?) -> CGFloat {
    return manager?.desc == "" ? 66 : 89
  }
}
