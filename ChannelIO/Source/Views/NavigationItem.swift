//
//  NavigationButton.swift
//  ch-desk-ios
//
//  Created by Haeun Chung on 15/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

enum NavigationItemAlign {
  case left
  case right
  case center
}

class CHNavigationBar: UINavigationBar {
  override func layoutSubviews() {
    super.layoutSubviews()

    if #available(iOS 11, *){
      self.layoutMargins = UIEdgeInsets.zero
      for subview in self.subviews {
        if String(describing: subview.classForCoder).contains("ContentView") {
          //let oldEdges = subview.layoutMargins
          subview.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
      }
    }
  }
}

class NavigationItem: UIBarButtonItem {
  public var actionHandler: (() -> Void)?
  
  convenience init(
    image: UIImage?,
    text: String? = "",
    fitToSize: Bool = false,
    alignment: NavigationItemAlign = .left,
    textColor: UIColor? = UIColor.white,
    actionHandler: (() -> Void)?) {
    
    let button = UIButton(type: .custom)
    button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.setTitle(text, for: .normal)
    button.imageView?.tintColor = textColor
    button.setTitleColor(textColor, for: .normal)
    if fitToSize {
      button.sizeToFit()
    }
    
    if alignment == .left {
      button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
      button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    } else if alignment == .right {
      button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
      button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    } else {
      button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
      button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    }
    
    button.widthAnchor.constraint(equalToConstant: 55).isActive = true
    button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    button.translatesAutoresizingMaskIntoConstraints = false
    
    self.init(customView: button)
    button.addTarget(self, action: #selector(barButtonItemPressed), for: .touchUpInside)
    self.actionHandler = actionHandler
  }
  
  convenience init(
    title: String?,
    style: UIBarButtonItem.Style,
    textColor: UIColor = CHColors.defaultTint,
    actionHandler: (() -> Void)?) {
    
    self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed))
    self.target = self
    self.actionHandler = actionHandler
    self.setTitleTextAttributes([.foregroundColor:textColor], for: .normal)
    
    let disableColor = textColor.withAlphaComponent(0.3)
    self.setTitleTextAttributes([.foregroundColor:disableColor], for: .disabled)
  }
  
  convenience init(
    image: UIImage?,
    tintColor: UIColor? = nil,
    style: UIBarButtonItem.Style,
    actionHandler: (() -> Void)?) {
    
    var itemImage: UIImage? = image
    if let tintColor = tintColor {
      itemImage = image?.withRenderingMode(.alwaysTemplate).tint(with:tintColor)
    }
    
    self.init(image: itemImage, style: style, target: nil, action: #selector(barButtonItemPressed))
    self.target = self
    self.actionHandler = actionHandler
  }
  
  @objc func barButtonItemPressed(sender: UIBarButtonItem) {
    actionHandler?()
  }
}
