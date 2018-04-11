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

class TextActionView: BaseView, DialogAction, UITextFieldDelegate {
  let submitSubject = PublishSubject<Any?>()
  let confirmButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "sendActive")?.withRenderingMode(.alwaysTemplate), for: .normal)
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
    self.layer.borderColor = CHColors.brightSkyBlue.cgColor
    
    self.addSubview(self.confirmButton)
    self.addSubview(self.textField)

    self.textField.rx.text.subscribe(onNext: { (text) in
      if let text = text {
        self.confirmButton.isEnabled = text.count > 0
      }
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
    }
  }
  
  //MARK: UserActionView Protocol
  
  func signalForAction() -> PublishSubject<Any?> {
    return submitSubject
  }
}


