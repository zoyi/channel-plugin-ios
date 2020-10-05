//
//  CHDateField.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/22.
//  Copyright © 2020 ZOYI. All rights reserved.
//

//import RxSwift
//import RxCocoa

final class CHDateField: BaseView {
  private enum Metric {
    static let dividerHeight = 0.5.f
    static let fieldLeading = 20.f
  }
  
  private let topDivider = UIView().then {
    $0.backgroundColor = UIColor.grey300
  }

  private let field = UITextField().then {
    $0.font = UIFont.systemFont(ofSize: 17)
    $0.textColor = UIColor.grey900
    $0.clearButtonMode = .always
  }

  private let botDivider = UIView().then {
    $0.backgroundColor = UIColor.grey300
  }
  
  private let validSubject = _RXRelay_PublishRelay<Bool>()
  private let changeSubject = _RXRelay_PublishRelay<String>()

  private var date: Date? {
    didSet {
      let text = self.date?.fullDateString() ?? ""
      self.setText(text)
      self.validSubject.accept(true)
      self.changeSubject.accept(text)
    }
  }

  private var disposeBag = _RXSwift_DisposeBag()

  convenience init(date: Date?) {
    self.init(frame: CGRect.zero)
    self.field.placeholder = CHAssets.localized("ch.profile_form.datetime_pick")
    self.field.delegate = self

    defer { // didSet 실행을 위해 사용
      self.date = date
    }
  }

  override func initialize() {
    super.initialize()
    
    self.field
      .signalForClick()
      .flatMap { [weak self] _ -> _RXSwift_Observable<(Date?)> in
        return CHDateSelectorView.create(with: self?.date)
      }
      .bind { [weak self] date in
        if let date = date {
          self?.date = date
        }
      }.disposed(by: self.disposeBag)

    self.backgroundColor = UIColor.white
    self.addSubview(self.field)
    self.addSubview(self.topDivider)
    self.addSubview(self.botDivider)
  }

  override func setLayouts() {
    super.setLayouts()

    self.topDivider.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(Metric.dividerHeight)
    }

    self.field.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.fieldLeading)
      make.trailing.equalToSuperview()
      make.top.bottom.equalToSuperview().inset(Metric.dividerHeight)
    }

    self.botDivider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(Metric.dividerHeight)
      make.height.equalTo(Metric.dividerHeight)
    }
  }

  @discardableResult
  override func becomeFirstResponder() -> Bool {
    return self.field.becomeFirstResponder()
  }
}

extension CHDateField: CHFieldDelegate {
  func getText() -> String {
    guard let time = self.date?.timeIntervalSince1970 else { return "" }
    return "\(Int64(time * 1000))"
  }

  func setText(_ value: String) {
    self.field.text = value
  }
  
  func isValid() -> _RXSwift_Observable<Bool> {
    return self.validSubject.asObservable()
  }
  
  func hasChanged() -> _RXSwift_Observable<String> {
    return self.changeSubject.asObservable()
  }
}

extension CHDateField: UITextFieldDelegate {
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    self.date = nil
    self.field.resignFirstResponder()
    return false
  }
}
