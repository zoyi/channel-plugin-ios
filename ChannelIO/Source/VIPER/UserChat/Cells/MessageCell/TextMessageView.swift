//
//  TextMessageView.swft
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 20..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift

class TextMessageView : BaseView {
  private struct Metric {
    static let topBottomPadding = 10.f
    static let leftRightPadding = 12.f
    static let minimalTopBottomPadding = 2.f
    static let minimalLeftRightPadding = 5.f
    static let textViewMinimalWidth = 20.f
    static let textViewInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    static let buttonRadius = 6.f
    static let buttonHeight = 36.f
    static let buttonSpace = 6.f
    static let buttonWidth = 232.f
  }

  private struct Constants {
    static let cornerRadius = 12.f
    static let singleCornerRadius = 2.f
    static let actionViewBottomRadius = 12.f
    static let borderWidth: CGFloat = 1
  }

  private struct Font {
    static let actionLabel = UIFont.boldSystemFont(ofSize: 13)
    static let messageView = UIFont.systemFont(ofSize: 15)
  }

 private struct Color {
    static let actionLabel = UIColor.grey500
    static let message = UIColor.grey900
  }

  //MARK: Properties

  let messageView = UITextView().then {
    $0.font = Font.messageView
    $0.textAlignment = .left
    $0.backgroundColor = UIColor.clear
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.isSelectable = true
    
    $0.dataDetectorTypes = [.link, .phoneNumber]
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = Metric.textViewInset
  }
  
  private let buttonStack = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .equalSpacing
    $0.spacing = Metric.buttonSpace
    $0.backgroundColor = .clear
  }
  private let firstButtonView = UILabel().then {
    $0.font = .systemFont(ofSize: 14.f)
    $0.textColor = .grey900
    $0.backgroundColor = .white
    $0.textAlignment = .center
    
    $0.clipsToBounds = true
    $0.layer.cornerRadius = Metric.buttonRadius
  }
  private let secondButtonView = UILabel().then {
    $0.font = .systemFont(ofSize: 14.f)
    $0.textColor = .grey900
    $0.backgroundColor = .white
    $0.textAlignment = .center
    
    $0.clipsToBounds = true
    $0.layer.cornerRadius = Metric.buttonRadius
  }
  

  var viewModel: MessageCellModelType?
  
  private var messageTopConstraint: Constraint?
  var leadingConstraint: Constraint?
  var trailingConstraint: Constraint?
  private var messageBottomConstraint: Constraint?
  
  private var buttonTopConstraint: Constraint?
  private var buttonTopMessageConstraint: Constraint?
  private var buttonBottomConstraint: Constraint?
  
  private let disposeBag = DisposeBag()
  
  override func initialize() {
    super.initialize()
    self.messageView.delegate = self
    
    self.layer.cornerRadius = Constants.singleCornerRadius
    self.addSubview(self.messageView)
    self.buttonStack.addArrangedSubview(self.firstButtonView)
    self.buttonStack.addArrangedSubview(self.secondButtonView)
    self.addSubview(self.buttonStack)
  }
  
  override func setLayouts() {
    super.setLayouts()

    self.messageView.snp.makeConstraints { make in
      self.leadingConstraint = make.leading.equalToSuperview()
        .inset(Metric.leftRightPadding).constraint
      self.messageTopConstraint = make.top.equalToSuperview()
        .inset(Metric.topBottomPadding).constraint
      self.trailingConstraint = make.trailing.equalToSuperview()
        .inset(Metric.leftRightPadding).constraint
      self.messageBottomConstraint = make.bottom.equalToSuperview()
        .inset(Metric.topBottomPadding).constraint
      make.width.greaterThanOrEqualTo(Metric.textViewMinimalWidth)
    }
    
    self.firstButtonView.snp.remakeConstraints { make in
      make.height.equalTo(Metric.buttonHeight)
      make.width.equalTo(Metric.buttonWidth)
    }
    
    self.secondButtonView.snp.remakeConstraints { make in
      make.height.equalTo(Metric.buttonHeight)
      make.width.equalTo(Metric.buttonWidth)
    }
    
    self.buttonStack.snp.makeConstraints { make in
      self.buttonTopConstraint = make.top.equalToSuperview()
        .inset(Metric.topBottomPadding).constraint
      self.buttonTopMessageConstraint = make.top.equalTo(self.messageView.snp.bottom)
        .offset(Metric.topBottomPadding).constraint
      make.leading.trailing.equalToSuperview().inset(Metric.leftRightPadding)
      self.buttonBottomConstraint = make.bottom.equalToSuperview()
        .inset(Metric.topBottomPadding).constraint
    }
  }

  func configure(_ viewModel: MessageCellModelType) {
    self.viewModel = viewModel
    var hasContents = false
    if let displayText = viewModel.text {
      hasContents = true
      self.messageView.isHidden = false
      self.backgroundColor = viewModel.isOnlyEmoji ?
        UIColor.clear : viewModel.bubbleBackgroundColor
      self.messageView.attributedText = displayText
      self.messageView.linkTextAttributes = [
        .foregroundColor: viewModel.linkColor,
        .underlineStyle: 1
      ]
    } else {
      self.messageView.isHidden = true
    }
    
    if viewModel.buttons.count > 0 {
      self.buttonStack.isHidden = false
      hasContents = true
        
      self.backgroundColor = viewModel.bubbleBackgroundColor
      self.configureButtonView(
        with: viewModel.buttons.get(index: 0),
        mkInfo: viewModel.message.mkInfo,
        view: self.firstButtonView
      )
      
      self.configureButtonView(
        with: viewModel.buttons.get(index: 1),
        mkInfo: viewModel.message.mkInfo,
        view: self.secondButtonView
      )
    } else {
      self.buttonStack.isHidden = true
      self.firstButtonView.isHidden = true
      self.secondButtonView.isHidden = true
    }
    
    if viewModel.text != nil, !viewModel.buttons.isEmpty {
      self.messageTopConstraint?.activate()
      self.messageBottomConstraint?.deactivate()
      self.buttonTopConstraint?.deactivate()
      self.buttonTopMessageConstraint?.activate()
      self.buttonBottomConstraint?.activate()
    } else if viewModel.text != nil, viewModel.buttons.isEmpty {
      self.messageTopConstraint?.activate()
      self.messageBottomConstraint?.activate()
      self.buttonTopConstraint?.deactivate()
      self.buttonTopMessageConstraint?.deactivate()
      self.buttonBottomConstraint?.deactivate()
    } else if !viewModel.buttons.isEmpty {
      self.messageTopConstraint?.deactivate()
      self.messageBottomConstraint?.deactivate()
      self.buttonTopConstraint?.activate()
      self.buttonTopMessageConstraint?.deactivate()
      self.buttonBottomConstraint?.activate()
    }
    
    self.isHidden = !hasContents
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    if self.viewModel?.isContinuous == true {
      self.roundCorners(corners: [.allCorners], radius: Constants.cornerRadius)
    } else if self.viewModel?.createdByMe == true {
      self.roundCorners(corners: [.topLeft, .bottomRight, .bottomLeft], radius: Constants.cornerRadius)
    } else {
      self.roundCorners(corners: [.topRight, .bottomRight, .bottomLeft], radius: Constants.cornerRadius)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.viewModel?.isContinuous == true {
      self.roundCorners(corners: [.allCorners], radius: Constants.cornerRadius)
    } else if self.viewModel?.createdByMe == true {
      self.roundCorners(
        corners: [.topLeft, .bottomRight, .bottomLeft],
        radius: Constants.cornerRadius
      )
    } else {
      self.roundCorners(
        corners: [.topRight, .bottomRight, .bottomLeft],
        radius: Constants.cornerRadius
      )
    }
  }
  
  static func viewHeight(
    fit width: CGFloat,
    model: MessageCellModelType,
    edgeInset: UIEdgeInsets? = nil) -> CGFloat {
    var textHeight = 0.f
    if let text = model.text, text.string != "" {
      let maxWidth = width - Metric.leftRightPadding * 2
      textHeight = text.height(fits: maxWidth) + Metric.topBottomPadding
    }
    
    var buttonHeight = 0.f
    switch model.buttons.count {
    case 1: buttonHeight += Metric.buttonHeight + Metric.topBottomPadding
    case 2: buttonHeight += Metric.buttonHeight * 2 + Metric.buttonSpace + Metric.topBottomPadding
    default: break
    }
    
    let totalHeight = textHeight + buttonHeight
    return totalHeight == 0 ? 0 : totalHeight + Metric.topBottomPadding
  }
}

extension TextMessageView : UITextViewDelegate {
  func textView(
    _ textView: UITextView,
    shouldInteractWith URL: URL,
    in characterRange: NSRange) -> Bool {
    if let mkInfo = self.viewModel?.message.mkInfo {
      mainStore.dispatch(ClickMarketing(type: mkInfo.type, id: mkInfo.id))
    }
    
    let shouldhandle = ChannelIO.delegate?.onClickChatLink?(url: URL)
    let scheme = URL.scheme ?? ""
    switch scheme {
    case "tel":
      return true
    case "mailto":
      return true
    default:
      return shouldhandle == false || shouldhandle == nil
    }
  }
  
  func textView(
    _ textView: UITextView,
    shouldInteractWith URL: URL,
    in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    if let mkInfo = self.viewModel?.message.mkInfo {
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
          URL.openWithUniversal()
        }
        return false
      }
    }
    
    return true
  }
  
  func configureButtonView(
    with button: CHLinkButton?,
    mkInfo: MarketingInfo?,
    view: UILabel
  ) {
    guard let button = button else {
      view.isHidden = true
      return
    }
    view.isHidden = false
    
    view.text = button.title
    view.textColor = button.theme?.color ?? .grey900
    view
      .signalForClick()
      .bind { _ in
        if let mkInfo = mkInfo {
          AppManager.shared.sendClickMarketing(
            type: mkInfo.type,
            id: mkInfo.id,
            userId: PrefStore.getCurrentUserId(),
            url: button.linkURL?.absoluteString
          )
        }
        
        if let url = button.linkURL {
          url.openWithUniversal()
        }
      }.disposed(by: self.disposeBag)
  }
}
