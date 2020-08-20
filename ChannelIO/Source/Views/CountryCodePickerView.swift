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
  private enum Metric {
    static let pickerHeight = 260.f
    static let actionViewHeight = 50.f
    static let horizontalPadding = 10.f
  }

  var countries: [CHCountry] = []
  let disposeBag = DisposeBag()
  var bottomContraint: Constraint?
  var pickedCode = "" {
    didSet {
      if let index = self.countries.firstIndex(where: { country -> Bool in
        return country.code == self.pickedCode
      }) {
        self.pickerView.selectRow(index, inComponent: 0, animated: false)
        self.selectedIndex = index
      }
    }
  }
  
  var selectedIndex = 0
  
  var submitSubject = PublishSubject<(String, String)>()
  var cancelSubject = PublishSubject<Any?>()
  
  let actionView = UIView()
  let closeButton = UIButton().then {
    $0.setTitleColor(.grey900, for: .normal)
    $0.setTitle(CHAssets.localized("ch.common.cancel"), for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.f)
    
  }
  let submitButton = UIButton().then {
    $0.setTitleColor(.grey900, for: .normal)
    $0.setTitle(CHAssets.localized("ch.button_confirm"), for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 17.f)
  }
  let pickerView = UIPickerView().then {
    $0.setValue(UIColor.grey900, forKeyPath: "textColor")
  }
  let pickerContainerView = UIView().then {
    $0.backgroundColor = .white
  }
  
  let backgroundView = UIView().then {
    $0.backgroundColor = UIColor.grey700.withAlphaComponent(0.5)
  }
  
  static func presentCodePicker(with code: String) -> Observable<(String?, String?)> {
    return Observable.create { subscriber in
      guard var controller = CHUtils.getTopController() else { return Disposables.create() }
      if let navigation = controller.navigationController {
        controller = navigation
      }
      
      let pickerView = CountryCodePickerView(frame: controller.view.frame)
      pickerView.pickedCode = code
      pickerView.showPicker(onView: controller.view, animated: true)
      
      let submitSignal = pickerView.signalForSubmit().subscribe(onNext: { (code, dial) in
        subscriber.onNext((code, dial))
        subscriber.onCompleted()
      })
      
      let cancelSignal = pickerView.signalForCancel().subscribe(onNext: { _ in
        subscriber.onNext((nil, nil))
        subscriber.onCompleted()
      })
      
      return Disposables.create {
        submitSignal.dispose()
        cancelSignal.dispose()
      }
    }
  }
  
  override func initialize() {
    super.initialize()
    self.countries = mainStore.state.countryCodeState.codes
    
    self.actionView.addSubview(self.closeButton)
    self.actionView.addSubview(self.submitButton)
    self.pickerContainerView.addSubview(self.actionView)
    self.pickerContainerView.addSubview(self.pickerView)
    
    self.addSubview(self.backgroundView)
    self.addSubview(self.pickerContainerView)

    self.pickerView.delegate = self
    
    self.backgroundView
      .signalForClick()
      .bind { [weak self] _ in
        self?.cancelSubject.onNext(nil)
        self?.cancelSubject.onCompleted()
          
        self?.removePicker(animated: true)
      }.disposed(by: self.disposeBag)
    
    self.closeButton
      .signalForClick()
      .bind { [weak self] event in
        self?.cancelSubject.onNext(nil)
        self?.cancelSubject.onCompleted()
        
        self?.removePicker(animated: true)
      }.disposed(by: self.disposeBag)
    
    self.submitButton
      .signalForClick()
      .bind { [weak self] event in
        guard
          let index = self?.selectedIndex,
          let country = self?.countries.get(index: index)
        else {
          return
        }
        
        self?.submitSubject.onNext((country.code, country.dial))
        self?.submitSubject.onCompleted()
        
        self?.removePicker(animated: true)
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    self.backgroundView.snp.remakeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.closeButton.snp.remakeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.horizontalPadding)
      make.centerY.equalToSuperview()
    }
    
    self.submitButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(Metric.horizontalPadding)
      make.centerY.equalToSuperview()
    }
    
    self.actionView.snp.makeConstraints { make in
      make.height.equalTo(Metric.actionViewHeight)
      make.top.leading.trailing.equalToSuperview()
    }
    
    self.pickerView.snp.makeConstraints { make in
      make.top.equalTo(self.actionView.snp.bottom)
      make.leading.trailing.equalToSuperview()
      
      if #available(iOS 11.0, *) {
        let bottom = CHUtils.getKeyWindow()?.rootViewController?.view.safeAreaInsets.bottom ?? 0.f
        make.bottom.equalToSuperview().inset(bottom)
      } else {
        make.bottom.equalToSuperview()
      }
    }
    
    self.pickerContainerView.snp.makeConstraints { [weak self] make in
      make.leading.trailing.equalToSuperview()

      if #available(iOS 11.0, *) {
        let bottom = CHUtils.getKeyWindow()?.rootViewController?.view.safeAreaInsets.bottom ?? 0.f
        self?.bottomContraint = make.bottom
          .equalToSuperview()
          .inset(-Metric.pickerHeight - bottom).constraint
        make.height.equalTo(Metric.pickerHeight + bottom)
        
      } else {
        self?.bottomContraint = make.bottom.equalToSuperview()
          .inset(-Metric.pickerHeight)
          .constraint
        make.height.equalTo(Metric.pickerHeight)
      }
    }
  }
  
  func signalForSubmit() -> Observable<(String, String)> {
    return self.submitSubject.asObservable()
  }
  
  func signalForCancel() -> Observable<Any?> {
    return self.cancelSubject.asObservable()
  }
}


// MARK: Transition

extension CountryCodePickerView {
  func showPicker(onView: UIView, animated: Bool) {
    CHUtils.getTopNavigation()?.interactivePopGestureRecognizer?.isEnabled = false

    onView.addSubview(self)
    onView.layoutIfNeeded()
    
    if !animated {
      return
    }
    
    UIView.animate(withDuration: 0.3) {
      self.pickerContainerView.snp.updateConstraints { make in
        make.bottom.equalToSuperview().inset(0)
      }
      onView.layoutIfNeeded()
    }
  }
  
  func removePicker(animated: Bool) {
    CHUtils.getTopNavigation()?.interactivePopGestureRecognizer?.isEnabled = true

    if !animated {
      self.removeFromSuperview()
      return
    }
    
    UIView.animate(withDuration: 0.3, animations: {
      self.pickerContainerView.snp.updateConstraints { make in
        if #available(iOS 11.0, *) {
          let bottom = CHUtils
            .getKeyWindow()?
            .rootViewController?
            .view.safeAreaInsets
            .bottom ?? 0.f
          make.bottom.equalToSuperview().inset(-Metric.pickerHeight - bottom)
        } else {
          make.bottom.equalToSuperview().inset(-Metric.pickerHeight)
        }
      }
      self.layoutIfNeeded()
    }) { [weak self] completed in
      self?.removeFromSuperview()
    }
  }
}

//MARK: UIPickerViewDelegate

extension CountryCodePickerView : UIPickerViewDelegate {
  
  func pickerView(
    _ pickerView: UIPickerView,
    titleForRow row: Int,
    forComponent component: Int
  ) -> String? {
    return "\(self.countries[row].name)  +\(self.countries[row].dial)"
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.selectedIndex = row
  }
}

//MARK: UIPickerViewDataSource

extension CountryCodePickerView : UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.countries.count
  }
}
