//
//  DefaultNavigationTitleView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import SnapKit

class DefaultNavigationTitleView: BaseView {
  
  struct Metric {
    static let titleHeight = 22.f
    static let imageSize = 22.f
  }
  
  let channelNameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 17)
  }
  let statusImageView = UIImageView().then {
    $0.contentMode = .center
  }
  let operationLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = .white70
    $0.alpha = 0.7
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.channelNameLabel)
    self.addSubview(self.statusImageView)
    self.addSubview(self.operationLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.channelNameLabel.snp.makeConstraints { (make) in
      make.height.equalTo(Metric.titleHeight)
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.statusImageView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(self.channelNameLabel.snp.trailing)
      make.top.equalToSuperview()
      make.height.equalTo(Metric.imageSize)
      make.width.equalTo(Metric.imageSize)
    }
    
    self.operationLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalToSuperview()
      make.top.equalTo(self.channelNameLabel.snp.bottom)
      make.bottom.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
  
  func configure(channel: CHChannel, userChat: CHUserChat?, plugin: CHPlugin) {
    self.channelNameLabel.textColor = plugin.textUIColor
    self.operationLabel.textColor = plugin.textUIColor
    
    if channel.working {
      self.operationLabel.text = CHAssets.localized("ch.chat.expect_response_delay.\(channel.expectedResponseDelay).short_description")
      self.statusImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "\(channel.expectedResponseDelay)W") :
        CHAssets.getImage(named: "\(channel.expectedResponseDelay)B")
    } else {
      if let (_, timeLeft) = channel.closestWorkingTime(from: Date()) {
        self.operationLabel.text = timeLeft > 60 ?
          String(format: CHAssets.localized("ch.navigation.next_operation.hour_left"), timeLeft / 60) :
          String(format: CHAssets.localized("ch.navigation.next_operation.minutes_left"), max(1, timeLeft))
      }
      else {
        self.operationLabel.text = CHAssets.localized("ch.chat.expect_response_delay.out_of_working.short_description")
      }
     
      self.statusImageView.image = plugin.textColor == "white" ?
        CHAssets.getImage(named: "offhoursW") :
        CHAssets.getImage(named: "offhoursB")
    }
  }
  
  override var intrinsicContentSize: CGSize {
    return UIView.layoutFittingExpandedSize
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: 35)
  }
}
