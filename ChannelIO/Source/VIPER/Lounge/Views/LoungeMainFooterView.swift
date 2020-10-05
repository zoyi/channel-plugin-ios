//
//  LoungeMainFooterView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift
//import RxCocoa

class LoungeMainFooterView: BaseView {
  private let newChatButton = CHButtonFactory.newChat()
  private var disposeBag = _RXSwift_DisposeBag()
  private var newSignal = _RXRelay_PublishRelay<Any?>()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.newChatButton)
  }
  
  override func setLayouts() {
    super.setLayouts()
    self.newChatButton.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
      make.height.equalTo(46)
    }
  }
  
  func newChatSignal() -> _RXSwift_Observable<Any?> {
    self.newSignal = _RXRelay_PublishRelay<Any?>()
    self.newChatButton.signalForClick()
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    return self.newSignal.asObservable()
  }
}
