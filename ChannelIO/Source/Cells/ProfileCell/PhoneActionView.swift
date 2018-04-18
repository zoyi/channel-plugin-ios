//
//  PhoneActionView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import PhoneNumberKit

final class PhoneActionView: BaseView, Actionable {
  //MARK: Constants
  struct Constants {
    static let defaultDailCode = "+82"
  }
  
  struct Metric {
    static let countryLabelLeading = 16.f
    static let arrowImageLeading = 3.f
    static let arrowImageTrailing = 3.f
    static let phoneFieldLeading = 10.f
    static let confirmButtonWidth = 75.f
    static let arrowImageSize = CGSize(width: 9, height: 8)
  }

  //MARK: Properties
  let submitSubject = PublishSubject<Any?>()
  let confirmButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "sendActive")?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.tintColor = CHColors.cobalt
  }
  
  let countryCodeView = UIView()
  let countryLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = CHColors.dark
    $0.textAlignment = .center
  }
  
  let arrowDownView = UIImageView().then {
    $0.contentMode = UIViewContentMode.center
    $0.image = CHAssets.getImage(named: "dropdownTriangle")
  }
  
  let phoneField = PhoneNumberTextField().then {
    $0.keyboardType = .phonePad
    $0.placeholder = CHAssets.localized("ch.mobile_verification.placeholder")
  }
  
  let disposeBeg = DisposeBag()
  var userGeoInfo: GeoIPInfo?
  //MARK: Init
  
  override func initialize() {
    super.initialize()
    
    self.layer.cornerRadius = 2.f
    self.layer.borderWidth = 1.f
    self.layer.borderColor = CHColors.paleGrey20.cgColor
    
    self.addSubview(self.phoneField)
    self.addSubview(self.confirmButton)
    self.addSubview(self.countryCodeView)
    self.countryCodeView.addSubview(self.countryLabel)
    self.countryCodeView.addSubview(self.arrowDownView)
    
    NotificationCenter.default.rx
      .notification(Notification.Name(rawValue: "com.zoyi.channel.keyboard_dismiss"))
      .subscribe(onNext: { [weak self] (_) in
        self?.phoneField.resignFirstResponder()
      }).disposed(by: self.disposeBeg)
    
    self.phoneField.delegate = self
    self.phoneField.rx.text.subscribe(onNext: { [weak self] (text) in
      if let text = text {
        self?.confirmButton.isHidden = text.count == 0
      }
      self?.confirmButton.isHighlighted = false
      self?.setFocus()
    }).disposed(by: self.disposeBeg)
    
    UtilityPromise.getCountryCodes().observeOn(MainScheduler.instance)
      .flatMap { (countries) -> Observable<GeoIPInfo> in
        mainStore.dispatch(GetCountryCodes(payload: countries))
        return UtilityPromise.getGeoIP()
      }.subscribe(onNext: { [weak self] (geoInfo) in
        if let countryCode = CHUtils.getCountryDialCode(countryCode: geoInfo.country) {
          self?.countryLabel.text = "+" + countryCode
        }
      }, onError: { [weak self] (error) in
        self?.countryLabel.text = Constants.defaultDailCode
      }).disposed(by: self.disposeBeg)

    self.countryCodeView.signalForClick().subscribe(onNext: { [weak self] (value) in
      self?.phoneField.resignFirstResponder()
        
      var code = (self?.countryLabel.text ?? "")
      code.remove(at: code.startIndex)
        
      CountryCodePickerView.presentCodePicker(with: code)
        .subscribe(onNext: { (newCode) in
          if let newCode = newCode {
            self?.countryLabel.text =  "+" + newCode
            self?.phoneField.becomeFirstResponder()
          }
        }).disposed(by: (self?.disposeBeg)!)
      }).disposed(by: self.disposeBeg)
    
    self.confirmButton.signalForClick().subscribe(onNext: { [weak self] _ in
      self?.submitValue()
    }).disposed(by: self.disposeBeg)
  }

  override func setLayouts() {
    super.setLayouts()
    
    self.countryCodeView.snp.makeConstraints { (make) in
      make.width.equalTo(70).priority(750)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.countryLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    self.arrowDownView.snp.makeConstraints { [weak self] (make) in
      make.size.equalTo(Metric.arrowImageSize)
      make.left.equalTo((self?.countryLabel.snp.right)!).offset(Metric.arrowImageLeading)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metric.arrowImageTrailing)
    }
    
    self.phoneField.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.countryCodeView.snp.right)!).offset(Metric.phoneFieldLeading)
      make.right.equalTo((self?.confirmButton.snp.left)!)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.confirmButton.snp.makeConstraints { (make) in
      make.width.equalTo(44)
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  func setMobileNumber(with fullNumber: String) {
    do {
      let phKit = PhoneNumberKit()
      let phoneNumber = try phKit.parse(fullNumber)
      self.phoneField.text = "\(phoneNumber.nationalNumber)"
      self.countryLabel.text = "\(phoneNumber.countryCode)"
    } catch {
      //self.number = text
    }
    self.confirmButton.isHidden = fullNumber == ""
  }
  
  //MARK: UserActionView Protocol
  
  func signalForAction() -> Observable<Any?> {
    return self.submitSubject.asObserver()
  }
  
  func signalForText() -> Observable<String?> {
    return self.phoneField.rx.text.asObservable()
  }
}

extension PhoneActionView {
  func setIntialValue(with value: String) {
    if let text = self.phoneField.text, text == "" {
      self.phoneField.text = value
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
  
  func submitValue() {
    if let code = self.countryLabel.text, let number = self.phoneField.text {
      let fullNumber = code + "-" + number
      self.submitSubject.onNext(fullNumber)
    }
  }
}

extension PhoneActionView: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if self.phoneField == textField {
      self.setFocus()
    } else {
      self.setOutFocus()
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.setOutFocus()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.submitValue()
    return false
  }
}

