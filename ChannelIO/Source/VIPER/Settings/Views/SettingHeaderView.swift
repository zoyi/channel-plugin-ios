//
//  SettingHeaderView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit

class SettingHeaderView: BaseView {
  let bgLayer = CAGradientLayer().then {
    $0.startPoint = CGPoint(x: 0.0, y: 0.5)
    $0.endPoint = CGPoint(x: 1.0, y: 0.5)
    $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 86)
  }
  
  let bgImageView = UIImageView()
  
  let channelNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 24)
    $0.textAlignment = .left
  }
  let homepageUrlLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textAlignment = .left
  }
  let descriptionLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textAlignment = .left
    $0.alpha = 0.7
  }
  
  let channelAvatarView = AvatarView()
  
  override func initialize() {
    super.initialize()
    
    self.dropShadow(
      with: CHColors.black10,
      opacity: 0.5,
      offset: CGSize(width: 0, height: 2),
      radius: 2
    )
    self.clipsToBounds = false
    
//    self.layer.addSublayer(self.bgLayer)

    self.addSubview(self.bgImageView)
    self.addSubview(self.channelNameLabel)
    self.addSubview(self.homepageUrlLabel)
    self.addSubview(self.descriptionLabel)
    self.addSubview(self.channelAvatarView)
  }
  
  struct Metric {
    static let nameLeading = 60
    static let nameTrailing = 10
    static let homepageTop = 4
    static let descTop = 2
    static let descBottom = 20
    static let avatarTrailing = 27
    static let avatarSize = 60
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.bgImageView.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(86)
    }
    
    self.channelNameLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(Metric.nameLeading)
      make.top.equalToSuperview()
      make.trailing.lessThanOrEqualTo(self.channelAvatarView.snp.leading).offset(-Metric.nameTrailing)
    }
    
    self.homepageUrlLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(Metric.nameLeading)
      make.height.equalTo(20)
      make.top.equalTo(self.channelNameLabel.snp.bottom).offset(Metric.homepageTop)
      make.trailing.lessThanOrEqualTo(self.channelAvatarView.snp.leading).offset(-Metric.nameTrailing)
    }
    
    self.descriptionLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(Metric.nameLeading)
      make.height.equalTo(16)
      make.top.equalTo(self.homepageUrlLabel.snp.bottom).offset(Metric.descTop)
      make.trailing.lessThanOrEqualTo(self.channelAvatarView.snp.leading).offset(-Metric.nameTrailing)
      make.bottom.equalToSuperview().inset(Metric.descBottom)
    }
    
    self.channelAvatarView.snp.makeConstraints { (make) in
      make.height.equalTo(Metric.avatarSize)
      make.width.equalTo(Metric.avatarSize)
      make.top.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.avatarTrailing)
    }
  }
  
  func configure(with model: SettingHeaderViewModel) {
    self.channelNameLabel.text = model.title
    self.channelNameLabel.textColor = model.textColor
    self.homepageUrlLabel.text = model.homepageUrl
    self.homepageUrlLabel.textColor = model.textColor
    self.descriptionLabel.text = model.desc
    self.descriptionLabel.textColor = model.textColor
    self.channelAvatarView.configure(model.entity)
    self.bgLayer.colors = model.colors.map { $0.cgColor }
    self.bgImageView.image = self.bgLayer.createGradientImage()
  }
}
