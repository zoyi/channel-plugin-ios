//
//  CountryCodePickerView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 07/03/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import RxSwift
import SnapKit

final class CountryCodePickerView : BaseView {

  var countries: [CHCountry] = []
  let disposeBeg = DisposeBag()
  var bottomContraint: Constraint?
  var pickedCode = "" {
    didSet {
      let index = self.countries.index { (country) -> Bool in
        return country.dial == self.pickedCode
      }
      if index != nil {
        self.pickerView.selectRow(index!, inComponent: 0, animated: false)
      }
    }
  }
  
  var submitSubject = PublishSubject<String>()
  let actionView = UIView()
  let closeButton = UIButton().then {
    $0.setTitleColor(CHColors.dark, for: UIControlState.normal)
    $0.setTitle(CHAssets.localized("ch.mobile_verification.cancel"), for: UIControlState                                                                                                                                                                                                                                             .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.f)
    
  }
  let submitButton = UIButton().then {
    $0.setTitleColor(CHColors.dark, for: UIControlState.normal)
    $0.setTitle(CHAssets.localized("ch.mobile_verification.confirm"), for: UIControlState.normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.f)
  }
  let pickerView = UIPickerView()
  let pickerContainerView = UIView().then {
    $0.backgroundColor = CHColors.white
  }
  
  let backgroundView = UIView().then {
    $0.backgroundColor = CHColors.gray.withAlphaComponent(0.5)
  }
  
  override func initialize() {
    super.initialize()
    self.countries = mainStore.state.countryCodeState.codes
//    UtilityPromise.getCountryCodes()
//      .subscribe(onNext:{ [weak self] (countries) in
//        self?.countries = countries
//        self?.pickerView.reloadAllComponents()
//      }).disposed(by: self.disposeBeg)
    
    self.actionView.addSubview(self.closeButton)
    self.actionView.addSubview(self.submitButton)
    self.pickerContainerView.addSubview(self.actionView)
    self.pickerContainerView.addSubview(self.pickerView)
    
    self.addSubview(self.backgroundView)
    self.addSubview(self.pickerContainerView)

    self.pickerView.delegate = self
    
    self.closeButton.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
      self?.remove(animated: true)
    }).disposed(by: self.disposeBeg)
    
    self.submitButton.signalForClick()
      .subscribe(onNext: { [weak self] (event) in
      guard let code = self?.pickedCode else { return }
      self?.submitSubject.onNext(code)
      self?.submitSubject.onCompleted()
        
      self?.remove(animated: true)
    }).disposed(by: self.disposeBeg)
  }
  
  override func setLayouts() {
    self.backgroundView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.closeButton.snp.remakeConstraints { (make) in
      make.leading.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    self.submitButton.snp.remakeConstraints { (make) in
      make.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    self.actionView.snp.remakeConstraints { (make) in
      make.height.equalTo(50)
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    self.pickerView.snp.remakeConstraints { [weak self] (make) in
      make.top.equalTo((self?.actionView.snp.bottom)!)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    self.pickerContainerView.snp.remakeConstraints { [weak self] (make) in
      make.height.equalTo(260)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      
      self?.bottomContraint = make.bottom.equalToSuperview().inset(-260).constraint
    }
  }
  
  func signalForSubmit() -> Observable<String> {
    return self.submitSubject
  }
}


// MARK: Transition

extension CountryCodePickerView {
  func showPicker(onView: UIView, animated: Bool) {
    onView.addSubview(self)
    onView.layoutIfNeeded()
    
    if !animated {
      return
    }
    
    UIView.animate(withDuration: 0.3) {
      self.pickerContainerView.snp.updateConstraints { (make) in
        make.bottom.equalToSuperview().inset(0)
      }
      onView.layoutIfNeeded()
    }
  }
  
  func removePicker(animated: Bool) {
    if !animated {
      self.removeFromSuperview()
      return
    }
    
    UIView.animate(withDuration: 0.3, animations: {
      self.pickerContainerView.snp.updateConstraints { (make) in
        make.bottom.equalToSuperview().inset(-260)
      }
      self.layoutIfNeeded()
    }) { (completed) in
      self.removeFromSuperview()
    }
  }
}

//MARK: UIPickerViewDelegate

extension CountryCodePickerView : UIPickerViewDelegate {
  
  func pickerView(_ pickerView: UIPickerView,
                  titleForRow row: Int,
                  forComponent component: Int) -> String? {
    //let countryName = Assets.localized("ch.mobile_verification.country." + self.countries[row].code.lowercased())
    return "\(self.countries[row].name)  +\(self.countries[row].dial)"
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.pickedCode = self.countries[row].dial
  }
}

//MARK: UIPickerViewDataSource

extension CountryCodePickerView : UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  numberOfRowsInComponent component: Int) -> Int {
    return self.countries.count
  }
  
}
