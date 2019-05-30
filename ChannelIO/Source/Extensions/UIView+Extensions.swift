//
//  UIView+Extensions.swift
//  ChannelIO
//
//  Created by Haeun Chung on 28/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

extension UIView {
  
  static func activate(constraints: [NSLayoutConstraint]) {
    constraints.forEach { ($0.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false }
    NSLayoutConstraint.activate(constraints)
  }
  
  func pin(to view: UIView, insets: UIEdgeInsets = .zero) {
    UIView.activate(constraints: [
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
      rightAnchor.constraint(equalTo: view.rightAnchor, constant: -insets.right)
    ])
  }
  
  func center(in view: UIView, offset: UIOffset = .zero) {
    UIView.activate(constraints: [
      centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: offset.horizontal),
      centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: offset.vertical)
    ])
  }
  
}

extension UIViewController {
  private static let insetBackgroundViewTag = 98721 //Cool number
  
  func paintSafeAreaBottomInset(with color: UIColor?) {
    guard #available(iOS 11.0, *) else {
      return
    }
    if let insetView = view.viewWithTag(UIViewController.insetBackgroundViewTag) {
      insetView.backgroundColor = color
      return
    }
    
    let insetView = UIView(frame: .zero)
    insetView.tag = UIViewController.insetBackgroundViewTag
    insetView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(insetView)
    view.sendSubviewToBack(insetView)
    
    insetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    insetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    insetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    insetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    insetView.backgroundColor = color
  }
}
