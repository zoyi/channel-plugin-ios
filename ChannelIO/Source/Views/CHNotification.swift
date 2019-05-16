//
//  CHNotification.swift
//  ChannelIO
//
//  Created by R3alFr3e on 5/15/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

struct CHNotificationConfiguration {
  var textColor: UIColor
  var font: UIFont
  var numberOfLines: Int
  var backgroundColor: UIColor
  var timeout: TimeInterval
  var alpha: CGFloat
  var margin: CGFloat
  
  static var succeedConfig: CHNotificationConfiguration {
    return CHNotificationConfiguration(
      textColor: .white,
      font: UIFont.boldSystemFont(ofSize: 13),
      numberOfLines: 2,
      backgroundColor: CHColors.shamrockGreen,
      timeout: 2.0,
      alpha: 0.85,
      margin: 60.f
    )
  }
  
  static var warningConfig: CHNotificationConfiguration {
    return CHNotificationConfiguration(
      textColor: .white,
      font: UIFont.boldSystemFont(ofSize: 13),
      numberOfLines: 2,
      backgroundColor: CHColors.yellowishOrange,
      timeout: 0,
      alpha: 1.f,
      margin: 60.f
    )
  }
}

class CHNotification {
  static let shared = CHNotification()
  
  private var notificationView: CHNotificationView?
  private var config = CHNotificationConfiguration.succeedConfig
  private var timer: Timer?
  private init(){}
  
  var refreshSignal = PublishRelay<Any?>()
  var disposeBag = DisposeBag()
  
  func display(message: String, config: CHNotificationConfiguration = CHNotificationConfiguration.succeedConfig) {
    guard let vc = CHUtils.getTopController() else { return }
    self.notificationView?.removeFromSuperview()
    
    let notificationView = CHNotificationView()
    notificationView.configure(self.config)
    notificationView.refreshView.signalForClick()
      .bind(to: self.refreshSignal)
      .disposed(by: self.disposeBag)
    
    vc.view.addSubview(notificationView)
    notificationView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(vc.view.safeAreaLayoutGuide.snp.top).offset(config.margin)
      } else {
        make.top.equalToSuperview().inset(config.margin)
      }
      make.leading.equalToSuperview().inset(8)
      make.trailing.equalToSuperview().inset(8)
    }
    
    notificationView.display(with: message)
    self.notificationView = notificationView
    
    self.timer?.invalidate()
    if config.timeout != 0 {
      self.timer = Timer.scheduledTimer(
        timeInterval: config.timeout,
        target: self,
        selector: #selector(dismiss),
        userInfo: nil,
        repeats: false)
    }
  }
  
  @objc private func dismiss() {
    UIView.animate(withDuration: 0.6, animations: { [weak self] in
      self?.notificationView?.alpha = 0
    }) { [weak self] (completed) in
      self?.notificationView?.removeFromSuperview()
    }
  }
}

private class CHNotificationView: BaseView {
  let contentView = UIView()
  let messageLabel = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = .white
  }
  
  let refreshView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "refresh")
  }
  
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.alpha = 0
    self.layer.cornerRadius = 10.f
    self.clipsToBounds = true
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOpacity = 0.4
    self.layer.shadowOffset = CGSize(width: 0, height: 4)
    self.layer.shadowRadius = 4
    
    self.addSubview(self.contentView)
    self.addSubview(self.messageLabel)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.messageLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12)
      make.leading.equalToSuperview().inset(12)
      make.bottom.equalToSuperview().inset(12)
    }
    
    self.refreshView.snp.makeConstraints { [weak self] (make) in
      guard let `self` = self else { return }
      make.leading.equalTo(self.messageLabel.snp.trailing).offset(10)
      make.trailing.equalToSuperview()
      make.centerY.equalToSuperview()
    }
  }
  
  func configure(_ model: CHNotificationConfiguration) {
    self.messageLabel.textColor = model.textColor
    self.messageLabel.font = model.font
    self.messageLabel.numberOfLines = model.numberOfLines
    self.contentView.backgroundColor = model.backgroundColor
    self.contentView.alpha = model.alpha
  }
  
  func display(with message: String) {
    self.messageLabel.text = message
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      self?.alpha = 1
    }
  }
}
