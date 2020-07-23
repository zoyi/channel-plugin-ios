//
//  ProfileBooleanView.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/23.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class ProfileBooleanView: ProfileItemBaseView, ProfileContentProtocol {
  let booleanView = BooleanActionView()
  var responder: UIView {
    return self.booleanView
  }
  var didFirstResponder: Bool = false
  
  override var fieldView: Actionable? {
    get {
      return self.booleanView
    }
  }
  
  override func initialize() {
    super.initialize()
    self.booleanView.setOutFocus()
    resignFirstResponder()
  }
  
  override func configure(model: MessageCellModelType, index: Int?, presenter: UserChatPresenterProtocol?) {
    super.configure(model: model, index: index, presenter: presenter)
    guard let item = self.item else { return }
    if let bool = mainStore.state.user.profile?[item.key] as? Bool {
      self.booleanView.selectedValue = bool
    } else if let text = mainStore.state.user.profile?[item.key] as? String {
      self.booleanView.selectedValue = text == "true"
        ? true : text == "false"
        ? false : nil
    }
  }
}
