//
//  FollowersView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit

class FollowersView: BaseView {
  let firstFollowerView = AvatarView().then {
    $0.layer.shadowColor = CHColors.dark.cgColor
    $0.layer.shadowOpacity = 0.4
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 4
  }
  let secondFollowerView = AvatarView().then {
    $0.layer.shadowColor = CHColors.dark.cgColor
    $0.layer.shadowOpacity = 0.4
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 4
  }
  let thirdFollowerView = AvatarView().then {
    $0.layer.shadowColor = CHColors.dark.cgColor
    $0.layer.shadowOpacity = 0.4
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 4
  }
  let forthFollowerView = AvatarView().then {
    $0.layer.shadowColor = CHColors.dark.cgColor
    $0.layer.shadowOpacity = 0.4
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 4
  }
  
  var displayedMembers = 0
  
  struct Metric {
    static let sizeForOne = 60
    static let sizeForTwo = 48
    static let sizeForThree = 40
    static let sizeForFour = 40
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.firstFollowerView)
    self.addSubview(self.secondFollowerView)
    self.addSubview(self.thirdFollowerView)
    self.addSubview(self.forthFollowerView)
  }
  
  func resetContraints() {
    self.firstFollowerView.snp.removeConstraints()
    self.secondFollowerView.snp.removeConstraints()
    self.thirdFollowerView.snp.removeConstraints()
    self.forthFollowerView.snp.removeConstraints()
  }
  
  func configure(entities: [CHEntity]) {
    self.resetContraints()
    
    if entities.count == 1 {
      self.configureForOneEntity(entities.first)
    } else if entities.count == 2 {
      self.configureForTwoEntities(entities)
    } else if entities.count == 3 {
      self.configureForThreeEntities(entities)
    } else if entities.count == 4 {
      self.configureForFourEntities(entities)
    }
  }
  
  func configureDefault() {
    self.firstFollowerView.configure(nil)
    self.firstFollowerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.secondFollowerView.configure(nil)
    self.secondFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.leading.equalTo(self.firstFollowerView.snp.trailing).offset(2)
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.thirdFollowerView.configure(nil)
    self.thirdFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
      make.top.equalTo(self.firstFollowerView.snp.bottom).offset(2)
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.forthFollowerView.configure(nil)
    self.forthFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.top.equalTo(self.secondFollowerView.snp.bottom).offset(2)
      make.leading.equalTo(self.thirdFollowerView.snp.trailing).offset(2)
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.firstFollowerView.isHidden = false
    self.secondFollowerView.isHidden = false
    self.thirdFollowerView.isHidden = false
    self.forthFollowerView.isHidden = false
  }
  
  func configureForOneEntity(_ entity: CHEntity?) {
    guard let entity = entity else { return }
    
    self.firstFollowerView.configure(entity)
    self.firstFollowerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
      make.height.equalTo(Metric.sizeForOne)
      make.width.equalTo(Metric.sizeForOne)
    }
    self.firstFollowerView.isHidden = false
    self.secondFollowerView.isHidden = true
    self.thirdFollowerView.isHidden = true
    self.forthFollowerView.isHidden = true
  }
  
  func configureForTwoEntities(_ entities: [CHEntity]) {
    self.firstFollowerView.configure(entities[0])
    self.firstFollowerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(Metric.sizeForTwo)
      make.width.equalTo(Metric.sizeForTwo)
    }
    
    self.secondFollowerView.configure(entities[1])
    self.secondFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalTo(self.firstFollowerView.snp.trailing).offset(2)
      make.height.equalTo(Metric.sizeForTwo)
      make.width.equalTo(Metric.sizeForTwo)
    }
    
    self.firstFollowerView.isHidden = false
    self.secondFollowerView.isHidden = false
    self.thirdFollowerView.isHidden = true
    self.forthFollowerView.isHidden = true
  }
  
  func configureForThreeEntities(_ entities: [CHEntity]) {
    self.firstFollowerView.configure(entities[0])
    self.firstFollowerView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
      make.height.equalTo(Metric.sizeForThree)
      make.width.equalTo(Metric.sizeForThree)
    }
    
    self.secondFollowerView.configure(entities[1])
    self.secondFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
      make.top.equalTo(self.firstFollowerView.snp.bottom).offset(-3)
      make.height.equalTo(Metric.sizeForThree)
      make.width.equalTo(Metric.sizeForThree)
    }
    
    self.thirdFollowerView.configure(entities[2])
    self.thirdFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalTo(self.secondFollowerView.snp.trailing).offset(2)
      make.top.equalTo(self.firstFollowerView.snp.bottom).offset(-3)
      make.height.equalTo(Metric.sizeForThree)
      make.width.equalTo(Metric.sizeForThree)
    }
    
    self.firstFollowerView.isHidden = false
    self.secondFollowerView.isHidden = false
    self.thirdFollowerView.isHidden = false
    self.forthFollowerView.isHidden = true
  }
  
  func configureForFourEntities(_ entities: [CHEntity]) {
    self.firstFollowerView.configure(entities[0])
    self.firstFollowerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.secondFollowerView.configure(entities[1])
    self.secondFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.leading.equalTo(self.firstFollowerView.snp.trailing).offset(2)
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.thirdFollowerView.configure(entities[2])
    self.thirdFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
      make.top.equalTo(self.firstFollowerView.snp.bottom).offset(2)
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.forthFollowerView.configure(entities[3])
    self.forthFollowerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.top.equalTo(self.secondFollowerView.snp.bottom).offset(2)
      make.leading.equalTo(self.thirdFollowerView.snp.trailing).offset(2)
      make.height.equalTo(Metric.sizeForFour)
      make.width.equalTo(Metric.sizeForFour)
    }
    
    self.firstFollowerView.isHidden = false
    self.secondFollowerView.isHidden = false
    self.thirdFollowerView.isHidden = false
    self.forthFollowerView.isHidden = false
  }
}
