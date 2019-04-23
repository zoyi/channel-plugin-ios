//
//  KeyValueCell.swift
//  ChannelIO
//
//  Created by Haeun Chung on 23/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import Reusable

class KeyValueCell: BaseTableViewCell, Reusable {
 let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.dark
    $0.numberOfLines = 1
  }
  let valueLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 17)
    $0.textColor = CHColors.blueyGrey
    $0.text = CHAssets.localized("settings.profile.empty")
    $0.numberOfLines = 1
  }
  let arrowImageView = UIImageView().then {
    $0.contentMode = .center
    $0.image = CHAssets.getImage(named: "chevronRightSmall")
    $0.isHidden = true
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
    }
    
    self.valueLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalToSuperview()
      make.leading.equalTo(self.titleLabel.snp.trailing).inset(16)
    }
    
    self.arrowImageView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.greaterThanOrEqualTo(self.valueLabel.snp.trailing).offset(10)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(10)
    }
  }
  
  func configure(title: String?, detail: String?) {
    if let title = title {
      self.titleLabel.text = title
    }
    if let detail = detail {
      self.valueLabel.text = detail
      self.valueLabel.textColor = CHColors.dark
    } else {
      self.valueLabel.text = CHAssets.localized("settings.profile.empty")
      self.valueLabel.textColor = CHColors.blueyGrey
    }
  }
}
