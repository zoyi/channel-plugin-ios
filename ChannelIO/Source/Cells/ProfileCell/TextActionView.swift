//
//  TextActionView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import RxCocoa

class TextActionView: BaseView, Actionable {
  let submitSubject = PublishSubject<Any?>()
  let confirmButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "sendActive")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.setImage(CHAssets.getImage(named: "sendError")?.withRenderingMode(.alwaysTemplate), for: .disabled)
    $0.tintColor = CHColors.cobalt
  }
  
  let textField = UITextField().then {
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = CHColors.dark
    $0.placeholder = CHAssets.localized("ch.name_verification.placeholder")
  }
  
  let disposeBeg = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.layer.cornerRadius = 2.f
    self.layer.borderWidth = 1.f
    self.layer.borderColor = CHColors.paleGrey20.cgColor
    
    self.addSubview(self.confirmButton)
    self.addSubview(self.textField)
    
    NotificationCenter.default.rx
      .notification(Notification.Name.Channel.dismissKeyboard)
      .subscribe(onNext: { [weak self] (_) in
        self?.textField.resignFirstResponder()
      }).disposed(by: self.disposeBeg)
    
    self.textField.delegate = self
    self.textField.rx.text.subscribe(onNext: { [weak self] (text) in
      if let text = text {
        self?.confirmButton.isHidden = text.count == 0
      }
      self?.setFocus()
    }).disposed(by: self.disposeBeg)
    
    self.confirmButton.signalForClick()
      .subscribe(onNext: { [weak self] _ in
      self?.submitSubject.onNext(self?.textField.text)
    }).disposed(by: self.disposeBeg)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.textField.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(10)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.confirmButton.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.textField.snp.right)!)
      make.width.equalTo(44)
      make.height.equalTo(44)
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  //MARK: UserActionView Protocol
  
  func signalForAction() -> Observable<Any?> {
    return self.submitSubject.asObserver()
  }
  
  func signalForText() -> Observable<String?> {
    return self.textField.rx.text.asObservable()
  }
}

extension TextActionView {
  func setIntialValue(with value: String) {
    if let text = self.textField.text, text == "" {
      self.textField.text = value
    }
    self.confirmButton.isHidden = value == ""
  }
  
  func setFocus() {
    self.layer.borderColor = CHColors.brightSkyBlue.cgColor
    self.confirmButton.tintColor = CHColors.brightSkyBlue
  }
  
  func setOutFocus() {
    self.layer.borderColor = CHColors.paleGrey20.cgColor
    self.confirmButton.tintColor = CHColors.paleGrey20
  }
  
  func setInvalid() {
    self.layer.borderColor = CHColors.yellowishOrange.cgColor
    self.confirmButton.tintColor = CHColors.yellowishOrange
  }
}

extension TextActionView: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if self.textField == textField {
      self.setFocus()
    } else {
      self.setOutFocus()
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.setOutFocus()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.submitSubject.onNext(textField.text)
    return false
  }
}
