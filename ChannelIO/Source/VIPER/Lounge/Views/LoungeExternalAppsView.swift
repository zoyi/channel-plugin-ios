//
//  LoungeExternalAppsView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 25/04/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoungeExternalAppsView: BaseView {
  var clickSignal = PublishRelay<LoungeExternalSourceModel>()

  override func initialize() {
    super.initialize()
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  func configure(with model: LoungeExternalSourceViewModel) {
  
  }
}
