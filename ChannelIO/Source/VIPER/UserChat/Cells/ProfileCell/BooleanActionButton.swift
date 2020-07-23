//
//  BooleanActionButton.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/23.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import NVActivityIndicatorView

class BooleanActionButton: BaseView {
  let submitSubject = PublishSubject<Any?>()
  let focusSubject = PublishSubject<Bool>()
  
  let backgroundView = UIView().then {
    $0.backgroundColor = .white
  }
  
  let textLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16.f)
    $0.textColor = .grey300
  }

  let loadIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    .then {
      $0.type = .circleStrokeSpin
      $0.color = UIColor.grey500
      $0.isHidden = true
    }
  
  let disposeBag = DisposeBag()
  var didFocus = false
  var value: Bool = false {
    didSet {
      self.textLabel.text = self.value
        ? CHAssets.localized("ch.profile_form.boolean.yes")
        : CHAssets.localized("ch.profile_form.boolean.no")
    }
  }

  override func initialize() {
    super.initialize()
    
    self.addSubview(self.backgroundView)
    self.addSubview(self.textLabel)
    self.addSubview(self.loadIndicator)
    
    self
      .signalForClick()
      .bind{ [weak self] _ in
        self?.didFocus = true
        self?.submitSubject.onNext(self?.value)
      }.disposed(by: disposeBag)
  }
  
  override func setLayouts() {
    self.backgroundView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.textLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    self.loadIndicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}

extension BooleanActionButton: Actionable {
  func signalForAction() -> Observable<Any?> {
    return self.submitSubject.asObserver()
  }
  
  func signalForText() -> Observable<String?>? {
    return self.textField.rx.text.asObservable()
  }
  
  func signalForFocus() -> Observable<Bool> {
    return self.focusSubject
  }
  
  func setLoading() {
    self.textLabel.isHidden = true
    self.loadIndicator.isHidden = false
    self.loadIndicator.startAnimating()
  }
  
  func setFocus() {
    self.layer.borderColor = CHColors.brightSkyBlue.cgColor
    self.focusSubject.onNext(true)
  }
  
  func setOutFocus() {
    self.layer.borderColor = CHColors.paleGrey20.cgColor
    self.focusSubject.onNext(false)
  }
  
  func setInvalid() {
    self.layer.borderColor = CHColors.yellowishOrange.cgColor
    self.textLabel.isEnabled = false
    self.loadIndicator.isHidden = true
  }
}
