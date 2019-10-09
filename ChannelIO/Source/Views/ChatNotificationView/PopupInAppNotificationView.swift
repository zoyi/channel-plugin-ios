//
//  PopupInAppNotificationView.swift
//  ChannelIO
//
//  Created by Jam on 01/08/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit

class PopupInAppNotificationView: BaseView, InAppNotification {
  private struct Metrics {
    static let containerWidth = 320.f
    static let buttonViewTop = 8.f
    static let closeButtonTop = 2.f
    static let closeButtonTrailing = 2.f
    static let imageTop = -8.f
    static let contentSide = 18.f
    static let messageTop = 8.f
    static let writerTop = 14.f
    static let contentBottom = 18.f
    static let closeSize = CGSize(width: 44.f, height: 44.f)
    static let avatarSize = CGSize(width: 34.f, height: 34.f)
    static let buttonSize = CGSize(width: 320.f, height: 38.f)
    static let imageSize = CGSize(width: 320.f, height: 176.f)
    static let imageSide = 4.f
    static let imageBottom = 4.f
  }
  
  let notiType : InAppNotificationType = .popup
  
  private let closeButton = UIButton().then {
    $0.setImage(CHAssets.getImage(named: "exitPopup"), for: .normal)
    $0.backgroundColor = .white
  }
  
  private let dimView = UIView().then {
    $0.backgroundColor = .black10
  }
  
  private let containerView = UIView()
  
  private let contentView = UIView().then {
    $0.layer.cornerRadius = 8.f
    $0.backgroundColor = .white
  }
  
  private let buttonView = UIView().then {
    $0.layer.cornerRadius = 8.f
    $0.backgroundColor = .white
  }
  private let mainContentView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let infoView = UIView()
  private let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textColor = UIColor.grey900
    $0.textContainer.maximumNumberOfLines = 9
    $0.textContainer.lineBreakMode = .byTruncatingTail
    $0.dataDetectorTypes = [.link, .phoneNumber]
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
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
  
  private let imageView = UIView()
  private let redirectImageView = UIImageView().then {
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 8.f
  }
  private let redirectButton = UIButton().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8.f
    $0.setTitleColor(.cobalt400, for: .normal)
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    $0.titleLabel?.lineBreakMode = .byTruncatingTail
    $0.titleLabel?.numberOfLines = 1
  }
  
  private var chatSignal = PublishSubject<Any?>()
  private var redirectSignal = PublishSubject<String?>()
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.dimView)
    self.dimView.addSubview(self.containerView)
    self.containerView.addSubview(self.contentView)
    self.contentView.addSubview(self.mainContentView)
    
    self.infoView.addSubview(self.writerInfoStackView)
    self.infoView.addSubview(self.closeButton)
    self.infoView.addSubview(self.messageView)
    
    self.writerInfoStackView.addArrangedSubview(self.avatarView)
    self.writerInfoStackView.addArrangedSubview(self.nameLabel)
    self.writerInfoStackView.addArrangedSubview(self.timestampLabel)
    
    self.imageView.addSubview(self.redirectImageView)
    self.buttonView.addSubview(self.redirectButton)
    
    self.mainContentView.addArrangedSubview(self.infoView)
    self.mainContentView.addArrangedSubview(self.imageView)
    self.containerView.addSubview(self.buttonView)
    
    self.contentView.clipsToBounds = false
    self.messageView.delegate = self
    
    self.contentView.rx.observeWeakly(CGRect.self, "bounds")
      .subscribe(onNext: { [weak self] (bounds) in
        self?.containerView.layer.applySketchShadow(
          color: .black15, alpha: 1, x: 0, y: 3, blur: 12, spread: 1
        )
      }).disposed(by: self.disposeBag)

    self.containerView.signalForClick().subscribe(onNext: { [weak self] (_) in
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
    
    self.dimView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.containerView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.equalTo(Metrics.containerWidth)
    }
    
    self.contentView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.buttonView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView.snp.bottom).offset(Metrics.buttonViewTop)
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
    }

    self.mainContentView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    self.writerInfoStackView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.contentSide)
      make.top.equalToSuperview().inset(Metrics.writerTop)
      make.trailing.lessThanOrEqualTo(self.closeButton.snp.leading).offset(Metrics.contentSide)
    }
    
    self.closeButton.snp.makeConstraints { (make) in
      make.size.equalTo(Metrics.closeSize)
      make.trailing.equalToSuperview().inset(Metrics.closeButtonTrailing)
      make.top.equalToSuperview().inset(Metrics.closeButtonTop)
    }
    
    self.messageView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.contentSide)
      make.top.equalTo(self.writerInfoStackView.snp.bottom).offset(Metrics.messageTop)
      make.trailing.equalToSuperview().inset(Metrics.contentSide)
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
      self.imageView.isHidden = true
    }
  }
  
  private func configureForButton(_ viewModel: InAppNotificationViewModel) {
    self.messageView.textContainer.maximumNumberOfLines = 6
    self.buttonView.isHidden = false
    self.buttonView.addSubview(self.redirectButton)
    self.contentView.snp.remakeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    self.redirectButton.setTitle(viewModel.buttonTitle, for: .normal)
    self.redirectButton.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
      make.size.equalTo(Metrics.buttonSize)
    }
    
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
    self.messageView.textContainer.maximumNumberOfLines = 6
    self.imageView.isHidden = false
    self.imageView.addSubview(self.redirectImageView)
    self.redirectImageView.snp.makeConstraints { (make) in
      make.size.equalTo(Metrics.imageSize)
      make.top.equalToSuperview().inset(Metrics.imageTop)
      make.trailing.equalToSuperview().inset(Metrics.imageSide)
      make.leading.equalToSuperview().inset(Metrics.imageSide)
      make.bottom.equalToSuperview().inset(Metrics.imageBottom)
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
    
    self.snp.makeConstraints({ (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      } else {
        make.top.equalToSuperview()
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

extension PopupInAppNotificationView : UITextViewDelegate {
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
