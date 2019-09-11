//
//  BannerInAppNotificationView.swift
//  ChannelIO
//
//  Created by Jam on 01/08/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class BannerInAppNotificationView: BaseView, InAppNotification {
  private struct Metrics {
    static let closeButtonHeight = 28.f
    static let closeLeading = 10.f
    static let containerTop = 6.f
    static let containerLeading = 10.f
    static let containerTrailing = 10.f
    static let containerBottom = 12.f
    static let contentSide = 14.f
    static let messageTop = 10.f
    static let writerTop = 4.f
    static let contentBottom = 10.f
    static let avatarSize = CGSize(width: 24.f, height: 24.f)
    static let buttonTopBottom = 17.f
    static let buttonSide = 14.f
    static let buttonSize = CGSize(width: 34.f, height: 34.f)
    static let imageSize = CGSize(width: 66.f, height: 66.f)
    static let imageSide = 10.f
  }
  
  let notiType: InAppNotificationType = .banner
  
  private let closeButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "exitSmall"), for: .normal)
    $0.setTitle(CHAssets.localized("ch.button_close"), for: .normal)
    $0.setTitleColor(.grey500, for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    
    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 12)
    $0.imageEdgeInsets = UIEdgeInsets(top:0, left: -8, bottom: 0, right: 0)
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 14
  }
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 10.f                                    
    $0.backgroundColor = .white
  }
  private let contentView = UIStackView().then {
    $0.axis = .horizontal
  }
  
  private let mainContentView = UIView()
  private let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = UIColor.grey900
    $0.textContainer.maximumNumberOfLines = 2
    $0.textContainer.lineBreakMode = .byTruncatingTail
    
    $0.dataDetectorTypes = [.link, .phoneNumber]
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    
    $0.linkTextAttributes = [
      .foregroundColor: CHColors.cobalt,
      .underlineStyle: 0
    ]
  }
  
  private let writerInfoStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6
    $0.distribution = .fill
  }
  
  private let avatarView = AvatarView()
  private let nameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 12)
    $0.textColor = .grey900
  }
  private let timestampLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = .grey500
  }
  
  private let sideContentView = UIView()
  private let redirectImageView = UIImageView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 10.f
  }
  private let redirectButton = UIButton().then {
    $0.layer.borderWidth = 1.f
    $0.layer.borderColor = UIColor.black5.cgColor
    $0.layer.cornerRadius = 17.f
  }
  
  private var chatSignal = PublishSubject<Any?>()
  private var redirectSignal = PublishSubject<String?>()
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.closeButton)
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.contentView)
    
    self.mainContentView.addSubview(self.messageView)
    self.mainContentView.addSubview(self.writerInfoStackView)
    self.writerInfoStackView.addArrangedSubview(self.avatarView)
    self.writerInfoStackView.addArrangedSubview(self.nameLabel)
    self.writerInfoStackView.addArrangedSubview(self.timestampLabel)
    self.sideContentView.addSubview(self.redirectImageView)
    self.sideContentView.addSubview(self.redirectButton)
    self.contentView.addArrangedSubview(self.mainContentView)
    self.contentView.addArrangedSubview(self.sideContentView)
    
    self.containerView.clipsToBounds = false
    self.messageView.delegate = self
    
    self.containerView.rx.observeWeakly(CGRect.self, "bounds")
      .subscribe(onNext: { [weak self] (bounds) in
        self?.containerView.layer.applySketchShadow(
          color: .black15, alpha: 1, x: 0, y: 3, blur: 12, spread: 1
        )
      }).disposed(by: self.disposeBag)
    
    self.closeButton.rx.observeWeakly(CGRect.self, "bounds")
      .subscribe(onNext: { [weak self] (bounds) in
        self?.closeButton.layer.applySketchShadow(
          color: .black15, alpha: 1, x: 0, y: 2, blur: 3, spread: 1
        )
      }).disposed(by: self.disposeBag)
    
    self.signalForClick().subscribe(onNext: { [weak self] (_) in
      self?.chatSignal.onNext(nil)
      self?.chatSignal.onCompleted()
    }).disposed(by: self.disposeBag)
    
    self.messageView.signalForClick().subscribe(onNext: { [weak self] (_) in
      self?.chatSignal.onNext(nil)
      self?.chatSignal.onCompleted()
    }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.closeButton.snp.makeConstraints { (make) in
      make.height.equalTo(Metrics.closeButtonHeight)
      make.top.equalToSuperview()
      make.leading.equalToSuperview().inset(Metrics.closeLeading)
    }
    
    self.containerView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.containerLeading)
      make.trailing.equalToSuperview().inset(Metrics.containerTrailing)
      make.top.equalTo(self.closeButton.snp.bottom).offset(Metrics.containerTop)
      make.bottom.equalToSuperview().inset(Metrics.containerBottom)
    }
    
    self.contentView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.messageView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.contentSide)
      make.top.equalToSuperview().inset(Metrics.messageTop)
      make.trailing.equalToSuperview().inset(Metrics.contentSide)
    }
    
    self.writerInfoStackView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.contentSide)
      make.top.equalTo(self.messageView.snp.bottom).offset(Metrics.writerTop)
      make.trailing.lessThanOrEqualToSuperview().inset(Metrics.contentSide)
      make.bottom.equalToSuperview().inset(Metrics.contentBottom)
    }
    
    self.avatarView.snp.makeConstraints { (make) in
      make.size.equalTo(Metrics.avatarSize)
    }
  }
  
  func configure(with viewModel: InAppNotificationViewModel) {
    self.messageView.attributedText = viewModel.message
    self.avatarView.configure(viewModel.avatar)
    self.nameLabel.text = viewModel.avatar?.name
    self.timestampLabel.text = viewModel.timestamp
    
    if let _ = viewModel.buttonTitle {
      self.configureForButton(viewModel)
    } else if let url = viewModel.imageUrl {
      self.configureForImage(viewModel, url: url)
    } else {
      self.sideContentView.isHidden = true
    }
  }
  
  private func configureForButton(_ viewModel: InAppNotificationViewModel) {
    self.sideContentView.isHidden = false
    self.sideContentView.subviews.forEach { $0.removeFromSuperview() }
    self.sideContentView.addSubview(self.redirectButton)
    self.redirectButton.snp.remakeConstraints { (make) in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
      make.top.greaterThanOrEqualToSuperview().inset(Metrics.buttonTopBottom)
      make.bottom.lessThanOrEqualToSuperview().inset(Metrics.buttonTopBottom)
      make.leading.equalToSuperview().inset(Metrics.buttonSide)
      make.trailing.equalToSuperview().inset(Metrics.buttonSide)
      make.size.equalTo(Metrics.buttonSize)
    }
    
    let image = viewModel.pluginTextColor == CHColors.white ?
      CHAssets.getImage(named: "arrowRightWh") :
      CHAssets.getImage(named: "arrowRightBk")
    
    self.redirectButton.setImage(image, for: .normal)
    self.redirectButton.backgroundColor = viewModel.themeColor
    self.redirectButton.signalForClick().subscribe(onNext: { [weak self]  (_) in
      if let url = viewModel.buttonRedirect, url != "" {
        self?.redirectSignal.onNext(url)
        self?.redirectSignal.onCompleted()
      } else {
        self?.chatSignal.onNext(nil)
        self?.chatSignal.onCompleted()
      }
    }).disposed(by: self.disposeBag)
  }

  private func configureForImage(_ viewModel: InAppNotificationViewModel, url: URL) {
    self.sideContentView.isHidden = false
    self.sideContentView.subviews.forEach { $0.removeFromSuperview() }
    self.sideContentView.addSubview(self.redirectImageView)
    self.redirectImageView.snp.remakeConstraints { (make) in
      make.size.equalTo(Metrics.imageSize)
      make.top.equalToSuperview().inset(Metrics.imageSide)
      make.trailing.equalToSuperview().inset(Metrics.imageSide)
      make.leading.equalToSuperview().inset(Metrics.imageSide)
      make.bottom.equalToSuperview().inset(Metrics.imageSide)
    }
    
    self.redirectImageView.sd_setImage(with: url)
    self.redirectImageView.signalForClick().subscribe(onNext: { [weak self]  (_) in
      if let url = viewModel.imageRedirect, url != "" {
        self?.redirectSignal.onNext(url)
        self?.redirectSignal.onCompleted()
      } else {
        self?.chatSignal.onNext(nil)
        self?.chatSignal.onCompleted()
      }
    }).disposed(by: self.disposeBag)
  }
  
  func insertView(on view: UIView) {
    if let superview = self.superview, superview != view {
      self.removeFromSuperview()
    }
    if self.superview != view {
      self.insert(on: view, animated: true)
    }
    
    let maxWidth = 520.f
    
    self.snp.makeConstraints({ (make) in
      if UIScreen.main.bounds.width > maxWidth {
        make.centerX.equalToSuperview()
        make.width.equalTo(maxWidth)
      } else {
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
      }
      
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      } else {
        make.bottom.equalToSuperview()
      }
    })
  }
  
  func signalForRedirect() -> Observable<String?> {
    self.redirectSignal = PublishSubject<String?>()
    return self.redirectSignal.asObservable()
  }
  
  func signalForChat() -> Observable<Any?> {
    self.chatSignal = PublishSubject<Any?>()
    return self.chatSignal.asObservable()
  }
  
  func signalForClose() -> Observable<Any?> {
    return self.closeButton.signalForClick()
  }
  
  func removeView(animated: Bool) {
    self.remove(animated: animated)
  }
}

extension BannerInAppNotificationView : UITextViewDelegate {
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange) -> Bool {
    let shouldhandle = ChannelIO.delegate?.onClickChatLink?(url: URL)
    return shouldhandle == true || shouldhandle == nil
  }
  
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    if interaction == .invokeDefaultAction {
      let handled = ChannelIO.delegate?.onClickChatLink?(url: URL)
      if handled == false || handled == nil {
        URL.openWithUniversal()
      }
      return false
    }
    
    return true
  }
}
