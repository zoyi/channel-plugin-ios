//
//  LoungeMainFooterView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoungeMainFooterView: BaseView {
  private let newChatButton = CHButtonFactory.newChat()
  private var disposeBag = DisposeBag()
  private var newSignal = PublishRelay<Any?>()
  
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
  
  func newChatSignal() -> Observable<Any?> {
    self.newSignal = PublishRelay<Any?>()
    self.newChatButton.signalForClick()
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    return self.newSignal.asObservable()
  }
}
