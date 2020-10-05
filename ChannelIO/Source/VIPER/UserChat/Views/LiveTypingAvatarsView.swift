//
//  CHMultiAvatarView.swift
//  CHPlugin
//
//  Created by R3alFr3e on 11/14/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

class LiveTypingAvatarsView: BaseView {
  let firstAvatarView = AvatarView().then {
    $0.showBorder = false
    $0.showOnline = false
    $0.avatarImageView.layer.borderColor = UIColor(mainStore.state.plugin.color)?.cgColor
    $0.alpha = 0
  }
  let secondAvatarView = AvatarView().then {
    $0.showBorder = false
    $0.showOnline = false
    $0.avatarImageView.layer.borderColor = UIColor(mainStore.state.plugin.color)?.cgColor
    $0.alpha = 0
  }
  let thirdAvatarView = AvatarView().then {
    $0.showBorder = false
    $0.showOnline = false
    $0.avatarImageView.layer.borderColor = UIColor(mainStore.state.plugin.color)?.cgColor
    $0.alpha = 0
  }
  
  var persons = [CHEntity]()
  
  var avatarSize: CGFloat = 22
  var coverMargin: CGFloat = 0
  
  var firstTrailingContraint: Constraint? = nil
  var secondLeadingConstraint: Constraint? = nil
  var secondTrailingContraint: Constraint? = nil
  var thirdLeadingConstraint: Constraint? = nil
  var widthConstraint: Constraint? = nil
  
  //add property to reuse 
  init(avatarSize: CGFloat = 0, coverMargin: CGFloat = 0) {
    self.avatarSize = avatarSize
    self.coverMargin = coverMargin
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.thirdAvatarView)
    self.addSubview(self.secondAvatarView)
    self.addSubview(self.firstAvatarView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.firstAvatarView.snp.remakeConstraints { (make) in
      make.height.width.equalTo(self.avatarSize)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      self.firstTrailingContraint = make.trailing.equalToSuperview().constraint
    }

    self.secondAvatarView.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width:self.avatarSize, height:self.avatarSize))
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      self.secondTrailingContraint = make.trailing.equalToSuperview().constraint
      self.secondLeadingConstraint = make.leading.equalToSuperview()
        .inset(self.avatarSize - self.coverMargin).priority(750).constraint
    }

    self.thirdAvatarView.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width:self.avatarSize, height:self.avatarSize))
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.trailing.equalToSuperview()
      self.thirdLeadingConstraint = make.leading.equalToSuperview()
        .inset(self.avatarSize * 2 - self.coverMargin * 2).constraint
      self.thirdLeadingConstraint?.deactivate()
    }
  }
  
  func configure(persons: [CHEntity]) {
    self.persons = persons
    
    //self.widthConstraint?.deactivate()
    
    if persons.count == 1 {
      self.firstAvatarView.configure(persons[0])
      self.firstTrailingContraint?.activate()
      self.secondLeadingConstraint?.deactivate()
      self.secondTrailingContraint?.activate()
      self.thirdLeadingConstraint?.deactivate()
      self.layoutOneAvatar()
    } else if persons.count == 2 {
      self.firstAvatarView.configure(persons[0])
      self.secondAvatarView.configure(persons[1])
      self.firstTrailingContraint?.deactivate()
      self.secondLeadingConstraint?.activate()
      self.secondTrailingContraint?.activate()
      self.thirdLeadingConstraint?.deactivate()
      self.layoutTwoAvatars()
    } else if persons.count == 3 {
      self.firstAvatarView.configure(persons[0])
      self.secondAvatarView.configure(persons[1])
      self.thirdAvatarView.configure(persons[2])
      self.firstTrailingContraint?.deactivate()
      self.secondLeadingConstraint?.activate()
      self.secondTrailingContraint?.deactivate()
      self.thirdLeadingConstraint?.activate()
      self.layoutThreeAvatars()
    } else if persons.count >= 4{
      self.firstAvatarView.configure(persons[0])
      self.secondAvatarView.configure(persons[1])
      self.firstTrailingContraint?.deactivate()
      self.secondLeadingConstraint?.activate()
      self.secondTrailingContraint?.activate()
      self.thirdLeadingConstraint?.deactivate()
      self.layoutTwoAvatars()
    } else {
      //self.widthConstraint?.activate()
      self.firstAvatarView.alpha = 0
      self.secondAvatarView.alpha = 0
      self.thirdAvatarView.alpha = 0
    }
  }
  
  func layoutOneAvatar() {
    self.firstAvatarView.alpha = 1
    self.secondAvatarView.alpha = 0
    self.thirdAvatarView.alpha = 0
  }

  func layoutTwoAvatars() {
    self.firstAvatarView.alpha = 1
    self.secondAvatarView.alpha = 1
    self.thirdAvatarView.alpha = 0
  }

  func layoutThreeAvatars() {
    self.firstAvatarView.alpha = 1
    self.secondAvatarView.alpha = 1
    self.thirdAvatarView.alpha = 1
  }
}
