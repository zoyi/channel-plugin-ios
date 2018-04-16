//
//  ProfileInputView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift

class ProfileInputView: BaseView {
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
  }
  let indexLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 13)
  }
  var inputFieldView: UIView? = nil
  let optionalFooterLabel = UILabel()
  let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.titleLabel)
    self.addSubview(self.indexLabel)
    self.addSubview(self.inputFieldView!)
    self.addSubview(self.optionalFooterLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.titleLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview().inset(2)
      make.left.equalToSuperview().inset(14)
    }
    
    self.indexLabel.snp.makeConstraints { [weak self] (make) in
      make.top.equalToSuperview().inset(2)
      make.left.equalTo((self?.titleLabel.snp.right)!).offset(10)
      make.right.equalToSuperview().inset(14)
    }

    self.inputFieldView?.snp.makeConstraints({ (make) in
      make.left.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(12)
      make.top.equalToSuperview().inset(24)
      make.height.equalTo(44)
    })
    
    self.optionalFooterLabel.snp.makeConstraints { (make) in
      //make.top.equalTo((self?.profileInputView?.view.snp.bottom)!).offset(12)
      make.left.equalToSuperview().inset(12)
      make.right.equalToSuperview().inset(12)
      make.bottom.equalToSuperview().inset(12)
    }
  }
  
  func configure(model: MessageCellModelType, index: Int, presenter: ChatManager?) {
    let item = model.profileItems[index]
    self.titleLabel.text = item.nameI18n?.getMessage()
    let current = "\(index + 1)"
    let currentText = current.addFont(
      UIFont.systemFont(ofSize: 13),
      color: CHColors.dark,
      on: NSRange(location: 0, length: current.count))
    let total = "/\(model.profileItems.count)"
    let totalText = total.addFont(
      UIFont.systemFont(ofSize: 13),
      color: CHColors.silver,
      on: NSRange(location: 0, length: total.count))
    self.indexLabel.attributedText = currentText.combine(totalText)
  }
  
  class func viewHeight() -> CGFloat {
    return 80.0 // 118 if extended
  }
}
