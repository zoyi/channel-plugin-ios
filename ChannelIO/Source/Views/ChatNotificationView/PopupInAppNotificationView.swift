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
  private struct Metric {
    static let containerWidth = 320.f
    static let closeImageViewLength = 16.f
    static let closeContainerCenterYInset = -2.f
    static let closeContainerLength = 24.f
    static let closeContainerLeading = 8.f
    static let closeContainerTrailing = 12.f
    static let closeClickWidth = 44.f
    static let buttonHeight = 36.f
    static let buttonContainerHeight = 44.f
    static let buttonStackSide = 12.f
    static let headerViewLeading = 8.f
    static let headerViewHeight = 46.f
    static let headerCenterYInset = -2.f
    static let avatarViewTraling = 8.f
    static let nameViewTrailing = 6.f
    static let avatarViewLength = 24.f
    static let contentSide = 12.f
    static let messageTop = -4.f
    static let infoViewBottom = 12.f
  }
  
  private let mediaContainerView = UIView().then {
    $0.clipsToBounds = true
  }
  private struct Constants {
    static let maxLineWithMedia = 4
    static let maxLineWithoutMedia = 8
  }
  
  private let dimView = UIView().then {
    $0.backgroundColor = .black40
  }
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 10.f
    $0.backgroundColor = .white
    $0.clipsToBounds = true
  }
  private let mainContentView = UIStackView().then {
    $0.axis = .vertical
    $0.clipsToBounds = true
  }
  private let headerView = UIView()
  private let userInfoStackView = UIStackView().then {
    $0.axis = .horizontal
  }
  private let infoView = UIView()
  private let messageContainerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6.f
  }
  private let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.isSelectable = true
    $0.isUserInteractionEnabled = false
    $0.font = UIFont.systemFont(ofSize: 15)
    $0.textColor = UIColor.grey900
    $0.backgroundColor = .white
    $0.textContainer.maximumNumberOfLines = 8
    $0.textContainer.lineBreakMode = .byTruncatingTail
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    $0.linkTextAttributes = [
      .foregroundColor: UIColor.cobalt400,
      .underlineStyle: 0
    ]
  }
  private let fileInfoView = AttachmentFileInfoView()
  private let closeClickView = UIView()
  private let closeContainerView = UIView().then {
    $0.layer.cornerRadius = 12
    $0.backgroundColor = .black5
  }
  private let closeImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "cancel")
  }
  private let mediaView = InAppMediaView().then {
    $0.backgroundColor = .white
    $0.clipsToBounds = true
  }
  private let avatarView = AvatarView().then {
    $0.isRound = false
    $0.avatarImageView.layer.cornerRadius = 8.f
  }
  private let nameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = .grey900
  }
  private let timeLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = .grey500
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue:1000), for: .horizontal)
  }
  private let buttonContainerView = UIView().then {
    $0.isHidden = true
  }
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6.f
    $0.distribution = .fillEqually
  }
  private let firstButtonView = UILabel().then {
    $0.layer.cornerRadius = 6.f
    $0.clipsToBounds = true
    $0.isHidden = true
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textAlignment = .center
  }
  private let secondButtonView = UILabel().then {
    $0.layer.cornerRadius = 6.f
    $0.clipsToBounds = true
    $0.isHidden = true
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textAlignment = .center
  }
  
  let notiType : InAppNotificationType = .fullScreen
  private var chatSignal = PublishSubject<Any?>()
  private var closeSignal = PublishSubject<Any?>()
  private var mkInfo: MarketingInfo?
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.dimView)
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.mainContentView)
    
    self.messageContainerView.addArrangedSubview(self.messageView)
    self.messageContainerView.addArrangedSubview(self.fileInfoView)
    self.infoView.addSubview(self.messageContainerView)
    
    self.headerView.addSubview(self.userInfoStackView)
    self.userInfoStackView.addArrangedSubview(self.avatarView)
    self.userInfoStackView.addArrangedSubview(self.nameLabel)
    self.userInfoStackView.addArrangedSubview(self.timeLabel)
    self.headerView.addSubview(self.closeClickView)
    self.closeClickView.addSubview(self.closeContainerView)
    self.closeContainerView.addSubview(self.closeImageView)
    
    self.buttonContainerView.addSubview(self.buttonStackView)
    self.buttonStackView.addArrangedSubview(self.firstButtonView)
    self.buttonStackView.addArrangedSubview(self.secondButtonView)
    
    self.mediaContainerView.addSubview(self.mediaView)
    
    self.mainContentView.addArrangedSubview(self.headerView)
    self.mainContentView.addArrangedSubview(self.infoView)
    self.mainContentView.addArrangedSubview(self.buttonContainerView)
    self.mainContentView.addArrangedSubview(self.mediaContainerView)
    
    self.layer.zPosition = 1
    
    self.messageView.delegate = self
    
    self.containerView.rx.observeWeakly(CGRect.self, "bounds")
      .subscribe(onNext: { [weak self] (bounds) in
        self?.containerView.layer.applySketchShadow(
          color: .black15, alpha: 1, x: 0, y: 3, blur: 12, spread: 1
        )
      }).disposed(by: self.disposeBag)

    self.containerView
      .signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        self?.chatSignal.onNext(nil)
        self?.chatSignal.onCompleted()
      }).disposed(by: self.disposeBag)
    
    self.closeClickView
      .signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        guard let self = self else { return }
        self.closeSignal.onNext(nil)
        self.closeSignal.onCompleted()
      }).disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.dimView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.containerView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.width.equalTo(Metric.containerWidth)
    }

    self.mainContentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.headerView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.headerViewLeading)
      make.top.trailing.equalToSuperview()
      make.height.equalTo(Metric.headerViewHeight)
    }
    
    self.infoView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
    }
    
    self.userInfoStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.lessThanOrEqualTo(self.closeClickView.snp.leading)
      make.centerY.equalToSuperview().inset(Metric.headerCenterYInset)
    }
    
    if #available(iOS 11.0, *) {
      self.userInfoStackView.setCustomSpacing(Metric.avatarViewTraling, after: self.avatarView)
      self.userInfoStackView.setCustomSpacing(Metric.nameViewTrailing, after: self.nameLabel)
    }
    
    self.avatarView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.avatarViewLength)
    }
    
    self.closeImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.closeImageViewLength)
      make.centerX.centerY.equalToSuperview()
    }

    self.closeContainerView.snp.makeConstraints { make in
      make.centerY.equalToSuperview().inset(Metric.closeContainerCenterYInset)
      make.width.height.equalTo(Metric.closeContainerLength)
      make.leading.equalToSuperview().inset(Metric.closeContainerLeading)
      make.trailing.equalToSuperview().inset(Metric.closeContainerTrailing)
    }
    
    self.closeClickView.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.width.equalTo(Metric.closeClickWidth)
    }
    
    self.firstButtonView.snp.makeConstraints { make in
      make.height.equalTo(Metric.buttonHeight)
    }
    self.secondButtonView.snp.makeConstraints { make in
      make.height.equalTo(Metric.buttonHeight)
    }
    
    self.messageContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(Metric.contentSide)
      make.top.equalToSuperview().inset(Metric.messageTop)
      make.bottom.equalToSuperview().inset(Metric.infoViewBottom)
    }
    
    self.buttonContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(Metric.buttonContainerHeight)
    }
    
    self.buttonStackView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.bottom.equalToSuperview().inset(Metric.buttonStackSide)
    }
    
    self.mediaContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
    }
    
    self.mediaView.snp.makeConstraints { make in
      make.top.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  func configure(with viewModel: InAppNotificationViewModel) {
    let fileInfoVisibility = viewModel.hasMedia ? false : viewModel.files.count > 0
    
    self.avatarView.configure(viewModel.avatar)
    self.nameLabel.text = viewModel.name
    self.timeLabel.text = viewModel.timestamp
    self.fileInfoView.configure(with: viewModel.files, isInAppPush: true)
    self.messageView.textContainer.maximumNumberOfLines = viewModel.hasMedia ?
      Constants.maxLineWithMedia : Constants.maxLineWithoutMedia
    self.messageView.attributedText = viewModel.message
    self.mediaView.configure(model: viewModel)
    self.messageView.isHidden = !viewModel.hasText
    self.fileInfoView.isHidden = !fileInfoVisibility
    self.infoView.isHidden = !viewModel.hasText && !fileInfoVisibility
    self.mediaContainerView.isHidden = !viewModel.hasMedia
    self.mkInfo = viewModel.mkInfo
    
    self.buttonContainerView.isHidden = viewModel.buttons.count == 0
    self.firstButtonView.isHidden = true
    self.secondButtonView.isHidden = true
    if let first = viewModel.buttons.get(index: 0) {
      self.firstButtonView.isHidden = false
      self.firstButtonView.text = first.title
      self.firstButtonView.textColor = first.theme == nil ? .grey900 : .white
      self.firstButtonView.backgroundColor = first.theme?.color ?? .black5
      self.firstButtonView
        .signalForClick()
        .bind { _ in
          if let url = first.linkURL {
            self.closeSignal.onNext(nil)
            self.closeSignal.onCompleted()
            url.openWithUniversal()
          }
        }.disposed(by: self.disposeBag)
    }
    
    if let second = viewModel.buttons.get(index: 1) {
      self.secondButtonView.isHidden = false
      self.secondButtonView.text = second.title
      self.secondButtonView.textColor = second.theme == nil ? .grey900 : .white
      self.secondButtonView.backgroundColor = second.theme?.color ?? .black5
      self.secondButtonView
        .signalForClick()
        .bind { _ in
          if let url = second.linkURL {
            self.closeSignal.onNext(nil)
            self.closeSignal.onCompleted()
            url.openWithUniversal()
          }
        }.disposed(by: self.disposeBag)
    }
  }
  
  func insertView(on view: UIView?) {
    guard let view = view else { return }
    
    if let superview = self.superview, superview != view {
      self.removeFromSuperview()
    }
    if self.superview != view {
      self.insert(on: view, animated: true)
    }

    self.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }

  func signalForChat() -> Observable<Any?> {
    self.chatSignal = PublishSubject<Any?>()
    return self.chatSignal.asObservable()
  }
  
  func signalForClose() -> Observable<Any?> {
    self.closeSignal = PublishSubject<Any?>()
    return self.closeSignal.asObservable()
  }
  
  func removeView(animated: Bool) {
    self.remove(animated: animated)
  }
}

extension PopupInAppNotificationView : UITextViewDelegate {
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
      if let mkInfo = self.mkInfo {
        mainStore.dispatch(ClickMarketing(type: mkInfo.type, id: mkInfo.id))
      }
      return false
    }
    
    return true
  }
}
