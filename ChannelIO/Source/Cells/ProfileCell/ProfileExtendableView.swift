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
  let presenter: ChatManager? = nil
  
  override func initialize() {
    super.initialize()
    
    self.layer.borderColor = CHColors.dark10.cgColor
    self.layer.borderWidth = 1.f
    self.layer.cornerRadius = 6.f
    
    self.layer.shadowColor = CHColors.dark10.cgColor
    self.layer.shadowOpacity = 0.2
    self.layer.shadowOffset = CGSize(width: 0, height: 2)
    self.layer.shadowRadius = 3
  }
  
  override func setLayouts() {
    super.setLayouts()
  }
  
  func configure(model: MessageCellModelType) {
//    for (index, item) in self.items.enumerated() {
//      if let value = model.profileItems[index].value {
//        item.view.removeFromSuperview()
//
//        let completionView = ProfileCompletionView()
//        completionView.configure(text: "\(value)")
//        self.addSubview(completionView)
//        self.items[index] = completionView
//      }
//    }
//
    self.items.forEach { (item) in
      item.view.removeFromSuperview()
    }
    self.items = []
    var lastView: UIView?
    
    for (index, item) in model.profileItems.enumerated() {
      if let value = item.value, item.isCompleted {
        let completionView = ProfileCompletionView()
        completionView.configure(text: "\(value)")
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
  
  class func viewHeight(model: MessageCellModelType) -> CGFloat {
    //if first then check footer?
    //calculate completed fields * 80
    return 10.f + CGFloat(model.currentIndex + 1) * 80.f
  }
}
