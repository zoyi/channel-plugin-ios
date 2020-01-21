//
//  UIResponder+Extensions.swift
//  ChannelIO
//
//  Created by R3alFr3e on 1/21/20.
//  Copyright © 2020 ZOYI. All rights reserved.
//

import Foundation

extension UIResponder {
  private static weak var _currentFirstResponder: UIResponder?

  static var currentFirst: UIResponder? {
    _currentFirstResponder = nil
    UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)

    return _currentFirstResponder
  }

  @objc func findFirstResponder(_ sender: Any) {
    UIResponder._currentFirstResponder = self
  }
}
