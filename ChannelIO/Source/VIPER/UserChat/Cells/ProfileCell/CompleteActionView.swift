//
//  CompleteActionView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/18/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift

final class CompleteActionView: BaseView, Actionable {
  private let submitSubject = _RXSwift_PublishSubject<Any?>()
  private let textSubject = _RXSwift_PublishSubject<String?>()
  
  let contentLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = .grey900
  }
  
  let completionImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "complete")
  }
  var didFocus: Bool = false
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.contentLabel)
    self.addSubview(self.completionImageView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.contentLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview()
      make.centerY.equalToSuperview()
    }
    
    self.completionImageView.snp.makeConstraints { [weak self] (make) in
      make.left.greaterThanOrEqualTo((self?.contentLabel.snp.right)!).offset(14)
      make.right.equalToSuperview()
      make.centerY.equalToSuperview()
      make.height.equalTo(24)
      make.width.equalTo(24)
    }
  }
  
  func signalForText() -> _RXSwift_Observable<String?>? {
    return self.textSubject.asObserver()
  }
  
  func signalForAction() -> _RXSwift_Observable<Any?> {
    return self.submitSubject.asObserver()
  }
  
  func setLoading() {}
  func setFocus() {}
  func setOutFocus() {}
  func setInvalid() {}
  func signalForFocus() -> _RXSwift_Observable<Bool> {
    return _RXSwift_Observable.just(false);
  }
}
