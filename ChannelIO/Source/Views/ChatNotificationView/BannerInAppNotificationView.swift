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
  private enum Metric {
    static let bannerMaxWidth = 520.f
    static let bannerTopWithoutNavi = 24.f
    static let bannerTopWithNavi = 8.f
    static let bannerSide = 8.f
    static let mediaTopBottom = 8.f
    static let mediaLeading = 8.f
    static let buttonContainerHeight = 44.f
    static let buttonStackSide = 8.f
    static let headerViewLeading = 8.f
    static let headerViewHeight = 38.f
    static let headerCenterYInset = -2.f
    static let avatarViewTraling = 4.f
    static let nameContainerTrailing = 6.f
    static let nameViewLeading = 2.f
    static let messageFileStackSide = 10.f
    static let messageFileStackBottom = 10.f
    static let avatarViewLength = 24.f
    static let closeImageViewLength = 16.f
    static let closeContainerCenterYInset = -2.f
    static let closeContainerLength = 24.f
    static let closeContainerLeading = 12.f
    static let closeContainerTrailing = 8.f
    static let closeClickWidth = 44.f
    static let buttonHeight = 36.f
  }
  
  private struct Constants {
    static let maxLineWithOnlyText = 2
    static let maxLineWithFileInfo = 1
  }
  
  private let containerView = UIView().then {
    $0.layer.cornerRadius = 12.f
    $0.backgroundColor = .white
  }
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
  }
  private let upperContentContainerView = UIView()
  private let upperContentStackView = UIStackView().then {
    $0.axis = .horizontal
  }
  private let buttonContainerView = UIView().then {
    $0.isHidden = true
  }
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8.f
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
  private let rightInfoView = UIView()
  private let mediaContainerView = UIView()
  private let headerView = UIView()
  private let userInfoStackView = UIStackView().then {
    $0.axis = .horizontal
  }
  private let closeClickView = UIView()
  private let closeContainerView = UIView().then {
    $0.layer.cornerRadius = 12
    $0.backgroundColor = .black5
  }
  private let closeImageView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "cancel")
  }
  private let messageAndFileStackView = UIStackView().then {
    $0.axis = .vertical
  }
  private let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.isSelectable = true
    $0.isUserInteractionEnabled = false
    
    $0.font = UIFont.systemFont(ofSize: 15)
    $0.textColor = UIColor.grey900
    $0.backgroundColor = .white
    $0.textContainer.maximumNumberOfLines = 0
    $0.textContainer.lineBreakMode = .byTruncatingTail
    
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    $0.linkTextAttributes = [
      .foregroundColor: UIColor.cobalt400,
      .underlineStyle: 0
    ]
  }
  private let fileInfoView = AttachmentFileInfoView().then {
    $0.isHidden = true
  }
  private let avatarView = AvatarView().then {
    $0.isRound = false
    $0.avatarImageView.layer.cornerRadius = 8.f
  }
  private let medialayerView = UIView().then {
    $0.layer.cornerRadius = 6.f
    $0.clipsToBounds = true
  }
  private let mediaView = InAppMediaView()
  private let nameContainerView = UIView()
  private let nameLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textColor = .grey900
  }
  private let timeLabel = UILabel().then {
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = .grey500
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue:1000), for: .horizontal)
  }
  
  let notiType: InAppNotificationType = .banner
  private var mkInfo: MarketingInfo?
  private var chatSignal = PublishSubject<Any?>()
  private var closeSignal = PublishSubject<Any?>()
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.containerStackView)
    
    self.containerStackView.addArrangedSubview(self.upperContentContainerView)
    self.containerStackView.addArrangedSubview(self.buttonContainerView)
    
    self.upperContentContainerView.addSubview(self.upperContentStackView)
    self.buttonContainerView.addSubview(self.buttonStackView)
    
    self.upperContentStackView.addArrangedSubview(self.mediaContainerView)
    self.mediaContainerView.addSubview(self.medialayerView)
    self.medialayerView.addSubview(self.mediaView)
    self.upperContentStackView.addArrangedSubview(self.rightInfoView)
    self.rightInfoView.addSubview(self.headerView)
    self.rightInfoView.addSubview(self.messageAndFileStackView)
    self.headerView.addSubview(self.userInfoStackView)
    self.userInfoStackView.addArrangedSubview(self.avatarView)
    self.userInfoStackView.addArrangedSubview(self.nameContainerView)
    self.nameContainerView.addSubview(self.nameLabel)
    self.userInfoStackView.addArrangedSubview(self.timeLabel)
    self.headerView.addSubview(self.closeClickView)
    self.closeClickView.addSubview(self.closeContainerView)
    self.closeContainerView.addSubview(self.closeImageView)
    self.messageAndFileStackView.addArrangedSubview(self.messageView)
    self.messageAndFileStackView.addArrangedSubview(self.fileInfoView)
    
    self.buttonStackView.addArrangedSubview(self.firstButtonView)
    self.buttonStackView.addArrangedSubview(self.secondButtonView)
    
    self.layer.zPosition = 1
    
    self.messageView.delegate = self
    
    self.rx.observeWeakly(CGRect.self, "bounds")
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (bounds) in
        self?.layer.applySketchShadow(
          color: .black20, alpha: 1, x: 0, y: 4, blur: 20, spread: 0
        )
      }).disposed(by: self.disposeBag)
    
    self.signalForClick()
      .bind { [weak self] _ in
        self?.chatSignal.onNext(nil)
        self?.chatSignal.onCompleted()
      }.disposed(by: self.disposeBag)
    
    self.messageView
      .signalForClick()
      .bind { [weak self] _ in
        self?.chatSignal.onNext(nil)
        self?.chatSignal.onCompleted()
      }.disposed(by: self.disposeBag)
    
    self.closeClickView
      .signalForClick()
      .bind { [weak self] _ in
        guard let self = self else { return }
        CHUser.closePopup().subscribe().disposed(by: self.disposeBag)
        self.closeSignal.onNext(nil)
        self.closeSignal.onCompleted()
      }.disposed(by: self.disposeBag)
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.containerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    // NOTE: Because of UISV-canvas-connection on nested uistackview issue,
    // we need wrappint uiview on nested stackview
    self.upperContentContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
    }
    
    self.upperContentStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.buttonContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(Metric.buttonContainerHeight)
    }
    
    self.buttonStackView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview().inset(Metric.buttonStackSide)
    }
    
    self.medialayerView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.mediaLeading)
      make.trailing.equalToSuperview()
      make.top.bottom.equalToSuperview().inset(Metric.mediaTopBottom)
    }
    
    self.mediaView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.headerView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.headerViewLeading)
      make.top.trailing.equalToSuperview()
      make.height.equalTo(Metric.headerViewHeight)
    }
    
    self.userInfoStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.trailing.lessThanOrEqualTo(self.closeClickView.snp.leading)
      make.centerY.equalToSuperview().inset(Metric.headerCenterYInset)
    }
    
    if #available(iOS 11.0, *) {
      self.userInfoStackView.setCustomSpacing(Metric.avatarViewTraling, after: self.avatarView)
      self.userInfoStackView.setCustomSpacing(
        Metric.nameContainerTrailing,
        after: self.nameContainerView
      )
    }
    
    self.nameLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(Metric.nameViewLeading)
      make.top.bottom.trailing.equalToSuperview()
    }
    
    self.messageAndFileStackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(Metric.messageFileStackSide)
      make.top.equalTo(self.headerView.snp.bottom)
      make.bottom.lessThanOrEqualToSuperview().inset(Metric.messageFileStackBottom)
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
  }
  
  func configure(with viewModel: InAppNotificationViewModel) {
    self.mkInfo = viewModel.mkInfo
    let fileInfoVisibility = viewModel.hasMedia ?
      !viewModel.hasText : viewModel.files.count > 0
    self.nameLabel.text = viewModel.name
    self.avatarView.isHidden = viewModel.hasMedia
    self.avatarView.configure(viewModel.avatar)
    self.timeLabel.text = viewModel.timestamp
    self.mediaContainerView.isHidden = !viewModel.hasMedia
    self.mediaView.configure(model: viewModel)
    self.messageView.isHidden = !viewModel.hasText
    self.messageView.attributedText = viewModel.message
    self.messageView.textContainer.maximumNumberOfLines = fileInfoVisibility ?
      Constants.maxLineWithFileInfo : Constants.maxLineWithOnlyText
    self.fileInfoView.isHidden = !fileInfoVisibility
    self.fileInfoView.configure(with: viewModel.files, isInAppPush: true)
    
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
    
    let maxWidth = Metric.bannerMaxWidth
    
    self.snp.makeConstraints { make in
      if view.bounds.width > maxWidth {
        make.centerX.equalToSuperview()
        make.width.equalTo(maxWidth)
      } else {
        make.leading.trailing.equalToSuperview().inset(Metric.bannerSide)
      }
      make.top.equalToSuperview().inset(
        ChannelIO.launcherWindow?.naviHeight != 0
          ? Metric.bannerTopWithNavi : Metric.bannerTopWithoutNavi
      )
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

extension BannerInAppNotificationView : UITextViewDelegate {
  func textView(
    _ textView: UITextView,
    shouldInteractWith URL: URL,
    in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    if let mkInfo = self.mkInfo {
      mainStore.dispatch(ClickMarketing(type: mkInfo.type, id: mkInfo.id))
    }
    
    if interaction == .invokeDefaultAction {
      let scheme = URL.scheme ?? ""
      switch scheme {
      case "tel":
        return true
      case "mailto":
        return true
      default:
        let handled = ChannelIO.delegate?.onClickChatLink?(url: URL)
        if handled == false || handled == nil {
          self.closeSignal.onNext(nil)
          self.closeSignal.onCompleted()
          URL.openWithUniversal()
        }
        return false
      }
    }
    
    return true
  }
}
