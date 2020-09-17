//
//  NavigationTitleView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 23/11/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit
import RxSwift

class ChatNavigationTitleView : BaseView {
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 17)
    $0.numberOfLines = 1
  }
  
  let statusImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named:"fastW")
    $0.contentMode = .center
  }
  
  let subtitleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.numberOfLines = 1
    $0.alpha = 0.7
  }

  let disposeBag = DisposeBag()

  override func initialize() {
    super.initialize()

    self.addSubview(self.statusImageView)
    self.addSubview(self.titleLabel)
    self.addSubview(self.subtitleLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.statusImageView.snp.makeConstraints { [weak self] (make) in
      make.leading.equalTo((self?.titleLabel.snp.trailing)!)
      make.trailing.lessThanOrEqualToSuperview().inset(5)
      make.centerY.equalTo((self?.titleLabel.snp.centerY)!)
      make.height.equalTo(22)
      make.width.equalTo(22)
    }
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(5)
      make.leading.equalToSuperview()
    }
    
    self.subtitleLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.titleLabel.snp.bottom)!)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  func configure(channel: CHChannel, plugin: CHPlugin) {
    self.titleLabel.textColor = plugin.textUIColor
    self.subtitleLabel.textColor = plugin.textUIColor
    
    if !channel.working {
      self.configureForOff(channel: channel, plugin: plugin)
    } else {
      self.configureForReady(channel: channel, plugin: plugin)
    }
  }
  
  fileprivate func configureForOff(channel: CHChannel, plugin: CHPlugin) {
    self.titleLabel.fadeTransition(0.4)
    self.titleLabel.text = channel.name
    self.subtitleLabel.isHidden = false
    
    if let (_, timeLeft) = channel.closestWorkingTime(from: Date()) {
      self.subtitleLabel.text = timeLeft > 60 ?
        String(format: CHAssets.localized("ch.navigation.next_operation.hour_left"), timeLeft / 60) :
        String(format: CHAssets.localized("ch.navigation.next_operation.minutes_left"), max(1, timeLeft))
    } else {
      self.subtitleLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working.short_description")
    }
    
    self.statusImageView.image = plugin.textColor == "white" ?
      CHAssets.getImage(named: "offhoursW") :
      CHAssets.getImage(named: "offhoursB")
    self.statusImageView.isHidden = false
  }
  
  fileprivate func configureForReady(channel: CHChannel, plugin: CHPlugin){
    self.titleLabel.fadeTransition(0.4)
    self.titleLabel.text = channel.name
    self.statusImageView.isHidden = false
    self.statusImageView.image = plugin.textColor == "white" ?
      CHAssets.getImage(named: "\(channel.expectedResponseDelay)W") :
      CHAssets.getImage(named: "\(channel.expectedResponseDelay)B")
    
    self.subtitleLabel.text = CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay).short_description")
    self.subtitleLabel.isHidden = false
  }
  
  override var intrinsicContentSize: CGSize {
    //is there a way to calculate its max width more proper way other than magic number?
    let width = UIScreen.main.bounds.width - 120
    return CGSize(width: width, height: 44)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let width = UIScreen.main.bounds.width - 120
    return CGSize(width: width, height: 44)
  }
}

class ChatNavigationFollowingTitleView : BaseView {
  let hostView = AvatarView()
  let hostNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 17)
  }
  
  let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.hostView)
    self.addSubview(self.hostNameLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.hostView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(-5)
      make.centerY.equalToSuperview()
      make.height.equalTo(24)
      make.width.equalTo(24)
    }
    
    self.hostNameLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(self.hostView.snp.trailing).offset(5)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  func configure(host: CHEntity, plugin: CHPlugin) {
    self.hostView.configure(host)
    self.hostNameLabel.text = host.name
    self.hostNameLabel.textColor = plugin.textUIColor
  }
  
  override var intrinsicContentSize: CGSize {
    let width = UIScreen.main.bounds.width - 120
    return CGSize(width: width, height: 44)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let width = UIScreen.main.bounds.width - 120
    return CGSize(width: width, height: 44)
  }
}
