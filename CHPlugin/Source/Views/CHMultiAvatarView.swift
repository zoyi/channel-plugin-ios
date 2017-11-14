//
//  CHMultiAvatarView.swift
//  CHPlugin
//
//  Created by R3alFr3e on 11/14/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

class CHMultiAvatarView: BaseView {
  let firstAvatarView = AvatarView().then {
    $0.showBorder = false
  }
  let secondAvatarView = AvatarView().then {
    $0.showBorder = false
  }
  let thirdAvatarView = AvatarView().then {
    $0.showBorder = false
  }
  
  var persons = [CHEntity]()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.thirdAvatarView)
    self.addSubview(self.secondAvatarView)
    self.addSubview(self.firstAvatarView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.firstAvatarView.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width:22, height:22))
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.secondAvatarView.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width:22, height:22))
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview().inset(18)
    }
    
    self.thirdAvatarView.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width:22, height:22))
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview().inset(36)
    }
  }
  
  func configure(persons: [CHEntity]) {
    guard self.isIdentical(persons: persons) == false else { return }
    
    if persons.count == 1 {
      self.firstAvatarView.configure(persons[0])
      self.layoutOneAvatar()
    } else if persons.count == 2 {
      self.firstAvatarView.configure(persons[0])
      self.secondAvatarView.configure(persons[1])
      self.layoutTwoAvatars()
    } else if persons.count == 3 {
      self.firstAvatarView.configure(persons[0])
      self.secondAvatarView.configure(persons[1])
      self.thirdAvatarView.configure(persons[2])
      self.layoutThreeAvatars()
    } else {
      self.firstAvatarView.configure(persons[0])
      self.secondAvatarView.configure(persons[1])
      self.layoutTwoAvatars()
    }
  }
  
  func isIdentical(persons: [CHEntity]) -> Bool {
    for person in persons {
      if self.persons.index(where: { (p) in
        return p.avatarUrl == person.avatarUrl && p.name == person.name
      }) != nil {
        continue
      } else {
        return false
      }
    }
    
    return true
  }
  
  func layoutOneAvatar() {
    AnimationSequence(withStepDuration: 0.2).doStep { [weak self] in
      self?.firstAvatarView.alpha = 1
    }.execute()

    if self.secondAvatarView.alpha == 1 {
      AnimationSequence(withStepDuration: 0.2).doStep { [weak self] in
        self?.secondAvatarView.alpha = 0
      }.execute()
    }

    if self.thirdAvatarView.alpha == 1 {
      AnimationSequence(withStepDuration: 0.2).doStep { [weak self] in
        self?.thirdAvatarView.alpha = 0
      }.execute()
    }
  }

  func layoutTwoAvatars() {
    if self.secondAvatarView.alpha == 0 {
      AnimationSequence(withStepDuration: 0.2).doStep { [weak self] in
        self?.secondAvatarView.alpha = 1
      }.execute()
    }

    if self.thirdAvatarView.alpha == 1 {
      AnimationSequence(withStepDuration: 0.2).doStep { [weak self] in
        self?.thirdAvatarView.alpha = 0
      }.execute()
    }
  }

  func layoutThreeAvatars() {
    if self.secondAvatarView.alpha == 0 {
      let seq = AnimationSequence(withStepDuration: 0.4)
      seq.doStep { [weak self] in
        self?.secondAvatarView.alpha = 1
        }
        .doStep { [weak self] in
          self?.thirdAvatarView.alpha = 1
        }.execute()
    }
  }
}
