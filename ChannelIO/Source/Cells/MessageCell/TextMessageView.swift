//
//  TextMessageView.swft
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 20..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import SnapKit

let placeHolder = UITextView()
  .then {
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
  }

class TextMessageView : BaseView {
  struct Metrics {
    static let topBottomPadding = 10.f
    static let leftRightPadding = 12.f
    static let minimalTopBottomPadding = 2.f
    static let minimalLeftRightPadding = 5.f
    static let textViewMinimalWidth = 20.f
  }

  struct Constants {
    static let cornerRadius = 12.f
    static let singleCornerRadius = 2.f
    static let actionViewBottomRadius = 12.f
    static let borderWidth: CGFloat = 1
  }

  struct Font {
    static let actionLabel = UIFont.boldSystemFont(ofSize: 13)
    static let messageView = UIFont.systemFont(ofSize: 15)
  }

  struct Color {
    static let actionLabel = CHColors.blueyGrey
    static let message = UIColor.grey900
  }

  //MARK: Properties

  let messageView = UITextView().then {
    $0.font = Font.messageView
    $0.textAlignment = NSTextAlignment.left
    $0.backgroundColor = UIColor.clear
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.isSelectable = true
    
    $0.dataDetectorTypes = [.link, .phoneNumber]
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
  }

  var viewModel: MessageCellModelType?
  
  var topConstraint: Constraint?
  var leadingConstraint: Constraint?
  var trailingConstraint: Constraint?
  var bottomConstraint: Constraint?
  
  override func initialize() {
    super.initialize()
    self.messageView.delegate = self
    
    self.layer.cornerRadius = Constants.singleCornerRadius
    self.addSubview(self.messageView)
  }
  
  override func setLayouts() {
    super.setLayouts()

    self.messageView.snp.makeConstraints { make in
      self.leadingConstraint = make.leading.equalToSuperview().inset(Metrics.leftRightPadding).constraint
      self.topConstraint = make.top.equalToSuperview().inset(Metrics.topBottomPadding).constraint
      self.trailingConstraint = make.trailing.equalToSuperview().inset(Metrics.leftRightPadding).constraint
      self.bottomConstraint = make.bottom.equalToSuperview().inset(Metrics.topBottomPadding).constraint
      make.width.greaterThanOrEqualTo(Metrics.textViewMinimalWidth)
    }
  }

  func configure(_ viewModel: MessageCellModelType) {
    self.viewModel = viewModel
    self.isHidden = viewModel.message.isEmpty()
        
    if !viewModel.message.onlyEmoji {
      self.leadingConstraint?.update(inset: Metrics.leftRightPadding)
      self.trailingConstraint?.update(inset: Metrics.leftRightPadding)
      self.topConstraint?.update(inset: Metrics.topBottomPadding)
      self.bottomConstraint?.update(inset: Metrics.topBottomPadding)
    } else {
      self.leadingConstraint?.update(inset: Metrics.minimalLeftRightPadding)
      self.trailingConstraint?.update(inset: Metrics.minimalLeftRightPadding)
      self.topConstraint?.update(inset: Metrics.minimalTopBottomPadding)
      self.bottomConstraint?.update(inset: Metrics.minimalTopBottomPadding)
    }
    
    if viewModel.translateState == .translated {
      if let translated = self.viewModel?.translatedText {
        self.messageView.attributedText = translated
      }
    } else if let attributedText = viewModel.attributedText {
      self.messageView.attributedText = attributedText
    } else {
      self.messageView.text = viewModel.message.message
    }
    
    if viewModel.isDeleted {
      self.backgroundColor = .grey200
      self.messageView.textColor = .grey500
    } else {
      self.backgroundColor = viewModel.bubbleBackgroundColor
      self.messageView.textColor = viewModel.textColor
    }

    self.messageView.linkTextAttributes = [
      .foregroundColor: viewModel.linkColor,
      .underlineStyle: 1
    ]
    
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
      self.roundCorners(corners: [.topLeft, .bottomRight, .bottomLeft], radius: Constants.cornerRadius)
    } else {
      self.roundCorners(corners: [.topRight, .bottomRight, .bottomLeft], radius: Constants.cornerRadius)
    }
  }
  
  class func viewHeight(
    fits width: CGFloat,
    viewModel: MessageCellModelType,
    edgeInset: UIEdgeInsets? = nil) -> CGFloat {
    var viewHeight : CGFloat = 0.0

    let text = viewModel.translateState == .loading || viewModel.translateState == .original ?
      viewModel.attributedText :
      viewModel.translatedText
    
    let maxWidth = !viewModel.message.onlyEmoji ?
      width - Metrics.leftRightPadding * 2 :
      width - Metrics.minimalLeftRightPadding * 2

    let topBottomPadding = viewModel.message.onlyEmoji ?
      Metrics.minimalTopBottomPadding : Metrics.topBottomPadding
    
    if let edgeInset = edgeInset {
      placeHolder.textContainerInset = edgeInset
    } else {
      placeHolder.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
    }
    
    placeHolder.frame = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
    placeHolder.textContainer.lineFragmentPadding = 0
    placeHolder.attributedText = text
    placeHolder.sizeToFit()
    
    viewHeight += placeHolder.frame.size.height + topBottomPadding * 2
    return viewHeight
  }
}

extension TextMessageView : UITextViewDelegate {
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange) -> Bool {
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
  
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
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

}
