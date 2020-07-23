//
//  ProfileExtendableView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit

class ProfileExtendableView: BaseView {
  struct Metric {
    static let footerLeading = 12.f
    static let footerTrailing = 12.f
    static let footerBottom = 12.f
    static let topMargin = 10.f
    static let bottomMargin = 10.f
    static let itemHeight = 73.f
    static let itemTop = 4.f
    static let shadowHeight = 2.f
  }
  
  var items: [ProfileContentProtocol] = []
  var footerLabel = UILabel().then {
    $0.numberOfLines = 0

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.minimumLineHeight = 16.f
    paragraph.lineBreakMode = CHAssets.localized("ch.agreement").guessLanguage() == "日本語" ?
      .byCharWrapping : .byWordWrapping
    let font = UIFont.systemFont(ofSize: 11)
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: CHColors.blueyGrey,
      .paragraphStyle: paragraph,
      .baselineOffset: (paragraph.minimumLineHeight - font.lineHeight)/4
    ]
    
    let tagAttributes: [StringTagType: [NSAttributedString.Key: Any]] = [
      .bold:[
        .font: UIFont.boldSystemFont(ofSize: 11),
        .foregroundColor: CHColors.blueyGrey,
        .paragraphStyle: paragraph
      ]
    ]
    
    $0.attributedText = CHAssets.localized(
      "ch.agreement",
      attributes: attributes,
      tagAttributes: tagAttributes)
  }
  
  var shouldBecomeFirstResponder = false
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.footerLabel)
    
    _ = self.footerLabel.signalForClick().subscribe { _ in
      UserChatActions.openAgreement()
    }
    
    self.layer.borderColor = CHColors.dark10.cgColor
    self.layer.borderWidth = 1.f
    self.layer.cornerRadius = 6.f
    
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOpacity = 0.2
    self.layer.shadowOffset = CGSize(width: 0, height: Metric.shadowHeight)
    self.layer.shadowRadius = 2
    self.backgroundColor = CHColors.white
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.footerLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(Metric.footerBottom)
      make.leading.equalToSuperview().inset(Metric.footerLeading)
      make.trailing.equalToSuperview().inset(Metric.footerTrailing)
    }
  }
  
  func configure(model: MessageCellModelType, presenter: UserChatPresenterProtocol? = nil, redraw: Bool = false) {
    if redraw {
      presenter?.shouldRedrawProfileBot = false
      self.drawViews(model: model, presenter: presenter)
    } 
  }
  
  func drawViews(model: MessageCellModelType, presenter: UserChatPresenterProtocol? = nil) {
    for item in self.items {
      if item.didFirstResponder {
        self.shouldBecomeFirstResponder = true
        break
      }
    }
    
    //NOTE: this can be optimized, do not draw everything again if not necessary
    self.items.forEach { (item) in
      item.view.removeFromSuperview()
    }
    self.items = []
    var lastView: UIView?
    
    for (index, item) in model.profileItems.enumerated() {
      if item.value != nil {
        let completionView = ProfileCompletionView()
        completionView.configure(model: model, index: index, presenter: presenter)
        self.addSubview(completionView)
        self.items.append(completionView)
        
        completionView.snp.makeConstraints({ (make) in
          if let lview = lastView {
            make.top.equalTo(lview.snp.bottom).offset(Metric.itemTop)
          } else {
            make.top.equalToSuperview().inset(Metric.topMargin)
          }
          make.height.equalTo(Metric.itemHeight)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          if index != 0, index == model.profileItems.count - 1 {
            make.bottom.equalToSuperview().inset(Metric.bottomMargin)
          }
        })
        lastView = completionView
      } else {
        var itemView: ProfileContentProtocol?
        if item.fieldType == .mobileNumber {
          let phoneView = ProfilePhoneView()
          phoneView.configure(model: model, index:index, presenter: presenter)
          self.addSubview(phoneView)
          self.items.append(phoneView)
          itemView = phoneView
        } else if item.type == .boolean {
          let booleanView = ProfileBooleanView()
          booleanView.fieldType = item.fieldType
          booleanView.configure(model: model, index: index, presenter: presenter)
          self.addSubview(booleanView)
          self.items.append(booleanView)
          itemView = booleanView
        } else if item.type == .date {
          let dateView = ProfileDateView()
          dateView.fieldType = item.fieldType
          dateView.configure(model: model, index: index, presenter: presenter)
          self.addSubview(dateView)
          self.items.append(dateView)
          itemView = dateView
        } else {
          let textView = ProfileTextView()
          textView.fieldType = item.fieldType
          textView.configure(model: model, index: index, presenter: presenter)
          self.addSubview(textView)
          self.items.append(textView)
          itemView = textView
        }
        
        if self.shouldBecomeFirstResponder {
          dispatch(delay: 0.3) {
            itemView?.responder.becomeFirstResponder()
          }
        }
        
        itemView?.view.snp.makeConstraints({ (make) in
          if let lview = lastView {
            make.top.equalTo(lview.snp.bottom).offset(Metric.itemTop)
          } else {
            make.top.equalToSuperview().inset(Metric.topMargin)
          }
          make.height.equalTo(Metric.itemHeight)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          if index != 0, index == model.profileItems.count - 1 {
            make.bottom.equalToSuperview().inset(Metric.bottomMargin)
          }
        })
        break
      }
    }
    
    self.footerLabel.isHidden = self.items.count != 1
  }
  
  class func viewHeight(fit width: CGFloat, model: MessageCellModelType) -> CGFloat {
    var height = 0.f
    height += Metric.topMargin
    height += CGFloat(model.currentIndex + 1) * (Metric.itemHeight)
    height += CGFloat(model.currentIndex) * (Metric.itemTop)
    if model.currentIndex == 0 {
      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .center
      paragraph.minimumLineHeight = 16.f
      paragraph.lineBreakMode = .byCharWrapping
      let font = UIFont.systemFont(ofSize: 11)
      let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: CHColors.blueyGrey,
        .paragraphStyle: paragraph,
        .baselineOffset: (paragraph.minimumLineHeight - font.lineHeight)/4
      ]
      
      let tagAttributes: [StringTagType: [NSAttributedString.Key: Any]] = [
        StringTagType.bold:[
          .font: font,
          .foregroundColor: CHColors.blueyGrey,
          .paragraphStyle: paragraph,
          .baselineOffset: (paragraph.minimumLineHeight - font.lineHeight)/4
        ]
      ]
      
      let text = CHAssets.localized(
        "ch.agreement",
        attributes: attributes,
        tagAttributes: tagAttributes) 
      
      height += text.height(fits: width - Metric.footerLeading - Metric.footerTrailing)
      height += Metric.footerBottom
    } else {
      height += Metric.bottomMargin
    }
    return height
  }
}
