//
//  LoungeMainHeaderView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 30/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa

class LoungeMainHeaderView: BaseView {
  private let recentLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
    $0.text = CHAssets.localized("ch.lounge.proceeding_chat")
  }

  private let newChatButton = UIButton(type: .system).then {
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
    $0.setTitleColor(CHColors.charcoalGrey, for: .normal)
    $0.setTitle(CHAssets.localized("ch.chat.start_new_chat"), for: .normal)
    $0.setImage(CHAssets.getImage(named: "send")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.imageEdgeInsets = UIEdgeInsets(top:5, left: -3, bottom: 5, right: 5)
    $0.imageView?.contentMode = .scaleAspectFit
    $0.tintColor = CHColors.charcoalGrey
  }
  
  private var newSignal = PublishRelay<Any?>()
  private var disposeBag = DisposeBag()
  
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

  func newChatSignal() -> Observable<Any?> {
    self.newSignal = PublishRelay<Any?>()
    self.newChatButton.signalForClick()
      .bind(to: self.newSignal)
      .disposed(by: self.disposeBag)
    return self.newSignal.asObservable()
  }
}
