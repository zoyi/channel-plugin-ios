//
//  LabelCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 18/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

final class LabelCell : BaseTableViewCell {  
  let titleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 16)
    $0.textColor = .grey900
    $0.numberOfLines = 1
  }
  
  let arrowImageView = UIImageView().then {
    $0.contentMode = .center
    $0.image = CHAssets.getImage(named: "chevronRightSmall")
    $0.isHidden = true
  }
  
  var disabled = false {
    didSet {
      self.titleLabel.textColor = self.disabled ? .black20 : .grey900
    }
  }
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.titleLabel)
    self.addSubview(self.arrowImageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(16)
    }
    
    self.arrowImageView.snp.makeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(10)
    }
  }

  class func height() -> CGFloat {
    return 52
  }
}
