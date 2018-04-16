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

final class PhoneActionView: BaseView, DialogAction, ProfileInputProtocol {
  //MARK: Constants
  struct Constants {
    static let defaultDailCode = "+82"
  }
  
  struct Metric {
    static let countryLabelLeading = 16.f
    static let arrowImageLeading = 9.f
    static let arrowImageTrailing = 3.f
    static let phoneFieldLeading = 10.f
    static let confirmButtonWidth = 75.f
    static let arrowImageSize = CGSize(width: 9, height: 8)
  }

  //MARK: Properties
  let submitSubject = PublishSubject<Any?>()
  let confirmButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "sendActive")?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
  
  let countryCodeView = UIView()
  let countryLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 18)
    $0.textColor = CHColors.dark
  }
  
  let arrowDownView = UIImageView().then {
    $0.contentMode = UIViewContentMode.center
    $0.image = CHAssets.getImage(named: "dropdownTriangle")
  }
  
  let phoneField = UITextField().then {
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
    self.layer.borderColor = CHColors.brightSkyBlue.cgColor
    
    self.addSubview(self.phoneField)
    self.addSubview(self.confirmButton)
    self.addSubview(self.countryCodeView)
    self.countryCodeView.addSubview(self.countryLabel)
    self.countryCodeView.addSubview(self.arrowDownView)
    
    UtilityPromise.getCountryCodes()
      .observeOn(MainScheduler.instance)
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
    
    self.confirmButton.signalForClick()
      .subscribe(onNext: { [weak self] _ in
      if let code = self?.countryLabel.text,
        let number = self?.phoneField.text {
        let fullNumber = code + "-" + number
        self?.submitSubject.onNext(fullNumber)
      }
    }).disposed(by: self.disposeBeg)
  }

  override func setLayouts() {
    super.setLayouts()
    
    self.countryCodeView.snp.makeConstraints { (make) in
      //make.width.greaterThanOrEqualTo(Metric.codeViewWidth)
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.countryLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metric.countryLabelLeading)
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
      make.width.equalTo(Metric.confirmButtonWidth)
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }

  //MARK: UserActionView Protocol
  
  func signalForAction() -> PublishSubject<Any?> {
    return submitSubject
  }

}
