//
//  ProfilePhoneView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ProfilePhoneView: ProfileInputView, ProfileContentProtocol {
  let phoneView = PhoneActionView()
  var model: MessageCellModelType?
  var index: Int = 0
  var item: CHProfileItem?
  
  override var inputFieldView: UIView? {
    get {
      return self.phoneView
    }
    set {
      self.inputFieldView = phoneView
    }
  }
  
  override func initialize() {
    super.initialize()
    
    self.phoneView.setOutFocus()
    self.phoneView.signalForText().subscribe(onNext: { [weak self] (text) in
      self?.titleLabel.text = self?.item?.nameI18n?.getMessage()
    }).disposed(by: self.disposeBag)
    
    self.phoneView.signalForAction().subscribe(onNext: { [weak self] (phone) in
      if let index = self?.index, let item = self?.model?.profileItems[index] {
        _ = self?.presenter?.updateProfileItem(with: self?.model?.message, key: item.key, value: phone)
          .subscribe(onNext: { (completed) in
            if !completed {
              self?.phoneView.setInvalid()
              self?.titleLabel.text = "invalid input"
            }
          })
      }
    }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  override func configure(model: MessageCellModelType, index: Int?, presenter: ChatManager?) {
    super.configure(model: model, index: index, presenter: presenter)
    guard let index = index else { return }
    self.model = model
    self.index = index
    
    let item = model.profileItems[index]
    self.item = item
    
    if let value = mainStore.state.guest.profile?[item.key] as? String,
      self.phoneView.phoneField.text != "" {
      self.phoneView.setMobileNumber(with: value)
    }
  }
}
