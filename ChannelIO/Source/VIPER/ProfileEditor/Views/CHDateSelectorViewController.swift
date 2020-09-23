//
//  CHDateSelectorViewController.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/22.
//  Copyright © 2020 ZOYI. All rights reserved.
//

//import RxSwift

class CHDateSelectorView: BaseView {
  private enum Metrics {
    static let fontSize = 16.f
    static let buttonSpacing = 5.f
    static let buttonHorizontalPadding = 16.f
    static let buttonVerticalPadding = 12.f
    static let topPadding = 24.f
    static let buttonRadius = 6.f
    static let pickerHeight = 190.f
    static let buttonHeight = 40.f
    static let pickerBottomPadding = 6.f
    static let selectorHeight = 284.f
    static let backgroundAlpha = 0.4.f
  }
  
  let backgroundView = UIView().then {
    $0.backgroundColor = CHColors.black
  }
  
  let containerView = UIView().then {
    $0.backgroundColor = CHColors.white
  }
  private var datePicker = UIDatePicker().then {
    $0.datePickerMode = .dateAndTime
    $0.setValue(UIColor.grey900, forKeyPath: "textColor")
  }

  private let confirmButton = UILabel().then {
    $0.text = CHAssets.localized("ch.settings.save")
    $0.font = .boldSystemFont(ofSize: Metrics.fontSize)
    $0.textColor = .white
    $0.textAlignment = .center
    $0.layer.cornerRadius = Metrics.buttonRadius
    $0.layer.backgroundColor = UIColor.blue400.cgColor
  }

  private var date: Date? = nil {
    didSet {
      self.datePicker.date = self.date ?? Date()
    }
  }
  
  private var submitSubject = _RXSwift_PublishSubject<Date>()
  private var cancelSubject = _RXSwift_PublishSubject<Any?>()
  
  private let disposeBag = _RXSwift_DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.containerView.addSubview(self.datePicker)
    self.containerView.addSubview(self.confirmButton)
    
    self.addSubview(self.backgroundView)
    self.addSubview(self.containerView)
    
    self.backgroundView
      .signalForClick()
      .bind { [weak self] _ in
        self?.cancelSubject.onNext(nil)
        self?.cancelSubject.onCompleted()
        self?.removeSelector(animated: true)
      }.disposed(by: self.disposeBag)

    self.confirmButton
      .signalForClick()
      .bind { [weak self] _ in
        if let date = self?.datePicker.date {
          self?.submitSubject.onNext(date)
          self?.submitSubject.onCompleted()
        } else {
          self?.cancelSubject.onNext(nil)
          self?.cancelSubject.onCompleted()
        }
        self?.removeSelector(animated: true)
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    self.backgroundView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      
      if #available(iOS 11.0, *) {
        let bottom = CHUtils.getKeyWindow()?.rootViewController?.view.safeAreaInsets.bottom ?? 0.f
        make.height.equalTo(Metrics.selectorHeight + bottom)
        make.bottom.equalToSuperview().inset(-Metrics.selectorHeight - bottom)
      } else {
        make.height.equalTo(Metrics.selectorHeight)
        make.bottom.equalToSuperview().inset(-Metrics.selectorHeight)
      }
    }
    
    self.datePicker.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.topPadding)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(Metrics.pickerHeight)
    }

    self.confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(Metrics.buttonHorizontalPadding)
      make.height.equalTo(Metrics.buttonHeight)
      make.top.equalTo(self.datePicker.snp.bottom)
        .offset(Metrics.pickerBottomPadding + Metrics.buttonVerticalPadding)
      make.bottom.equalToSuperview().inset(Metrics.buttonVerticalPadding)
      
      if #available(iOS 11.0, *) {
        let bottom = CHUtils.getKeyWindow()?.rootViewController?.view.safeAreaInsets.bottom ?? 0.f
        make.bottom.equalToSuperview().inset(Metrics.buttonVerticalPadding + bottom)
      } else {
        make.bottom.equalToSuperview().inset(Metrics.buttonVerticalPadding)
      }
    }
  }
  
  func signalForSubmit() -> _RXSwift_Observable<Date> {
    return self.submitSubject
  }
  
  func signalForCancel() -> _RXSwift_Observable<Any?> {
    return self.cancelSubject
  }

  static func create(with date: Date?) -> _RXSwift_Observable<(Date?)> {
    return _RXSwift_Observable.create { subscriber in
      guard var controller = CHUtils.getTopController() else { return _RXSwift_Disposables.create() }
      if let navigation = controller.navigationController {
        controller = navigation
      }
      
      let selectorView = CHDateSelectorView(frame: controller.view.frame)
      selectorView.date = date
      
      selectorView.showSelector(onView: controller.view, animated: true)
      let submitSignal = selectorView
        .signalForSubmit()
        .bind { date in
          subscriber.onNext(date)
          subscriber.onCompleted()
        }
      
      let cancelSignal = selectorView
        .signalForCancel()
        .bind { _ in
          subscriber.onNext(nil)
          subscriber.onCompleted()
        }
      
      return _RXSwift_Disposables.create {
        submitSignal.dispose()
        cancelSignal.dispose()
      }
    }
  }
}

extension CHDateSelectorView {
  private func showView(onView: UIView) {
    self.backgroundView.alpha = Metrics.backgroundAlpha
    self.containerView.snp.updateConstraints { make in
      make.bottom.equalToSuperview().inset(0)
    }
    onView.layoutIfNeeded()
  }
  
  func showSelector(onView: UIView, animated: Bool) {
    CHUtils.getTopNavigation()?.interactivePopGestureRecognizer?.isEnabled = false

    self.backgroundView.alpha = 0
    
    onView.addSubview(self)
    onView.layoutIfNeeded()
    
    if animated {
      UIView.animate(withDuration: 0.3) { [weak self] in
        self?.showView(onView: onView)
      }
    } else {
      self.showView(onView: onView)
    }
  }
  
  @objc func removeSelector(animated: Bool) {
    CHUtils.getTopNavigation()?.interactivePopGestureRecognizer?.isEnabled = true

    if !animated {
      self.removeFromSuperview()
      return
    }
    
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.backgroundView.alpha = 0
      self?.containerView.snp.updateConstraints { make in
        if #available(iOS 11.0, *) {
          let bottom = CHUtils
            .getKeyWindow()?
            .rootViewController?
            .view.safeAreaInsets
            .bottom ?? 0.f
          
          make.bottom
            .equalToSuperview()
            .inset(-Metrics.selectorHeight - bottom)
        } else {
          make.bottom
            .equalToSuperview()
            .inset(-Metrics.selectorHeight)
        }
      }
      self?.layoutIfNeeded()
    }) { [weak self] _ in
      self?.removeFromSuperview()
    }
  }
}
