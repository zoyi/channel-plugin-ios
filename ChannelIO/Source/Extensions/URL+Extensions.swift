//
//  URL+Extensions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 10/25/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

extension URL {
  func openWithUniversal() {
    guard UIApplication.shared.canOpenURL(self) else { return }
    
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(self, options: [UIApplicationOpenURLOptionUniversalLinksOnly:true]) { (completed) in
        if !completed {
          UIApplication.shared.open(self, options: [:]) { (completed) in }
        }
      }
    } else {
      UIApplication.shared.openURL(self)
    }
  }
  
  func open() {
    guard UIApplication.shared.canOpenURL(self) else { return }
    
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(self, options: [:], completionHandler: nil)
    } else {
      UIApplication.shared.openURL(self)
    }
  }
}
