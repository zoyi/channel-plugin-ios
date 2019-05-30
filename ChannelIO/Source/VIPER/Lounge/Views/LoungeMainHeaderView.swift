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
  let recentLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.blueyGrey
    $0.text = CHAssets.localized("ch.lounge.recent_chat")
  }
  let alertCountLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.warmPink
  }
  let seeMoreLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = CHColors.charcoalGrey
    $0.text = CHAssets.localized("ch.lounge.see_all")
  }
  
  var moreSignal = PublishRelay<Any?>()
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.recentLabel)
    self.addSubview(self.alertCountLabel)
    self.addSubview(self.seeMoreLabel)
    self.seeMoreLabel.signalForClick()
      .bind(to: self.moreSignal)
      .disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.recentLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(12)
    }
    
    self.seeMoreLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalTo(self.recentLabel.snp.centerY)
      make.trailing.equalToSuperview().inset(16)
    }
    
    self.alertCountLabel.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.centerY.equalTo(self.recentLabel.snp.centerY)
      make.trailing.equalTo(self.seeMoreLabel.snp.leading).offset(-5)
    }
  }
  
  func configure(guest: CHGuest, chatModels: [UserChatCellModel]) {
    guard let guestAlert = guest.alert else { return }
    
    if chatModels.count > 3 {
      let displayAlertCounts = chatModels[0...2]
        .map { $0.badgeCount }
        .reduce(0) { (result, next) in
          return result + next
      }
      let restCount = guestAlert - displayAlertCounts
      
      self.seeMoreLabel.font = restCount > 0 ?
        UIFont.boldSystemFont(ofSize: 13) :
        UIFont.systemFont(ofSize: 13)
      
      self.alertCountLabel.text = "\(guestAlert - displayAlertCounts)"
      self.alertCountLabel.isHidden = restCount <= 0
    } else {
      self.seeMoreLabel.isHidden = true
    }
  }
}
