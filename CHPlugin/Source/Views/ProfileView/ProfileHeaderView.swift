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
  
  let contactViews = ContactsView()
  
  
  var channel: CHChannel? = nil

  override func initialize() {
    super.initialize()
    
    self.contactViews.buttonSize = 46
    
    self.channelIconView.addSubview(self.initialLabel)
    self.channelIconView.addSubview(self.channelImageView)
    self.addSubview(self.channelIconView)
    self.addSubview(self.contactViews)
    self.addSubview(self.channelNameLabel)

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
      make.top.equalTo((self?.channelIconView.snp.bottom)!).offset(12)
      make.centerX.equalToSuperview()
    }
    
    self.contactViews.snp.makeConstraints { [weak self] (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo((self?.channelNameLabel.snp.bottom)!).offset(16)
      make.bottom.equalToSuperview().inset(28)
    }
  }
  
  func configure(plugin: CHPlugin, channel: CHChannel) {
    self.channel = channel
    
    self.backgroundColor = UIColor(plugin.borderColor)
    self.channelIconView.backgroundColor = channel.avatarUrl != nil ?
      UIColor.white : UIColor(plugin.color)
    
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
    
    self.contactViews.removeAllButtons()
    
    self.contactViews.addButton(
      baseColor: plugin.textUIColor,
      image: CHAssets.getImage(named: "homepage")) {
        guard let url = URL(string: self.channel?.homepageUrl ?? "") else { return }
        url.open()
    }
    
    self.contactViews.addButton(
      baseColor: plugin.textUIColor,
      image: CHAssets.getImage(named: "phone")) {
        guard let phoneNumber = self.channel?.phoneNumber else { return }
        if let url = URL(string: "tel://\(phoneNumber)") {
          url.open()
        }
      }

    self.contactViews.layoutButtons()
    
    self.setNeedsLayout()
    self.layoutIfNeeded()
  }
  
}
