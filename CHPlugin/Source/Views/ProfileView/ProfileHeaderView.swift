//
//  ProfileHeaderView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 18/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SnapKit

final class ProfileHeaderView : BaseView {
  
  let channelIconView = UIView().then {
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor("#33152128").cgColor
    $0.layer.cornerRadius = 3
    $0.clipsToBounds = true
  }
  
  let initialLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 16)
    $0.textAlignment = .center
  }
  
  let channelImageView = UIImageView()
  
  let channelNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 18)
    $0.textAlignment = .center
  }
  
  let phoneView = UIView().then {
    $0.backgroundColor = CHColors.dark10
    $0.layer.cornerRadius = 3
    $0.clipsToBounds = true
  }
  
  let phoneImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "phone")
    $0.contentMode = .center
  }
  let phoneLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 14)
  }
  
  var channel: CHChannel? = nil

  override func initialize() {
    super.initialize()
    
    _ = self.phoneView.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
      //call
      let phoneNumber = self?.phoneLabel.text ?? ""
      if let url = URL(string: "tel://\(phoneNumber)") {
        url.open()
      }
    })
    
    self.channelIconView.addSubview(self.initialLabel)
    self.channelIconView.addSubview(self.channelImageView)
    self.addSubview(self.channelIconView)
    
    self.addSubview(self.channelNameLabel)
    self.phoneView.addSubview(self.phoneImageView)
    self.phoneView.addSubview(self.phoneLabel)
    self.addSubview(self.phoneView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    self.initialLabel.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.channelImageView.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.channelIconView.snp.remakeConstraints { (make) in
      make.top.equalToSuperview().inset(18)
      make.centerX.equalToSuperview()
      make.size.equalTo(CGSize(width: 40, height: 40))
    }
    
    self.channelNameLabel.snp.remakeConstraints { [weak self] (make) in
      if self?.channel?.phoneNumber != "" {
        make.bottom.equalTo((self?.phoneView.snp.top)!).offset(-10)
      } else {
        make.bottom.equalToSuperview().inset(24)
      }
      
      make.top.equalTo((self?.channelIconView.snp.bottom)!).offset(12)
      make.centerX.equalToSuperview()
    }
    
    self.phoneImageView.snp.remakeConstraints { (make) in
      make.size.equalTo(CGSize(width: 12, height: 12))
      make.leading.equalToSuperview().inset(8)
      make.centerY.equalToSuperview()
    }
    
    self.phoneLabel.snp.remakeConstraints { [weak self] (make) in
      make.leading.equalTo((self?.phoneImageView.snp.trailing)!).offset(4)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
    
    self.phoneView.snp.remakeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().inset(18)
      make.height.equalTo(28)
    }
  }
  
  func configure(plugin: CHPlugin, channel: CHChannel) {
    self.channel = channel
    
    self.channelIconView.backgroundColor = UIColor(plugin.color)
    self.backgroundColor = UIColor(plugin.borderColor)
   
    if let url = channel.avatarUrl {
      self.channelImageView.isHidden = false
      self.initialLabel.isHidden = true
      self.channelImageView.sd_setImage(with: URL(string: url)!)
    } else {
      self.channelImageView.isHidden = true
      self.initialLabel.isHidden = false
      self.initialLabel.text = channel.initial
      self.initialLabel.textColor =
        plugin.textColor == "white" ?
          CHColors.white : CHColors.black
    }
    
    self.channelNameLabel.text = channel.name
    self.channelNameLabel.textColor =
      plugin.textColor == "white" ?
        CHColors.white : CHColors.black
    
    self.phoneLabel.text = channel.phoneNumber
    self.phoneLabel.textColor =
      plugin.textColor == "white" ?
        CHColors.white : CHColors.black
    self.phoneView.isHidden = channel.phoneNumber == ""
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
  
}
