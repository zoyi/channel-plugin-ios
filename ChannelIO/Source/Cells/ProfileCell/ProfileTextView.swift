//
//  ProfileTextView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


class ProfileTextView: ProfileInputView, ProfileContentProtocol {
  let textView = TextActionView()
  override var inputFieldView: UIView? {
    get {
      return self.textView
    }
    set {
      self.inputFieldView = textView
    }
  }
  
  override func initialize() {
    super.initialize()

    
    self.textView.signalForAction().subscribe(onNext: { (text) in

    }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  override func configure(model: MessageCellModelType, index: Int, presenter: ChatManager?) {
    super.configure(model: model, index: index, presenter: presenter)
  }
}
