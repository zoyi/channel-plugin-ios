//
//  DateCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 22/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Reusable
import SnapKit

final class DateCell : BaseTableViewCell, Reusable {
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 12)
    $0.textColor = CHColors.blueyGrey
    $0.backgroundColor = CHColors.white
  }

  override func initialize() {
    super.initialize()
    self.addSubview(self.titleLabel)
  }
  
  func configure(date: String) {
    self.titleLabel.text = date
  }
  
  func configure(dateString: String) {
    self.titleLabel.text = dateString
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.titleLabel.snp.remakeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
}
