//
//  ChatNotificationView.swift
//  CHPlugin
//
//  Created by Haeun Chung on 09/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import SDWebImage

final class ChatNotificationView : BaseView {
  var topLayoutGuide: UILayoutSupport?
  
  // MARK: Constantss
  struct Metrics {
    static let AvatarSide = 48.f
    static let AvatarTop = -12.f
    static let AvatarLeading = 14.f
    static let NameTop = 16.f
    static let NameLeading = 8.f
    static let CloseTrailing = 6.f
    static let CloseTop = 6.f
    static let CloseSide = 45.f
    static let CloseLeading = 12.f
    static let MessageTop = 45.f
    static let MessageTrailing = 20.f
    static let MessageLeading = 20.f
    static let ImageSideMargin = 4.f
    static let ImageTop = 20.f
    static let ImageMaxHeight = 220.f //per device?
    static let contentTop = 20.f
    static let buttonBottom = 18.f
    static let buttonHeight = 37.f
    static let titleHeight = 24.f
    static let titleBottom = 6.f
    static let MessageTopToTitle = 75.f
    
    static let viewTopMargin = 20.f
    static let viewSideMargin = 14.f
    static let maxWidth = 520.f
  }
  
  struct Fonts {
    static let messageLabel = UIFont.systemFont(ofSize: 14)
    static let nameLabel = UIFont.boldSystemFont(ofSize: 13)
    static let timestampLabel = UIFont.systemFont(ofSize: 11)
  }
  
  struct Colors {
    static let border = CHColors.white.cgColor
    static let messageLabel = CHColors.charcoalGrey
    static let nameLabel = CHColors.charcoalGrey
    static let timeLabel = CHColors.warmGrey
  }
  
  struct Constants {
    static let titleLabelNumberOfLines = 1
    static let messageLabelNumberOfLines = 4
    static let timestampLabelNumberOfLines = 1
    static let nameLabelNumberOfLines = 1
    static let cornerRadius = 8.f
    static let shadowColor = CHColors.dark.cgColor
    static let shadowOffset = CGSize(width: 0.f, height: 5.f)
    static let shadowBlur = 20.f
    static let shadowOpacity = 0.4.f
  }

  // MARK: Properties
  let messageView = UITextView().then {
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.font = Fonts.messageLabel
    $0.textColor = Colors.messageLabel
    $0.textContainer.maximumNumberOfLines = 3
    $0.textContainer.lineBreakMode = .byTruncatingTail
    
    $0.dataDetectorTypes = [.link, .phoneNumber]
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    
    $0.linkTextAttributes = [
      .foregroundColor: CHColors.cobalt,
      .underlineStyle: 0
    ]
  }
  
  let nameLabel = UILabel().then {
    $0.font = Fonts.nameLabel
    $0.textColor = Colors.nameLabel
    $0.numberOfLines = Constants.nameLabelNumberOfLines
  }
  
  let titleLabel = UILabel().then {
    $0.font = UIFont.boldSystemFont(ofSize: 18)
    $0.textColor = CHColors.charcoalGrey
    $0.numberOfLines = 1
  }
  
  let timestampLabel = UILabel().then {
    $0.font = Fonts.timestampLabel
    $0.textColor = Colors.timeLabel
    $0.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
  }
  
  let avatarView = AvatarView().then {
    $0.showBorder = true
    $0.borderColor = UIColor.white
  }
  
  let closeView = UIImageView().then {
    $0.image = CHAssets.getImage(named: "cancelSmall")
    $0.contentMode = .center
    $0.layer.shadowOpacity = 0
  }
  
  let contentImageView = FLAnimatedImageView().then {
    $0.layer.cornerRadius = 6.f
    $0.clipsToBounds = true
    $0.contentMode = .scaleAspectFill
    $0.isHidden = true
  }
  
  let contentButton = UIButton().then {
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 13)
    $0.titleLabel?.numberOfLines = 1
    $0.contentEdgeInsets = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = CHColors.dark10.cgColor
    $0.layer.cornerRadius = 2.f
    $0.isHidden = true
  }
  
  var chatSignal = PublishSubject<Any?>()
  var redirectSignal = PublishSubject<String?>()
  let disposeBag = DisposeBag()
  
  var messageTopConstraint: Constraint? = nil
  var messageBottomConstraint: Constraint? = nil
  var contentImageHeightConstraint: Constraint? = nil
  var contentButtonBottomConstraint: Constraint? = nil
  var contentButtonTopConstraint: Constraint? = nil
  
  override func initialize() {
    super.initialize()
    
    self.backgroundColor = CHColors.white
    
    self.layer.cornerRadius = Constants.cornerRadius
    self.layer.shadowColor = Constants.shadowColor
    self.layer.shadowOffset = Constants.shadowOffset
    self.layer.shadowRadius = Constants.shadowBlur
    self.layer.shadowOpacity = Float(Constants.shadowOpacity)
    
    self.avatarView.layer.shadowColor = CHColors.dark10.cgColor
    self.avatarView.layer.shadowOffset = CGSize(width: 0.f, height: 2.f)
    self.avatarView.layer.shadowRadius = 4
    self.avatarView.layer.shadowOpacity = Float(Constants.shadowOpacity)
    
    self.messageView.delegate = self
    
    self.addSubview(self.nameLabel)
    self.addSubview(self.messageView)
    self.addSubview(self.titleLabel)
    self.addSubview(self.timestampLabel)
    self.addSubview(self.avatarView)
    self.addSubview(self.contentImageView)
    self.addSubview(self.contentButton)
    self.addSubview(self.closeView)
    
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
    
    self.avatarView.snp.makeConstraints { (make) in
      make.height.equalTo(Metrics.AvatarSide)
      make.width.equalTo(Metrics.AvatarSide)
      make.leading.equalToSuperview().inset(Metrics.AvatarLeading)
      make.top.equalToSuperview().inset(Metrics.AvatarTop)
    }
    
    self.nameLabel.snp.makeConstraints { [weak self] (make) in
      make.leading.equalTo((self?.avatarView.snp.trailing)!).offset(Metrics.NameLeading)
      make.top.equalToSuperview().inset(Metrics.NameTop)
    }
    
    self.timestampLabel.snp.makeConstraints { [weak self] (make) in
      make.leading.equalTo((self?.nameLabel.snp.trailing)!).offset(6)
      make.centerY.equalTo((self?.nameLabel.snp.centerY)!)
    }
    
    self.closeView.snp.makeConstraints { [weak self] (make) in
      make.leading.greaterThanOrEqualTo((self?.timestampLabel.snp.trailing)!).offset(Metrics.CloseLeading)
      make.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.height.equalTo(Metrics.CloseSide)
      make.width.equalTo(Metrics.CloseSide)
    }
    
    self.titleLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().inset(Metrics.MessageLeading)
      make.top.equalToSuperview().inset(Metrics.MessageTop)
      make.trailing.equalToSuperview().inset(Metrics.MessageTrailing)
    }
    
    self.messageView.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview().inset(Metrics.MessageLeading)
      self?.messageTopConstraint = make.top.equalToSuperview().inset(Metrics.MessageTop).constraint
      make.trailing.equalToSuperview().inset(Metrics.MessageTrailing)
    }
    
    self.contentImageView.snp.makeConstraints { [weak self] (make) in
      make.leading.equalToSuperview().inset(Metrics.ImageSideMargin)
      make.trailing.equalToSuperview().inset(Metrics.ImageSideMargin)
      make.top.equalTo((self?.messageView.snp.bottom)!).offset(Metrics.ImageTop)
      self?.contentImageHeightConstraint = make.height.lessThanOrEqualTo(Metrics.ImageMaxHeight).constraint
      make.bottom.equalToSuperview().inset(Metrics.ImageSideMargin)
    }
    
    self.contentButton.snp.makeConstraints { [weak self] (make) in
      make.leading.greaterThanOrEqualToSuperview().inset(20)
      make.trailing.lessThanOrEqualToSuperview().inset(20)
      make.centerX.equalToSuperview()
      self?.contentButtonTopConstraint = make.top.equalTo((self?.messageView.snp.bottom)!).offset(Metrics.ImageTop).constraint
      self?.contentButtonBottomConstraint = make.bottom.equalToSuperview().inset(22).constraint
    }
  }
  
  func configure(_ viewModel: ChatNotificationViewModelType) {
    self.messageView.attributedText = viewModel.message
    self.nameLabel.text = viewModel.name
    self.avatarView.configure(viewModel.avatar)
    self.timestampLabel.text = viewModel.timestamp
    
    if let title = viewModel.title {
      self.titleLabel.text = title
      self.titleLabel.isHidden = false
      self.messageTopConstraint?.update(inset: Metrics.MessageTopToTitle)
    } else {
      self.titleLabel.isHidden = true
      self.messageTopConstraint?.update(inset: Metrics.MessageTop)
    }
    
    if let buttonTitle = viewModel.buttonTitle {
      self.contentButton.isHidden = false
      self.contentButton.backgroundColor = viewModel.themeColor
      self.contentButton.setTitle(buttonTitle, for: .normal)
      
      self.contentButton.signalForClick().subscribe(onNext: { [weak self]  (_) in
        if let url = viewModel.buttonRedirect, url != "" {
          self?.redirectSignal.onNext(url)
          self?.redirectSignal.onCompleted()
        } else {
          self?.chatSignal.onNext(nil)
          self?.chatSignal.onCompleted()
        }
      }).disposed(by: self.disposeBag)
    } else if let url = viewModel.imageUrl {
      self.contentImageView.isHidden = false
      self.contentImageView.sd_setImage(with: url)
      self.contentImageHeightConstraint?.update(offset: min(Metrics.ImageMaxHeight, CGFloat(viewModel.imageHeight)))
      
      self.contentImageView.signalForClick().subscribe(onNext: { [weak self]  (_) in
        if let url = viewModel.imageRedirect, url != "" {
          self?.redirectSignal.onNext(url)
          self?.redirectSignal.onCompleted()
        } else {
          self?.chatSignal.onNext(nil)
          self?.chatSignal.onCompleted()
        }
      }).disposed(by: self.disposeBag)
    } else {
      self.contentButton.isHidden = true
      self.contentImageView.isHidden = true
      self.contentButtonBottomConstraint?.update(inset: 0)
      self.contentButtonTopConstraint?.update(offset: 0)
      self.contentImageHeightConstraint?.update(offset: 0)
    }
  }
  
  func signalForRedirect() -> Observable<String?> {
    self.redirectSignal = PublishSubject<String?>()
    return self.redirectSignal.asObservable()
  }
  
  func signalForChat() -> Observable<Any?> {
    self.chatSignal = PublishSubject<Any?>()
    return self.chatSignal.asObservable()
  }
}

extension ChatNotificationView : UITextViewDelegate {
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

