//
//  ChatStatusExtensionView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 23/11/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit
import SnapKit

class ChatStatusDefaultView : BaseView {
  let statusLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 14)
  }
  
  let statusImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "offhoursW")
    $0.contentMode = .center
  }
  
  let statusDescLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.numberOfLines = 0
  }
  
  let multiAvatarView = CHMultiAvatarView()
  
  let divider = UIView().then {
    $0.isHidden = false
    $0.alpha = 0.3
    $0.backgroundColor = UIColor.white
  }
  
  let businessHoursView = UIView().then {
    $0.isHidden = false
  }
  let businessHoursLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.numberOfLines = 0
  }
  
  var avatarWidthContraint: Constraint? = nil
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.statusLabel)
    self.addSubview(self.statusImageView)
    self.addSubview(self.statusDescLabel)
    self.addSubview(self.multiAvatarView)
    self.addSubview(self.divider)
    self.businessHoursView.addSubview(self.businessHoursLabel)
    self.addSubview(self.businessHoursView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.statusLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(18)
      make.top.equalToSuperview().inset(10)
    }
    
    self.statusImageView.snp.makeConstraints { [weak self] (make) in
      make.centerY.equalTo((self?.statusLabel.snp.centerY)!)
      make.leading.equalTo((self?.statusLabel.snp.trailing)!).offset(7)
      make.trailing.lessThanOrEqualTo((self?.multiAvatarView.snp.leading)!).offset(10)
      make.height.equalTo(22)
      make.width.equalTo(22)
    }
    
    self.statusDescLabel.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview().inset(18)
      make.top.equalTo((self?.statusLabel.snp.bottom)!).offset(4)
      make.trailing.equalTo((self?.multiAvatarView.snp.leading)!).offset(-10)
    }
    
    self.multiAvatarView.snp.makeConstraints { (make) in
      make.trailing.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(10)
      make.height.equalTo(44)
    }
    
    self.divider.snp.makeConstraints { [weak self] (make) in
      make.top.equalTo((self?.statusDescLabel.snp.bottom)!).offset(15)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(0.5)
    }
    
    self.businessHoursView.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.top.equalTo((self?.divider.snp.bottom)!)
      make.bottom.equalToSuperview()
    }
    
    self.businessHoursLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(18)
      make.trailing.equalToSuperview().inset(18)
      make.top.equalToSuperview().inset(15)
      make.bottom.equalToSuperview().inset(20)
    }
  }
  
  func configure(channel: CHChannel) {
    self.statusLabel.text = "운영시간 아님"
    self.statusLabel.textColor = UIColor.white
    self.statusDescLabel.text = "지금은 채팅 운영시간이 아닙니다.\n질문을 남겨주시면 가능한 빨리 답변을 드리도록 하겠습니다."
    self.statusDescLabel.textColor = UIColor.white
    
    self.multiAvatarView.configure(persons: [])
    self.businessHoursLabel.text = channel.workingTimeString
    self.businessHoursLabel.textColor = UIColor.white
    //configure
  }
  
  static func viewHeight(fits width: CGFloat, channel: CHChannel) -> CGFloat {
    var height: CGFloat = 0
    let avatarWidth = 100.f
    height += 10 //top margin
    height += "운영시간 아님".height(fits: width - avatarWidth, font: UIFont.boldSystemFont(ofSize: 14))
    height += 4
    height += "지금은 채팅 운영시간이 아닙니다.\n질문을 남겨주시면 가능한 빨리 답변을 드리도록 하겠습니다.".height(fits: width - avatarWidth, font: UIFont.systemFont(ofSize: 13))
    height += 15
    
    //if business hour set ..
    height += 15 //top
    height += channel.workingTimeString.height(fits: width - avatarWidth, font: UIFont.systemFont(ofSize: 13))
    height += 20 //bottom
    height += 5
    return height
  }
}
