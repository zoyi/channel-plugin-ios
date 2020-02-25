//
//  TextMessageView.swft
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 20..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import SnapKit

let placeHolder = UITextView().then {
  $0.textContainer.lineFragmentPadding = 0
  $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
}

class TextMessageView : BaseView {
  private struct Metrics {
    static let topBottomPadding = 10.f
    static let leftRightPadding = 12.f
    static let minimalTopBottomPadding = 2.f
    static let minimalLeftRightPadding = 5.f
    static let textViewMinimalWidth = 20.f
    static let textViewInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
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
    $0.textContainerInset = Metrics.textViewInset
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
    guard let displayText = viewModel.text else {
      self.isHidden = true
      return
    }
    self.isHidden = false
    self.backgroundColor = displayText.string.containsOnlyEmoji ?
      UIColor.clear : viewModel.bubbleBackgroundColor
    let attrText = NSMutableAttributedString(attributedString: displayText)
    attrText.addAttribute(
      .foregroundColor,
      value: viewModel.textColor,
      range: NSRange(location: 0, length: attrText.string.utf16.count)
    )
    self.messageView.attributedText = attrText
    
    self.messageView.linkTextAttributes = [
      .foregroundColor: viewModel.linkColor,
      .underlineStyle: 1
    ]
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
      self.roundCorners(corners: [.topLeft, .bottomRight, .bottomLeft], radius: Constants.cornerRadius)
    } else {
      self.roundCorners(corners: [.topRight, .bottomRight, .bottomLeft], radius: Constants.cornerRadius)
    }
  }
  
  static func viewHeight(
    fit width: CGFloat,
    model: MessageCellModelType,
    edgeInset: UIEdgeInsets? = nil) -> CGFloat {
    guard let text = model.text, text.string != "" else {
      return 0
    }
    
    var insets: UIEdgeInsets
    if let edgeInset = edgeInset {
      insets = edgeInset
    } else {
      insets = Metrics.textViewInset
    }

    let maxWidth = width - Metrics.leftRightPadding * 2
    let topBottomPadding = Metrics.topBottomPadding * 2

    var viewHeight: CGFloat = 0
    placeHolder.textContainerInset = insets
    placeHolder.frame = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
    placeHolder.attributedText = text
    placeHolder.sizeToFit()

    viewHeight += placeHolder.frame.size.height + topBottomPadding
    return viewHeight
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
  
  @available(iOS 10.0, *)
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

}
