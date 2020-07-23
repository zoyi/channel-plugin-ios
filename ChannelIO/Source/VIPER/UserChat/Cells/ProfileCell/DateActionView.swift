//
//  DateActionView.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/23.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import RxCocoa
import NVActivityIndicatorView

class DateActionView: BaseView {
  let submitSubject = PublishSubject<Any?>()
  let focusSubject = PublishSubject<Bool>()
  
  let selectButton = UIImageView().then {
    $0.image = CHAssets.getImage(named: "triangleDown")?.tint(with: .grey700)
  }
  
  let loadIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    .then {
      $0.type = .circleStrokeSpin
      $0.color = CHColors.light
      $0.isHidden = true
    }
  
  let textField = UITextField().then {
    $0.font = UIFont.systemFont(ofSize: 16)
    $0.textColor = .grey500
    $0.placeholder = CHAssets.localized("ch.profile_form.datetime_pick")
  }
  
  var date: Date? {
    didSet {
      let text = self.date?.fullDateString() ?? ""
      self.textField.text = text
    }
  }
  
  let disposeBag = DisposeBag()
  var didFocus = false
  
  override func initialize() {
    super.initialize()
    
    self.layer.cornerRadius = 2.f
    self.layer.borderWidth = 1.f
    self.layer.borderColor = CHColors.paleGrey20.cgColor
    
    self.addSubview(self.selectButton)
    self.addSubview(self.textField)
    self.addSubview(self.loadIndicator)
    
    NotificationCenter.default.rx
      .notification(Notification.Name.Channel.dismissKeyboard)
      .subscribe(onNext: { [weak self] (_) in
        self?.textField.resignFirstResponder()
      }).disposed(by: self.disposeBag)
    
    self.textField.delegate = self
    
    self.textField.signalForClick()
      .bind { [weak self] _ in
        guard self != nil else { return }
        self!.openDateSelector()
      }.disposed(by: self.disposeBag)
    
    self.selectButton.signalForClick()
      .bind { [weak self] _ in
        guard self != nil else { return }
        self!.openDateSelector()
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.textField.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(10)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.selectButton.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.textField.snp.right)!)
      make.width.equalTo(20)
      make.height.equalTo(20)
      make.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    self.loadIndicator.snp.makeConstraints { [weak self] (make) in
      make.centerX.equalTo((self?.selectButton.snp.centerX)!)
      make.centerY.equalTo((self?.selectButton.snp.centerY)!)
    }
  }
  
  private func openDateSelector() {
    UIApplication.shared.sendAction(
      #selector(UIApplication.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
    CHDateSelectorView.create(with: self.date)
      .bind { [weak self] date in
        if let date = date {
          self?.date = date
          self?.submitSubject.onNext(date)
        }
      }.disposed(by: self.disposeBag)
  }
}

extension DateActionView: Actionable {
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
    self.selectButton.isHidden = true
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
    self.selectButton.isHidden = false
    self.loadIndicator.isHidden = true
  }
}

extension DateActionView: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if self.textField == textField {
      self.didFocus = true
      self.setFocus()
    } else {
      self.setOutFocus()
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.setOutFocus()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.didFocus = true
    self.submitSubject.onNext(textField.text)
    return false
  }
}

