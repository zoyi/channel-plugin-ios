//
//  LogCell.swift
//  CHPlugin
//
//  Created by Haeun Chung on 27/06/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

final class LogCell : BaseTableViewCell {
  let container = UIView().then {
    $0.backgroundColor = .white
  }
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = .grey900
    $0.textAlignment = .center
  }
  
  let timestampLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = .grey500
    $0.textAlignment = .left
  }
  
  override func initialize() {
    super.initialize()
    
    self.container.addSubview(self.titleLabel)
    self.container.addSubview(self.timestampLabel)
    self.contentView.addSubview(self.container)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.container.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top:6, left:0, bottom:6, right:0))
    }
    
    self.titleLabel.snp.remakeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.leading.greaterThanOrEqualToSuperview().inset(10)
    }
    
    self.timestampLabel.snp.remakeConstraints { [weak self] (make) in
      make.trailing.greaterThanOrEqualToSuperview().inset(10)
      make.centerY.equalToSuperview()
      make.leading.equalTo((self?.titleLabel.snp.trailing)!).offset(5)
    }
  }
  
  func configure(message: CHMessage) {
    guard let log = message.log else { return }
    if log.action == "closed" {
      self.titleLabel.text = CHAssets.localized("ch.log.resolved")
      self.timestampLabel.text = message.createdAt.readableShortString()
    }
  }
  
  class func cellHeight(fit width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    return 46
  }
}
