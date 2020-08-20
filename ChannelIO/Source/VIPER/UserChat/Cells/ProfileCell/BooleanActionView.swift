//
//  BooleanActionView.swift
//  ChannelIO
//
//  Created by 김진학 on 2020/07/23.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import RxSwift
import SnapKit
import RxCocoa
import NVActivityIndicatorView

final class BooleanActionView: BaseView {
  private enum Metric {
    static let indicatorSize = 20.f
    static let borderWidth = 1.f
    static let cornerRadius = 5.f
    static let buttonWidth = 148.5.f
    static let dividerWidth = 1.f
  }
  
  private let submitSubject = PublishSubject<Any?>()
  private let focusSubject = PublishSubject<Bool>()
  
  private let yesBackground = UIView()
  
  private let yesLabel = UILabel().then {
    $0.text = CHAssets.localized("ch.profile_form.boolean.yes")
    $0.textColor = .grey500
  }
  
  private let noBackground = UIView()
  
  private let noLabel = UILabel().then {
    $0.text = CHAssets.localized("ch.profile_form.boolean.no")
    $0.textColor = .grey500
  }
  
  private let verticalDivider = UIView().then {
    $0.backgroundColor = .grey300
  }
  
  private let loadIndicator = NVActivityIndicatorView(
    frame: CGRect(x: 0, y: 0, width: Metric.indicatorSize, height:  Metric.indicatorSize)
  ).then {
    $0.type = .circleStrokeSpin
    $0.color = .grey500
    $0.isHidden = true
  }
  
  private var yesLoadIndicatorConstraint: Constraint?
  private var noLoadIndicatorConstraint: Constraint?
  
  private let disposeBag = DisposeBag()
  var selectedValue: Bool? {
    didSet {
      self.yesBackground.layer.backgroundColor = UIColor.white.cgColor
      self.yesLabel.textColor = .grey300

      self.noBackground.layer.backgroundColor = UIColor.white.cgColor
      self.noLabel.textColor = .grey300
      
      if self.selectedValue == true {
        self.yesBackground.layer.backgroundColor = UIColor.grey300.cgColor
        self.yesLabel.textColor = .white

        self.yesLoadIndicatorConstraint?.activate()
        self.noLoadIndicatorConstraint?.deactivate()
      } else if self.selectedValue == false {
        self.noBackground.layer.backgroundColor = UIColor.grey300.cgColor
        self.noLabel.textColor = .white

        self.yesLoadIndicatorConstraint?.deactivate()
        self.noLoadIndicatorConstraint?.activate()
      }
    }
  }
  var didFocus: Bool = false
  
  override func initialize() {
    super.initialize()
    
    self.layer.borderColor = UIColor.grey300.cgColor
    self.layer.borderWidth = Metric.borderWidth
    self.layer.cornerRadius = Metric.cornerRadius
    self.layer.masksToBounds = true
    
    self.addSubview(self.yesBackground)
    self.addSubview(self.yesLabel)
    self.addSubview(self.verticalDivider)
    self.addSubview(self.noBackground)
    self.addSubview(self.noLabel)
    self.addSubview(self.loadIndicator)
    
    self.yesBackground
      .signalForClick()
      .bind { [weak self] _ in
        self?.selectedValue = true
        self?.submitSubject.onNext(true)
      }.disposed(by: self.disposeBag)
    
    self.noBackground
      .signalForClick()
      .bind { [weak self] _ in
        self?.selectedValue = false
        self?.submitSubject.onNext(false)
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    self.yesBackground.snp.makeConstraints { make in
      make.width.equalTo(Metric.buttonWidth)
      make.top.bottom.leading.equalToSuperview()
      make.trailing.equalTo(self.verticalDivider.snp.leading)
    }
    
    self.yesLabel.snp.makeConstraints { make in
      make.center.equalTo(self.yesBackground)
    }
    
    self.verticalDivider.snp.makeConstraints { make in
      make.width.equalTo(Metric.dividerWidth)
      make.top.bottom.equalToSuperview()
      make.trailing.equalTo(noBackground.snp.leading)
    }
    
    self.noBackground.snp.makeConstraints { make in
      make.width.equalTo(Metric.buttonWidth)
      make.top.bottom.trailing.equalToSuperview()
    }
    
    self.noLabel.snp.makeConstraints { make in
      make.center.equalTo(self.noBackground)
    }
    
    self.loadIndicator.snp.makeConstraints { make in
      self.yesLoadIndicatorConstraint = make.center.equalTo(self.yesBackground).constraint
      self.noLoadIndicatorConstraint = make.center.equalTo(self.noBackground).constraint
    }
  }
}

extension BooleanActionView: Actionable {
  func signalForAction() -> Observable<Any?> {
    return self.submitSubject
  }
  
  func signalForText() -> Observable<String?>? {
    return nil
  }
  
  func signalForFocus() -> Observable<Bool> {
    return self.focusSubject
  }
  
  func setLoading() {
    self.yesLabel.isHidden = self.selectedValue == true
    self.noLabel.isHidden = self.selectedValue == false
    
    self.yesBackground.gestureRecognizers?.forEach({ gesture in
      self.yesBackground.removeGestureRecognizer(gesture)
    })
    
    self.noBackground.gestureRecognizers?.forEach({ gesture in
      self.noBackground.removeGestureRecognizer(gesture)
    })
    
    self.loadIndicator.isHidden = false
    self.loadIndicator.startAnimating()
  }
  
  func setFocus() {
    self.layer.borderColor = UIColor.cobalt400.cgColor
    self.focusSubject.onNext(true)
  }
  
  func setOutFocus() {
    self.layer.borderColor = UIColor.grey200.cgColor
    self.focusSubject.onNext(false)
  }
  
  func setInvalid() {
    self.layer.borderColor = UIColor.orange400.cgColor
    self.loadIndicator.isHidden = true
  }
}
