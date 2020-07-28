//
//  DateActionView.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/23.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import RxSwift
import SnapKit
import RxCocoa
import NVActivityIndicatorView

final class DateActionView: BaseView {
  private enum Metric {
    static let fontSize = 16.f
    static let indicatorSize = 20.f
    static let selectButtonSize = 20.f
    static let cornerRadius = 2.f
    static let borderWidth = 1.f
    static let horizontalPadding = 10.f
  }
  private let submitSubject = PublishSubject<Any?>()
  private let focusSubject = PublishSubject<Bool>()
  
  private let selectButton = UIImageView().then {
    $0.image = CHAssets.getImage(named: "triangleDown")?.tint(with: .grey700)
  }
  
  private let loadIndicator = NVActivityIndicatorView(
    frame: CGRect(x: 0, y: 0, width: Metric.indicatorSize, height: Metric.indicatorSize)
  ).then {
    $0.type = .circleStrokeSpin
    $0.color = CHColors.light
    $0.isHidden = true
  }
  
  let textField = UITextField().then {
    $0.font = UIFont.systemFont(ofSize: Metric.fontSize)
    $0.textColor = .grey500
    $0.placeholder = CHAssets.localized("ch.profile_form.datetime_pick")
  }
  
  var date: Date? {
    didSet {
      let text = self.date?.fullDateString() ?? ""
      self.textField.text = text
    }
  }
  
  private let disposeBag = DisposeBag()
  var didFocus = false
  
  override func initialize() {
    super.initialize()
    
    self.layer.cornerRadius = Metric.cornerRadius
    self.layer.borderWidth = Metric.borderWidth
    self.layer.borderColor = CHColors.paleGrey20.cgColor
    
    self.addSubview(self.selectButton)
    self.addSubview(self.textField)
    self.addSubview(self.loadIndicator)
    
    NotificationCenter.default.rx
      .notification(Notification.Name.Channel.dismissKeyboard)
      .bind { [weak self] _ in
        self?.textField.resignFirstResponder()
      }.disposed(by: self.disposeBag)
    
    self.textField.delegate = self
    
    self.textField
      .signalForClick()
      .bind { [weak self] _ in
        self?.openDateSelector()
      }.disposed(by: self.disposeBag)
    
    self.selectButton
      .signalForClick()
      .bind { [weak self] _ in
        self?.openDateSelector()
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.textField.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.horizontalPadding)
      make.top.bottom.equalToSuperview()
    }
    
    self.selectButton.snp.makeConstraints { make in
      make.leading.equalTo(self.textField.snp.trailing)
      make.width.height.equalTo(Metric.selectButtonSize)
      make.trailing.equalToSuperview().inset(Metric.horizontalPadding)
      make.centerY.equalToSuperview()
    }
    
    self.loadIndicator.snp.makeConstraints { make in
      make.center.equalTo(self.selectButton.snp.center)
    }
  }
  
  private func openDateSelector() {
    UIApplication.shared.sendAction(
      #selector(UIApplication.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
    
    CHDateSelectorView
      .create(with: self.date)
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

