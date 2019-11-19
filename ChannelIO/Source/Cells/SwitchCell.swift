//
//  SwitchCell.swift
//  CHPlugin
//
//  Created by R3alFr3e on 6/20/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

final class SwitchCell : BaseTableViewCell {
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 16)
    $0.textColor = CHColors.charcoalGrey
    $0.numberOfLines = 1
  }
  
  let onOffSwitch = UISwitch()
  var switchSignal = PublishRelay<Bool>()
  
  override func initialize() {
    super.initialize()
    
    self.onOffSwitch.addTarget(
      self, action: #selector(self.switchChanged(_:)),
      for: .valueChanged)
    self.addSubview(self.titleLabel)
    self.addSubview(self.onOffSwitch)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.titleLabel.snp.remakeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(16)
    }
    
    self.onOffSwitch.snp.remakeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(10)
    }
  }
  
  class func height() -> CGFloat {
    return 48
  }
  
  func configure(title: String, isOn: Bool) {
    self.titleLabel.text = title
    self.onOffSwitch.isOn = isOn
  }
  
  func switched() -> Observable<Bool> {
    self.switchSignal = PublishRelay<Bool>()
    return self.switchSignal.asObservable()
  }
  
  @objc func switchChanged(_ sender: UISwitch) {
    self.switchSignal.accept(sender.isOn)
  }
}

