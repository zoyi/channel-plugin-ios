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

class ProfileCompletionView: ProfileItemBaseView, ProfileContentProtocol {
  let contentView = CompleteActionView()

  override var fieldView: Actionable? {
    get {
      return self.contentView
    }
    set {
      self.fieldView = contentView
    }
  }
  
  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  override func configure(model: MessageCellModelType, index: Int?, presenter: ChatManager?) {
    super.configure(model: model, index: index, presenter: presenter)
    self.indexLabel.isHidden = true
    if let index = index, let value = model.profileItems[index].value {
      self.contentView.contentLabel.text = "\(value)"
    }
  }
}
