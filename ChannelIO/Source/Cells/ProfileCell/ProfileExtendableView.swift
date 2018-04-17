//
//  ProfileExtendableView.swift
//  ChannelIO
//
//  Created by R3alFr3e on 4/11/18.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import UIKit

class ProfileExtendableView: BaseView {
  var items: [ProfileContentProtocol] = []
  var footer = UILabel().then {
    let text = CHAssets.localized("ch.agreement")
    $0.text = text
    $0.font = UIFont.systemFont(ofSize: 11)
    $0.textColor = CHColors.blueyGrey
    $0.textAlignment = .center
    
    let range = text.range(of: CHAssets.localized("ch.terms_of_service"))
    $0.attributedText = $0.text?.addFont(
      UIFont.boldSystemFont(ofSize: 11),
      color: CHColors.blueyGrey,
      on: NSRange(range!, in: text))
  }
  
  var presenter: ChatManager? = nil
  
  override func initialize() {
    super.initialize()
    self.addSubview(self.footer)
    _ = self.footer.signalForClick().subscribe { _ in
      UserChatActions.openAgreement()
    }
    self.layer.borderColor = CHColors.dark10.cgColor
    self.layer.borderWidth = 1.f
    self.layer.cornerRadius = 6.f
    
    self.layer.shadowColor = CHColors.dark.cgColor
    self.layer.shadowOpacity = 0.2
    self.layer.shadowOffset = CGSize(width: 0, height: 2)
    self.layer.shadowRadius = 2
    self.backgroundColor = CHColors.white
  }
  
  override func setLayouts() {
    super.setLayouts()
    
    self.footer.snp.makeConstraints { (make) in
      make.bottom.equalToSuperview().inset(12)
      make.left.equalToSuperview().inset(14)
      make.right.equalToSuperview().inset(14)
    }
  }
  
  func configure(model: MessageCellModelType, presenter: ChatManager? = nil) {
    self.presenter = presenter
    
    self.items.forEach { (item) in
      item.view.removeFromSuperview()
    }
    self.items = []
    var lastView: UIView?
    
    for (index, item) in model.profileItems.enumerated() {
      self.footer.isHidden = index != 0
      if item.value != nil {
        let completionView = ProfileCompletionView()
        completionView.configure(model: model, index: index, presenter: presenter)
        self.addSubview(completionView)
        self.items.append(completionView)
        
        completionView.snp.makeConstraints({ (make) in
          if let lview = lastView {
            make.top.equalTo(lview.snp.bottom)
          } else {
            make.top.equalToSuperview().inset(10)
          }
          make.height.equalTo(80)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          if index == 3 {
            make.bottom.equalToSuperview()
          }
        })
        lastView = completionView
      } else {
        var itemView: ProfileContentProtocol?
        if item.key == "email" {
          let textView = ProfileTextView()
          textView.configure(model: model, index: index, presenter: self.presenter)
          self.addSubview(textView)
          self.items.append(textView)
          itemView = textView
        } else if item.key == "mobileNumber" {
          let phoneView = ProfilePhoneView()
          phoneView.configure(model: model, index:index, presenter: self.presenter)
          self.addSubview(phoneView)
          self.items.append(phoneView)
          itemView = phoneView
        } else {
          let textView = ProfileTextView()
          textView.configure(model: model, index: index, presenter: self.presenter)
          self.addSubview(textView)
          self.items.append(textView)
          itemView = textView
        }
        itemView?.view.snp.makeConstraints({ (make) in
          if let lview = lastView {
            make.top.equalTo(lview.snp.bottom)
          } else {
            make.top.equalToSuperview().inset(10)
          }
          make.height.equalTo(80)
          make.leading.equalToSuperview()
          make.trailing.equalToSuperview()
          if index == 3 {
            make.bottom.equalToSuperview()
          }
        })
        break
      }
    }
  }
  
  class func viewHeight(fit width: CGFloat, model: MessageCellModelType) -> CGFloat {
    var height = 0.f
    height += 10.f //top margin
    height += CGFloat(model.currentIndex + 1) * 80.f
    if model.currentIndex == 0 {
      height += CHAssets.localized("ch.agreement").height(fits: width, font: UIFont.systemFont(ofSize: 11))
      height += 12
    }
    return height
  }
}
