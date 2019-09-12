//
//  KeyValueCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import Reusable
import PhoneNumberKit

class KeyValueCell: BaseTableViewCell, Reusable {
 let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
    $0.numberOfLines = 1
  }
  let valueLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 17)
    $0.textColor = CHColors.blueyGrey
    $0.numberOfLines = 1
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue:500), for: .horizontal)
  }
  
  let arrowImageView = UIImageView().then {
    $0.contentMode = .center
    $0.image = CHAssets.getImage(named: "chevronRightSmall")
  }

  override func initialize() {
    super.initialize()
    
    self.addSubview(self.titleLabel)
    self.addSubview(self.valueLabel)
    self.addSubview(self.arrowImageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(16)
      make.width.lessThanOrEqualTo(UIScreen.main.bounds.width / 2)
    }
    
    self.valueLabel.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.leading.equalTo(self.titleLabel.snp.trailing).offset(16)
    }
    
    self.arrowImageView.snp.makeConstraints { (make) in
      make.leading.greaterThanOrEqualTo(self.valueLabel.snp.trailing).offset(10)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(10).priority(1000)
    }
  }
  
  func configure(profile: GuestProfileItemModel) {
    self.titleLabel.text = profile.profileName
    
    if let value = profile.profileValue {
      if profile.rawData.key == "mobileNumber" {
        self.valueLabel.text = PartialFormatter().formatPartial("\(value)")
      } else {
        self.valueLabel.text = "\(value)"
      }
      self.valueLabel.textColor = CHColors.charcoalGrey
    } else {
      self.valueLabel.text = CHAssets.localized("ch.settings.empty_content")
      self.valueLabel.textColor = CHColors.blueyGrey
    }
  }
}
