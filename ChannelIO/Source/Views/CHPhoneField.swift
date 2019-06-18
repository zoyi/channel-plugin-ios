//
//  PhoneField.swift
//  CHPlugin
//
//  Created by Haeun Chung on 18/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import PhoneNumberKit
import RxSwift
import RxCocoa

final class CHPhoneField: BaseView {
  
  fileprivate var dial : String = ""
  fileprivate var code : String = ""
  fileprivate var number : String = ""
  
  private struct Constants {
    static let defaultDailCode = "82"
  }
  
  private struct Metrics {
    static let countryLabelLeading = 16
    static let arrowImageLeading = 9
    static let arrowImageTrailing = 3
    static let phoneFieldLeading = 10
    static let arrowImageSize = CGSize(width: 9, height: 8)
  }
  
  let changeSubject = PublishRelay<String>()
  let validSubject = PublishSubject<Bool>()
  
  var countries: [CHCountry] = []
  var disposeBeg = DisposeBag()
  let countryCodeView = UIView()
  
  let countryLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = CHColors.dark
    $0.text = "+" + Constants.defaultDailCode
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
  }
  
  let arrowDownView = UIImageView().then {
    $0.contentMode = .center
    $0.image = CHAssets.getImage(named: "downArrow")
  }
  
  let topDivider = UIView().then {
    $0.backgroundColor = CHColors.dark20
  }
  
  var field: UITextField {
    return self.phoneField
  }
  
  let phoneField = PhoneNumberTextField().then {
    $0.textColor = CHColors.dark
    $0.keyboardType = .phonePad
    $0.clearButtonMode = .whileEditing
    $0.placeholder = CHAssets.localized("ch.settings.edit.phone_number_placeholder")
  }
  
  let bottomDivider = UIView().then {
    $0.backgroundColor = CHColors.dark20
  }
  
  convenience init(text: String = "") {
    self.init(frame: CGRect.zero)
    
    do {
      let phKit = PhoneNumberKit()
      let phoneNumber = try phKit.parse(text)
      self.number = "\(phoneNumber.nationalNumber)"
      self.dial = "\(phoneNumber.countryCode)"
    } catch {
      self.number = text
    }
    
    self.countryLabel.text = "+" + self.dial
    
    UtilityPromise.getCountryCodes()
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] (countries) -> Observable<GeoIPInfo> in
        self?.countries = countries
        if let code = self?.getCountryCode(dial: self?.dial) {
          self?.phoneField.defaultRegion = code
          self?.phoneField.text = self?.number
        }
        return UtilityPromise.getGeoIP()
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext:{ [weak self] (geoInfo) in
        if let dial =  self?.getCountryDialCode(countryCode: geoInfo.country), text == "" {
          self?.dial = dial
          self?.code = geoInfo.country
          self?.countryLabel.text = "+" + dial
          self?.phoneField.defaultRegion = geoInfo.country
        }
        }, onError: { [weak self] error in
          self?.countryLabel.text = "+" + Constants.defaultDailCode
          self?.phoneField.defaultRegion = "KR"
          self?.phoneField.text = self?.number
      }).disposed(by: self.disposeBeg)
  }
  
  func getCountryDialCode(countryCode: String?) -> String? {
    guard let countryCode = countryCode else { return nil }
    for each in self.countries {
      if each.code == countryCode {
        return each.dial
      }
    }
    return nil
  }
  
  func getCountryCode(dial: String?) -> String? {
    guard let dial = dial else { return nil }
    for each in self.countries {
      if each.dial == dial {
        return each.code
      }
    }
    return nil
  }
  
  override func initialize(){
    super.initialize()
    self.handleAction()
    self.phoneField.addTarget(
      self,
      action: #selector(textFieldDidChange(_:)),
      for: .editingChanged)
    
    self.backgroundColor = UIColor.white
    self.countryCodeView.addSubview(self.countryLabel)
    self.countryCodeView.addSubview(self.arrowDownView)
    self.addSubview(self.countryCodeView)
    self.addSubview(self.phoneField)
    self.addSubview(self.topDivider)
    self.addSubview(self.bottomDivider)
  }
  
  override func layoutSubviews(){
    super.layoutSubviews()
    
    self.countryCodeView.snp.makeConstraints { (make) in
      make.width.lessThanOrEqualTo(90)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.countryLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.countryLabelLeading)
      make.centerY.equalToSuperview()
    }
    
    self.arrowDownView.snp.makeConstraints { [weak self] (make) in
      make.size.equalTo(Metrics.arrowImageSize)
      make.left.equalTo((self?.countryLabel.snp.right)!).offset(Metrics.arrowImageLeading)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metrics.arrowImageTrailing)
    }
    
    self.topDivider.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(0.33)
    }
    
    self.phoneField.snp.makeConstraints { [weak self] (make) in
      make.left.equalTo((self?.countryCodeView.snp.right)!).offset(Metrics.phoneFieldLeading)
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.bottomDivider.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.height.equalTo(0.33)
      make.bottom.equalToSuperview()
    }
  }
}

extension CHPhoneField : CHFieldDelegate {
  func getText() -> String {
    if let number = self.phoneField.text,
      number == "" {
      return ""
    }
    
    return "+" + self.dial + self.phoneField.nationalNumber
  }
  
  func setText(_ value: String) {
    self.phoneField.text = value
  }
  
  func isValid() -> Observable<Bool> {
    return self.validSubject
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    self.validSubject.onNext(true)
    if let text = textField.text {
      self.changeSubject.accept(text)
    }
  }
  
  func hasChanged() -> Observable<String> {
    return self.changeSubject.asObservable()
  }
}

extension CHPhoneField {
  func handleAction() {
    
    self.countryCodeView.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        self?.field.resignFirstResponder()
        
        var controller = CHUtils.getTopController()
        if let navigation = controller?.navigationController {
          controller = navigation
        }
        
        let pickerView = CountryCodePickerView(frame: (controller?.view.frame)!)
        
        pickerView.countries = self?.countries ?? []
        pickerView.pickedCode = self?.code ?? ""
        pickerView.showPicker(onView: (controller?.view)!,animated: true)
        
        pickerView.signalForSubmit()
          .subscribe(onNext: { (code, dial) in
            self?.code = code
            self?.dial = dial
            self?.phoneField.defaultRegion = code
            self?.countryLabel.text =  "+" + dial
          }).disposed(by: (self?.disposeBeg)!)
      }).disposed(by: self.disposeBeg)
  }
  
}


