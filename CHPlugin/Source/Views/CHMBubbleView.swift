//
//  CHMBubbleView.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 20..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import Foundation
import SnapKit

class CHMBubbleView : BaseView {

  //MARK: Constant

  struct Metric {
    static let topBottomPadding = 10.f
    static let leftRightPadding = 12.f
    static let actionLabelTopMargin = 10.f
    static let actionLabelTopBottomPadding = 10.f
  }

  struct Constant {
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
    static let message = UIColor.black
  }

  //MARK: Properties

  let actionView = UIView().then {
    $0.backgroundColor = UIColor.white
  }

  let actionLabel = UILabel().then {
    $0.numberOfLines = 1
    $0.font = Font.actionLabel
    $0.textColor = Color.actionLabel
    $0.textAlignment = .center
  }

  let messageView = UITextView().then {
    $0.font = Font.messageView
    $0.textAlignment = NSTextAlignment.left
    $0.backgroundColor = UIColor.clear
    $0.isScrollEnabled = false
    $0.isEditable = false
    $0.isSelectable = true
    $0.dataDetectorTypes = UIDataDetectorTypes.link
    $0.textContainer.lineFragmentPadding = 0
    $0.textContainerInset = UIEdgeInsets.zero
  }

  var viewModel: MessageCellModelType?

  //MARK: init

  override func initialize() {
    super.initialize()
    self.messageView.delegate = self
    
    self.layer.cornerRadius = Constant.singleCornerRadius
    self.addSubview(self.messageView)
    self.addSubview(self.actionView)
    self.actionView.addSubview(self.actionLabel)
  }

  func configure(_ viewModel: MessageCellModelType) {
    self.backgroundColor = viewModel.bubbleBackgroundColor 
    
    self.messageView.text = viewModel.message.message
    self.messageView.textColor = viewModel.createdByMe ? viewModel.textColor : Color.message
    //self.messageView.tintColor = viewModel.createdByMe ? viewModel.textColor : UIColor.blue
    let linkColor = viewModel.createdByMe ? viewModel.textColor : CHColors.cobalt
    self.messageView.linkTextAttributes = [
      NSAttributedStringKey.foregroundColor.rawValue: linkColor,
      NSAttributedStringKey.underlineStyle.rawValue: 1]
    self.actionLabel.text = viewModel.actionText
    self.actionView.isHidden = !viewModel.isActionable
    self.actionLabel.isHidden = !viewModel.isActionable

    self.viewModel = viewModel
  }

  //MARK: layout

  override func layoutSubviews() {
    super.layoutSubviews()
    
    //TODO: performance check
    if self.viewModel?.isContinuous == true {
      self.roundCorners(corners: [.allCorners], radius: Constant.cornerRadius)
    } else if self.viewModel?.createdByMe == true {
      self.roundCorners(corners: [.topLeft, .bottomRight, .bottomLeft], radius: Constant.cornerRadius)
    } else {
      self.roundCorners(corners: [.topRight, .bottomRight, .bottomLeft], radius: Constant.cornerRadius)
    }

    self.messageView.snp.remakeConstraints({ [weak self] (make) in
      if self?.messageView.text == "" {
        return
      }
      make.leading.equalToSuperview().inset(Metric.leftRightPadding).priority(999)
      make.top.equalToSuperview().inset(Metric.topBottomPadding)
      make.trailing.equalToSuperview().inset(Metric.leftRightPadding).priority(999)
      if self?.actionView.isHidden == true {
        make.bottom.equalToSuperview().inset(Metric.topBottomPadding)
      }
    })

    self.actionView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: Constant.actionViewBottomRadius)
    self.actionView.snp.remakeConstraints { [weak self] (make) in
      make.leading.equalToSuperview().inset(3).priority(1000)
      make.trailing.equalToSuperview().inset(3).priority(1000)
      if self?.actionView.isHidden == true {
        make.top.equalTo((self?.messageView.snp.bottom)!)
        make.bottom.equalToSuperview()
      } else {
        make.top.equalTo((self?.messageView.snp.bottom)!).offset(Metric.actionLabelTopMargin)
        make.bottom.equalToSuperview().inset(3)
      }
    }

    self.actionLabel.snp.remakeConstraints { [weak self] (make) in
      if self?.actionView.isHidden == true {
        make.top.equalToSuperview()
        make.bottom.equalToSuperview()
      } else {
        make.top.equalToSuperview().inset(Metric.actionLabelTopBottomPadding)
        make.bottom.equalToSuperview().inset(Metric.actionLabelTopBottomPadding)
      }
      make.centerX.equalToSuperview()
      make.leading.greaterThanOrEqualToSuperview().inset(10)
      make.trailing.greaterThanOrEqualToSuperview().inset(10)
    }
  }

  class func measureHeight(fits width: CGFloat, viewModel: MessageCellModelType) -> CGFloat {
    var viewHeight : CGFloat = 0.0

    if let msg = viewModel.message.message {
      viewHeight += msg.height(fits: width - Metric.leftRightPadding * 2, font: Font.messageView)
      viewHeight += Metric.topBottomPadding * 2
    }

    if viewModel.isActionable {
      viewHeight += Metric.actionLabelTopMargin + Metric.actionLabelTopBottomPadding * 2
      viewHeight += 13 // action label font height
    }

    return viewHeight
  }
}

extension CHMBubbleView : UITextViewDelegate {
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange) -> Bool {
    let shouldhandle = ChannelPlugin.delegate?.shouldHandleChatLink?(url: URL)
    return shouldhandle == true || shouldhandle == nil
  }
  
  @available(iOS 10.0, *)
  func textView(_ textView: UITextView,
                shouldInteractWith URL: URL,
                in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    let shouldhandle = ChannelPlugin.delegate?.shouldHandleChatLink?(url: URL)
    if shouldhandle == true || shouldhandle == nil {
      URL.openWithUniversal()
    }
    
    return false
  }

}
