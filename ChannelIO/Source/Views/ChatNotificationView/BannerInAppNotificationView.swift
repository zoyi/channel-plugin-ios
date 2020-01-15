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
    static let containerViewHeight = 78.f
    static let avatarLength = 44.f
    static let avatarLeading = 12.f
    static let nameLabelBottom = 2.f
    static let nameLabelHeight = 16.f
    static let closeImageLength = 18.f
    static let closeButtonViewWidth = 42.f
    static let rightStackTrailing = -4.f
    static let rightStackSide = 12.f
    static let containerViewSide = 10.f
    static let containerBottom = 10.f
  }
  
  private struct Constants {
    static let maxLineWithOnlyText = 2
    static let maxLineWithFileInfo = 1
  }
  
  let notiType: InAppNotificationType = .banner
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 8.f
    $0.backgroundColor = .white
    $0.clipsToBounds = true
  }
  
  private let leftStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .center
  }
  private let avatarView = AvatarView()
  
  private let mediaView = InAppMediaView()
  
  private let rightStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .top
  }
  
  private let nameContainerView = UIView()
  private let nameLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 12)
    $0.textColor = .grey900
  }

  private let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    
    $0.font = UIFont.systemFont(ofSize: 13)
    $0.textColor = UIColor.grey900
    $0.textContainer.maximumNumberOfLines = 1
    $0.textContainer.lineBreakMode = .byTruncatingTail
    
    $0.dataDetectorTypes = [.link, .phoneNumber]
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    $0.linkTextAttributes = [
      .foregroundColor: CHColors.cobalt,
      .underlineStyle: 0
    ]
  }
  
  private let fileInfoView = AttachmentFileInfoView()
  
  private let closeContainerView = UIView()
    
  private let closeImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "cancel")
  }
  private var chatSignal = PublishSubject<Any?>()
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.leftStackView)
    self.containerView.addSubview(self.rightStackView)
    self.leftStackView.addArrangedSubview(self.avatarView)
    self.leftStackView.addArrangedSubview(self.mediaView)
    self.nameContainerView.addSubview(self.nameLabel)
    self.rightStackView.addArrangedSubview(self.nameContainerView)
    self.rightStackView.addArrangedSubview(self.messageView)
    self.rightStackView.addArrangedSubview(self.fileInfoView)
    self.closeContainerView.addSubview(self.closeImageView)
    self.containerView.addSubview(self.closeContainerView)
    
    self.messageView.delegate = self
    
    self.rx.observeWeakly(CGRect.self, "bounds")
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (bounds) in
        self?.layer.applySketchShadow(
          color: .black15, alpha: 1, x: 0, y: 3, blur: 12, spread: 1
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
    
    self.containerView.snp.makeConstraints { make in
      make.height.equalTo(Metrics.containerViewHeight)
      make.top.bottom.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(Metrics.containerViewSide)
    }
    
    self.leftStackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.equalToSuperview()
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.bottom.equalToSuperview().inset(Metrics.nameLabelBottom)
      make.height.equalTo(Metrics.nameLabelHeight)
    }
    
    self.rightStackView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(Metrics.rightStackSide)
      make.bottom.lessThanOrEqualToSuperview().inset(Metrics.rightStackSide)
      make.leading.equalTo(self.leftStackView.snp.trailing)
        .offset(Metrics.rightStackSide)
      make.trailing.equalTo(self.closeContainerView.snp.leading)
        .offset(Metrics.rightStackTrailing)
    }
    
    self.avatarView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metrics.avatarLeading)
      make.centerY.equalToSuperview()
      make.width.equalTo(Metrics.avatarLength)
      make.height.equalTo(Metrics.avatarLength)
    }
    
    self.closeImageView.snp.makeConstraints { make in
      make.width.equalTo(Metrics.closeImageLength)
      make.height.equalTo(Metrics.closeImageLength)
      make.centerX.centerY.equalToSuperview()
    }
    
    self.closeContainerView.snp.makeConstraints { make in
      make.top.bottom.trailing.equalToSuperview()
      make.width.equalTo(Metrics.closeButtonViewWidth)
    }
  }
  
  func configure(with viewModel: InAppNotificationViewModel) {
    self.avatarView.configure(viewModel.avatar)
    self.nameLabel.text = viewModel.name
    self.fileInfoView.configure(with: viewModel.files, isLarge: false)
    self.mediaView.configure(model: viewModel)
    self.messageView.attributedText = viewModel.message
    
    var hasMessage = false
    if let message = viewModel.message {
      hasMessage = message != NSAttributedString(string: "")
    }
    
    self.messageView.isHidden = !hasMessage ? true : false
    if viewModel.hasMedia {
      self.fileInfoView.isHidden = !hasMessage ? false : true
      self.messageView.textContainer.maximumNumberOfLines = Constants.maxLineWithFileInfo
    } else {
      self.fileInfoView.isHidden = viewModel.files.count > 0 ? false : true
      self.messageView.textContainer.maximumNumberOfLines = viewModel.files.count > 0 ?
        Constants.maxLineWithFileInfo : Constants.maxLineWithOnlyText
    }
    self.avatarView.isHidden = viewModel.hasMedia
    self.mediaView.isHidden = !viewModel.hasMedia
  }
  
  func insertView(on view: UIView) {
    if let superview = self.superview, superview != view {
      self.removeFromSuperview()
    }
    if self.superview != view {
      self.insert(on: view, animated: true)
    }
    
    let maxWidth = 520.f
    
    self.snp.makeConstraints { make in
      if view.bounds.width > maxWidth {
        make.centerX.equalToSuperview()
        make.width.equalTo(maxWidth)
      } else {
        make.leading.equalToSuperview()
        make.trailing.equalToSuperview()
      }
      
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
          .inset(Metrics.containerBottom)
      } else {
        make.bottom.equalToSuperview().inset(Metrics.containerBottom)
      }
    }
  }
  
  func signalForChat() -> Observable<Any?> {
    self.chatSignal = PublishSubject<Any?>()
    return self.chatSignal.asObservable()
  }
  
  func signalForClose() -> Observable<Any?> {
    return self.closeContainerView.signalForClick()
  }
  
  func removeView(animated: Bool) {
    self.remove(animated: animated)
  }
}

extension BannerInAppNotificationView : UITextViewDelegate {
  func textView(
    _ textView: UITextView,
    shouldInteractWith URL: URL,
    in characterRange: NSRange,
    interaction: UITextItemInteraction) -> Bool {
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
