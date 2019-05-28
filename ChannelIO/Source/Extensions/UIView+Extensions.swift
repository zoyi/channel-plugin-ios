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
