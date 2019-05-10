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
  let contentView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  let infoContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  let textContainerView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  let channelNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 22)
    $0.textAlignment = .left
  }
  
  let settingButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "settings")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.alpha = 0.8
  }
  let dismissButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "closeWhite")?.withRenderingMode(.alwaysTemplate), for: .normal)
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
    $0.text = CHAssets.localized("ch.out_of_work.confirm")
    $0.alpha = 0.8
    $0.isHidden = true
  }
  
  let helpImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "clock")?.withRenderingMode(.alwaysTemplate)
    $0.isHidden = true
    $0.alpha = 0.8
  }
  
  let followersView = FollowersView()
  let offlineImageView = CHView.gradientImageView(
    named: "moon",
    colors: [
      CHColors.yellowishOrange,
      CHColors.yellowishOrange.withAlphaComponent(0.8)
    ],
    startPoint: .top,
    endPoint: .bottom).then {
      $0.dropShadow(
        with: CHColors.dark,
        opacity: 0.4,
        offset: CGSize(width: 0, height: 4),
        radius: 4)
    }
  
  let bgView = CAGradientLayer().then {
    $0.startPoint = CAGradientLayer.Point.topLeft.value
    $0.endPoint = CAGradientLayer.Point.bottomRight.value
    $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 306)
  }
  
  let bottomBgView = CAGradientLayer().then {
    $0.startPoint = CAGradientLayer.Point.bottom.value
    $0.endPoint = CAGradientLayer.Point.top.value
    $0.frame = CGRect(x: 0, y: 206, width: UIScreen.main.bounds.width, height: 100)
    $0.colors = [CHColors.paleGreyFour.cgColor, CHColors.paleGreyFour0.cgColor]
  }
  
  let triggerPoint:CGFloat = 0.7
  
  var settingSignal = PublishRelay<Any?>()
  var dismissSignal = PublishRelay<Any?>()
  var helpSignal = PublishRelay<Any?>()
  
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.layer.addSublayer(self.bgView)
    self.layer.addSublayer(self.bottomBgView)
    
    self.addSubview(self.contentView)
    self.contentView.addSubview(self.channelNameLabel)
    self.contentView.addSubview(self.settingButton)
    self.contentView.addSubview(self.dismissButton)
    
    self.infoContainerView.addSubview(self.textContainerView)
    self.textContainerView.addSubview(self.responseLabel)
    self.textContainerView.addSubview(self.responseImageView)
    self.textContainerView.addSubview(self.responseDescriptionLabel)
    self.textContainerView.addSubview(self.operationTimeLabel)
    self.textContainerView.addSubview(self.helpImageView)
    
    self.addSubview(self.infoContainerView)
    self.infoContainerView.addSubview(self.followersView)
    self.infoContainerView.addSubview(self.offlineImageView)
    
    self.settingButton.signalForClick()
      .bind(to: self.settingSignal)
      .disposed(by: self.disposeBag)
    
    self.dismissButton.signalForClick()
      .bind(to: self.dismissSignal)
      .disposed(by: self.disposeBag)
    
    self.helpImageView.signalForClick()
      .bind(to: self.helpSignal)
      .disposed(by: self.disposeBag)
    
    self.operationTimeLabel.signalForClick()
      .bind(to: self.helpSignal)
      .disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.contentView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
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
    
    self.infoContainerView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalToSuperview()
      make.top.equalTo(self.channelNameLabel.snp.bottom).offset(6)
      make.trailing.equalToSuperview()
      make.height.equalTo(80)
    }
    
    self.textContainerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    self.responseLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.responseImageView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.height.equalTo(22)
      make.width.equalTo(22)
      make.centerY.equalTo(self.responseLabel.snp.centerY)
      make.leading.equalTo(self.responseLabel.snp.trailing)
    }
    
    self.responseDescriptionLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.responseImageView.snp.bottom).offset(2)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    self.operationTimeLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.top.equalTo(self.responseDescriptionLabel.snp.bottom).offset(2)
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.helpImageView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalTo(self.operationTimeLabel.snp.centerY)
      make.leading.equalTo(self.operationTimeLabel.snp.trailing).offset(5)
      make.trailing.lessThanOrEqualToSuperview()
      make.height.equalTo(15)
      make.width.equalTo(15)
    }
    
    self.followersView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalToSuperview()
      make.leading.equalTo(self.textContainerView.snp.trailing).offset(10)
      make.trailing.equalToSuperview().inset(20)
    }
    
    self.offlineImageView.snp.makeConstraints { (make) in
      make.height.equalTo(60)
      make.width.equalTo(60)
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalToSuperview()
    }
  }
  
  override func displayError() {
    let plugin = mainStore.state.plugin
    let channel = mainStore.state.channel
    
    self.bgView.colors = plugin.gradientColors
    self.settingButton.tintColor = plugin.textUIColor
    self.dismissButton.tintColor = plugin.textUIColor
    self.channelNameLabel.text = channel.name
    self.channelNameLabel.textColor = plugin.textUIColor
    
    self.setVisibilityForComponents(hidden: true)
    self.followersView.configureDefault()
  }
  
  func configure(model: LoungeHeaderViewModel) {
    self.configure(channel: model.chanenl, plugin: model.plugin, followers: model.followers)
  }
  
  func configure(channel: CHChannel, plugin: CHPlugin, followers: [CHEntity]) {
    self.bgView.colors = plugin.gradientColors
    
    self.settingButton.tintColor = plugin.textUIColor
    self.dismissButton.tintColor = plugin.textUIColor
    self.helpImageView.tintColor = plugin.textUIColor
    
    self.setVisibilityForComponents(hidden: false)
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
      self.followersView.configure(entities: followers)
      self.followersView.isHidden = false
      self.offlineImageView.isHidden = true
    } else {
      self.responseImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "offhoursW") :
        CHAssets.getImage(named: "offhoursB")
      
      self.responseLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working")
      self.responseDescriptionLabel.text =  CHAssets.localized("ch.lounge.header.available_time")
      self.followersView.isHidden = true
      self.offlineImageView.isHidden = false
    }
  }
  
  func change(with progress: CGFloat) {
    self.contentView.alpha = progress
  }
  
  func setVisibilityForComponents(hidden: Bool) {
    self.channelNameLabel.isHidden = hidden
    self.channelNameLabel.isHidden = hidden
    self.responseDescriptionLabel.isHidden = hidden
    self.responseLabel.isHidden = hidden
    self.operationTimeLabel.isHidden = hidden
    self.responseImageView.isHidden = hidden
    self.helpImageView.isHidden = hidden
  }
}
