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
  var actionable: Bool
  var actionImage: UIImage?
  
  static var succeedConfig: CHNotificationConfiguration {
    return CHNotificationConfiguration(
      textColor: .white,
      font: UIFont.boldSystemFont(ofSize: 13),
      numberOfLines: 2,
      backgroundColor: .green400,
      timeout: 2.0,
      alpha: 0.85,
      margin: 44.f,
      actionable: false,
      actionImage: nil
    )
  }
  
  static var warningConfig: CHNotificationConfiguration {
    return CHNotificationConfiguration(
      textColor: .white,
      font: UIFont.boldSystemFont(ofSize: 13),
      numberOfLines: 2,
      backgroundColor: .orange400,
      timeout: 0,
      alpha: 1.f,
      margin: 44.f,
      actionable: true,
      actionImage: CHAssets.getImage(named: "refresh")
    )
  }
  
  static var warningNormalConfig: CHNotificationConfiguration {
    return CHNotificationConfiguration(
      textColor: .white,
      font: UIFont.boldSystemFont(ofSize: 13),
      numberOfLines: 2,
      backgroundColor: .orange400,
      timeout: 0,
      alpha: 1.f,
      margin: 10.f,
      actionable: true,
      actionImage: CHAssets.getImage(named: "refresh")
    )
  }
  
  static var warningServerErrorConfig: CHNotificationConfiguration {
    return CHNotificationConfiguration(
      textColor: .white,
      font: UIFont.boldSystemFont(ofSize: 13),
      numberOfLines: 2,
      backgroundColor: .orange400,
      timeout: 3,
      alpha: 1.f,
      margin: 2.f,
      actionable: false
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
    guard let vc = CHUtils.getTopController(), mainStore.state.uiState.isChannelVisible else { return }
    self.notificationView?.removeFromSuperview()
    
    let notificationView = CHNotificationView()
    notificationView.configure(config)
    notificationView.refreshView.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        self?.refreshSignal.accept(nil)
      })
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
    self.config = config
    
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
  
  @objc func dismiss() {
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
  
  let refreshView = UIImageView()
  
  var disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.alpha = 0
    self.contentView.layer.cornerRadius = 10.f

    self.layer.shadowColor = UIColor.grey900.cgColor
    self.layer.shadowOpacity = 0.4
    self.layer.shadowOffset = CGSize(width: 0, height: 4)
    self.layer.shadowRadius = 4
    
    self.addSubview(self.contentView)
    self.addSubview(self.messageLabel)
    self.addSubview(self.refreshView)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.messageLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12)
      make.leading.equalToSuperview().inset(12).priority(750)
      make.centerX.equalToSuperview()
      make.trailing.equalToSuperview().inset(12).priority(750)
      make.bottom.equalToSuperview().inset(12)
    }
    
    self.refreshView.snp.makeConstraints { (make) in
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
    self.refreshView.isHidden = !model.actionable
    self.refreshView.image = model.actionImage
  }
  
  func display(with message: String) {
    self.messageLabel.text = message
    
    UIView.animate(withDuration: 0.3) { [weak self] in
      self?.alpha = 1
    }
  }
}
