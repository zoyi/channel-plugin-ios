//
//  LoungeMainFooterView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

class LoungeMainFooterView: BaseView {
  let newChatButton = CHButton.newChat()
  
  let newChatSignal = PublishRelay<Any?>()
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.newChatButton)
    
    self.newChatButton.signalForClick()
      .bind(to: self.newChatSignal)
      .disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.newChatButton.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
      make.height.equalTo(46)
    }
  }
}
