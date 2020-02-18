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
    static let closeImageViewTrailing = 16.f
    static let closeImageViewTop = 16.f
    static let contentSide = 18.f
    static let messageTop = 8.f
    static let writerTop = 14.f
    static let contentBottom = 18.f
    static let closeContainerSide = 48.f
    static let closeSide = 16.f
    static let avatarSize = CGSize(width: 34.f, height: 34.f)
    static let mediaContainerSide = 4.f
    static let avatarTrailing = 4.f
  }
  
  private struct Constants {
    static let maxLineWithMedia = 4
    static let maxLineWithoutMedia = 8
  }
  
  let notiType : InAppNotificationType = .fullScreen
  
  private let dimView = UIView().then {
    $0.backgroundColor = .black10
  }
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 10.f
    $0.backgroundColor = .white
  }
  
  private let mainContentView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let infoView = UIView()
  
  private let messageContainerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 10.f
  }
  private let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.isUserInteractionEnabled = false
    
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textColor = UIColor.grey900
    $0.textContainer.maximumNumberOfLines = 8
    $0.textContainer.lineBreakMode = .byTruncatingTail
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
  
  private let mediaView = InAppMediaView().then {
    $0.layer.cornerRadius = 10.f
    $0.backgroundColor = .white
    $0.clipsToBounds = true
  }
  
  private let writerInfoStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 6
    $0.distribution = .fill
  }
  private let avatarContainerView = UIView()
  private let avatarView = AvatarView()
  private let nameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 12)
    $0.textColor = .grey900
  }
  private let timestampLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = .grey500
  }
  
  private let mediaContainerView = UIView()
  
  private var chatSignal = PublishSubject<Any?>()
  private var closeSignal = PublishSubject<Any?>()
  private var mkInfo: MarketingInfo?
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.dimView)
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.mainContentView)
    
    self.infoView.addSubview(self.writerInfoStackView)
    self.infoView.addSubview(self.closeContainerView)
    self.closeContainerView.addSubview(self.closeImageView)
    
    self.messageContainerView.addArrangedSubview(self.messageView)
    self.messageContainerView.addArrangedSubview(self.fileInfoView)
    self.infoView.addSubview(self.messageContainerView)
    
    self.writerInfoStackView.addArrangedSubview(self.avatarContainerView)
    self.avatarContainerView.addSubview(self.avatarView)
    self.writerInfoStackView.addArrangedSubview(self.nameLabel)
    self.writerInfoStackView.addArrangedSubview(self.timestampLabel)
    
    self.mainContentView.addArrangedSubview(self.infoView)
    self.mainContentView.addArrangedSubview(self.mediaContainerView)
    
    self.mediaContainerView.addSubview(self.mediaView)
    
    self.layer.zPosition = 1
    
    self.messageView.delegate = self
    
    self.containerView.rx.observeWeakly(CGRect.self, "bounds")
      .subscribe(onNext: { [weak self] (bounds) in
        self?.containerView.layer.applySketchShadow(
          color: .black15, alpha: 1, x: 0, y: 3, blur: 12, spread: 1
        )
      }).disposed(by: self.disposeBag)

    self.containerView.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        self?.chatSignal.onNext(nil)
        self?.chatSignal.onCompleted()
      }).disposed(by: self.disposeBag)
    
    self.closeContainerView.signalForClick()
      .subscribe(onNext: { [weak self] (_) in
        guard let self = self else { return }
        CHUser.closePopup().subscribe().disposed(by: self.disposeBag)
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
      make.width.equalTo(Metrics.containerWidth)
    }

    self.mainContentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.writerInfoStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metrics.contentSide)
      make.top.equalToSuperview().inset(Metrics.writerTop)
      make.trailing.lessThanOrEqualTo(self.closeContainerView.snp.leading)
        .offset(Metrics.contentSide)
    }
    
    self.closeContainerView.snp.makeConstraints { make in
      make.width.equalTo(Metrics.closeContainerSide)
      make.height.equalTo(Metrics.closeContainerSide)
      make.top.trailing.equalToSuperview()
    }
    
    self.closeImageView.snp.makeConstraints { make in
      make.width.equalTo(Metrics.closeSide)
      make.height.equalTo(Metrics.closeSide)
      make.trailing.equalToSuperview().inset(Metrics.closeImageViewTrailing)
      make.top.equalToSuperview().inset(Metrics.closeImageViewTop)
    }
    
    self.messageContainerView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metrics.contentSide)
      make.top.equalTo(self.writerInfoStackView.snp.bottom)
        .offset(Metrics.messageTop)
      make.trailing.equalToSuperview().inset(Metrics.contentSide)
      make.bottom.equalToSuperview().inset(Metrics.contentBottom)
    }
    
    self.avatarView.snp.makeConstraints { make in
      make.leading.top.bottom.equalToSuperview()
      make.trailing.equalToSuperview().inset(Metrics.avatarTrailing)
      make.size.equalTo(Metrics.avatarSize)
    }
    
    self.mediaView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.trailing.bottom.equalToSuperview()
        .inset(Metrics.mediaContainerSide)
    }
  }
  
  func configure(with viewModel: InAppNotificationViewModel) {
    let fileInfoVisibility = viewModel.hasMedia ?
      !viewModel.hasText : viewModel.files.count > 0
    
    self.avatarView.configure(viewModel.avatar)
    self.nameLabel.text = viewModel.name
    self.timestampLabel.text = viewModel.timestamp
    self.fileInfoView.configure(with: viewModel.files, isLarge: true)
    self.messageView.textContainer.maximumNumberOfLines = viewModel.hasMedia ?
      Constants.maxLineWithMedia : Constants.maxLineWithoutMedia
    self.messageView.attributedText = viewModel.message
    self.mediaView.configure(model: viewModel)
    self.messageView.isHidden = !viewModel.hasText
    self.fileInfoView.isHidden = !fileInfoVisibility
    self.mediaContainerView.isHidden = !viewModel.hasMedia
    self.mkInfo = viewModel.mkInfo
  }
  
  func insertView(on view: UIView?) {
    guard let view = view else { return }
    
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
