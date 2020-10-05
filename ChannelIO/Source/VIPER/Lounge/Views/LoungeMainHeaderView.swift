//
//  LoungeMainHeaderView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift
//import RxCocoa

class LoungeMainHeaderView: BaseView {
  private let recentLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = .grey500
    $0.text = CHAssets.localized("ch.lounge.proceeding_chat")
  }

  private let newChatButton = UIButton(type: .system).then {
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
    $0.setTitleColor(.grey900, for: .normal)
    $0.setTitle(CHAssets.localized("ch.chat.start_new_chat"), for: .normal)
    $0.setImage(CHAssets.getImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.imageEdgeInsets = UIEdgeInsets(top:5, left: -3, bottom: 5, right: 5)
    $0.imageView?.contentMode = .scaleAspectFit
    $0.tintColor = .grey900
  }
  
  private var newSignal = _RXRelay_PublishRelay<Any?>()
  private var disposeBag = _RXSwift_DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.recentLabel)
    self.addSubview(self.newChatButton)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.recentLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(12)
    }
    
    self.newChatButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.recentLabel.snp.centerY)
      make.trailing.equalToSuperview().inset(16)
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
