//
//  ProfileCompletionView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 13/04/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import PhoneNumberKit

class ProfileCompletionView: ProfileItemBaseView, ProfileContentProtocol {
  let contentView = CompleteActionView()
  var responder: UIView {
    return self
  }
  var didFirstResponder: Bool {
    return false
  }
  
  override var fieldView: Actionable? {
    get {
      return self.contentView
    }
  }
  
  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  override func configure(model: MessageCellModelType, index: Int?, presenter: UserChatPresenterProtocol?) {
    super.configure(model: model, index: index, presenter: presenter)
    self.indexLabel.isHidden = true
    
    if let index = index, let value = model.profileItems[index].value {
      let unwrapped = unwrap(any: value)
      if self.item?.fieldType == .mobileNumber {
        self.contentView.contentLabel.text = PartialFormatter().formatPartial("\(unwrapped)")
      } else if self.item?.type == .boolean, let value = value as? Bool {
        self.contentView.contentLabel.text = value
          ? CHAssets.localized("ch.profile_form.boolean.yes")
          : CHAssets.localized("ch.profile_form.boolean.no")
      } else if self.item?.type == .date, let value = value as? Double {
        self.contentView.contentLabel.text = Date(timeIntervalSince1970: value / 1000)
          .fullDateString()
      } else {
        self.contentView.contentLabel.text = "\(unwrapped)"
      }
    }
  }
}
