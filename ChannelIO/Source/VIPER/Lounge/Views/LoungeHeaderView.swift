//
//  LoungeHeaderView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoungeHeaderView: BaseView {
  let channelNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 22)
    $0.textAlignment = .left
  }
  
  let settingButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.alpha = 0.8
  }
  let dismissButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "exit")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.alpha = 0.8
  }
  
  let dismissOverlayButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "exit"), for: .normal)
  }
  
  let responseLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.alpha = 0.8
  }
  let responseImageView = UIImageView()
  let responseDescriptionLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.alpha = 0.8
  }
  let operationTimeLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.alpha = 0.8
  }
  
  let followersView = FollowersView()
  let bgView = CAGradientLayer().then {
    $0.startPoint = CGPoint(x: 0.5, y: 0.0)
    $0.endPoint = CGPoint(x: 0.5, y: 1.0)
    $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 270)
    $0.locations = [0, 0.33, 0.66, 1]
  }
  
  let triggerPoint:CGFloat = 0.7
  
  var settingSignal = PublishRelay<Any?>()
  var dismissSignal = PublishRelay<Any?>()
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.layer.addSublayer(self.bgView)
    self.addSubview(self.channelNameLabel)
    self.addSubview(self.settingButton)
    self.addSubview(self.dismissButton)
    self.addSubview(self.responseLabel)
    self.addSubview(self.responseImageView)
    self.addSubview(self.responseDescriptionLabel)
    self.addSubview(self.operationTimeLabel)
    self.addSubview(self.followersView)
    
    self.settingButton.signalForClick()
      .bind(to: self.settingSignal)
      .disposed(by: self.disposeBag)
    
    self.dismissButton.signalForClick()
      .bind(to: self.dismissSignal)
      .disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.channelNameLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      if #available(iOS 11.0, *) {
        make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(16)
      } else {
        make.top.equalToSuperview().inset(16)
      }
      make.leading.equalToSuperview().inset(24)
    }
    
    self.settingButton.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(self.channelNameLabel.snp.trailing).offset(10)
      if #available(iOS 11.0, *) {
         make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(7)
      } else {
         make.top.equalToSuperview().inset(7)
      }
     
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
    
    self.dismissButton.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(self.settingButton.snp.trailing).offset(18)
      if #available(iOS 11.0, *) {
        make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(7)
      } else {
        make.top.equalToSuperview().inset(7)
      }
      
      make.trailing.equalToSuperview().inset(12)
      make.height.equalTo(30)
      make.width.equalTo(30)
    }
    
    self.responseLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.channelNameLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(24)
      make.trailing.lessThanOrEqualTo(self.followersView.snp.leading).offset(-10)
    }
    
    self.responseImageView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.height.equalTo(22)
      make.width.equalTo(22)
      make.centerY.equalTo(self.responseLabel.snp.centerY)
      make.leading.equalTo(self.responseLabel.snp.trailing)
      make.trailing.lessThanOrEqualTo(self.followersView).offset(-10)
    }
    
    self.responseDescriptionLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.responseImageView.snp.bottom).offset(2)
      make.leading.equalToSuperview().inset(24)
      make.trailing.lessThanOrEqualTo(self.followersView.snp.leading).offset(-10)
    }
    
    self.operationTimeLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.responseDescriptionLabel.snp.bottom).offset(2)
      make.leading.equalToSuperview().inset(24)
      make.trailing.lessThanOrEqualTo(self.followersView.snp.leading).offset(-10)
    }
    
    self.followersView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.responseLabel.snp.top)
      make.trailing.equalToSuperview().inset(20)
    }
  }
  
  func configure(model: LoungeHeaderViewModel) {
    self.configure(channel: model.chanenl, plugin: model.plugin, followers: model.followers)
  }
  
  func configure(channel: CHChannel, plugin: CHPlugin, followers: [CHEntity]) {
    self.bgView.colors = [
      plugin.bgColor.cgColor,
      plugin.bgColor.cgColor,
      plugin.bgColor.cgColor,
      UIColor.white.cgColor
    ]
    
    self.settingButton.tintColor = plugin.textUIColor
    self.dismissButton.tintColor = plugin.textUIColor
    
    self.channelNameLabel.text = channel.name
    self.channelNameLabel.textColor = plugin.textUIColor
    self.responseDescriptionLabel.textColor = plugin.textUIColor
    self.responseLabel.textColor = plugin.textUIColor
    self.operationTimeLabel.textColor = plugin.textUIColor
    
    if channel.working {
      self.responseImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "\(channel.expectedResponseDelay)W") :
        CHAssets.getImage(named: "\(channel.expectedResponseDelay)B")
      self.responseLabel.text = CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay)")
      self.responseDescriptionLabel.text = CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay).short_description")
      self.operationTimeLabel.text = channel.todayOperationTime ?? ""
      self.followersView.configure(entities: followers)
    } else {
      self.responseImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "offhoursW") :
        CHAssets.getImage(named: "offhoursB")
      
      self.responseLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working")
      self.responseDescriptionLabel.text =  CHAssets.localized("상담 가능한 시간")
      self.operationTimeLabel.text = channel.nextOperationTime ?? ""
      self.followersView.configure(entities: [channel])
    }
  }
  
  func change(with progress: CGFloat) {
    self.alpha = 1 - progress
    if self.alpha >= self.triggerPoint {
      
    } else {
      
    }
  }
}
