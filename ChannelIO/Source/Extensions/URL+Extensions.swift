//
//  URL+Extensions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 10/25/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

extension URL {
  func openWithUniversal() {
    guard UIApplication.shared.canOpenURL(self) else { return }
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(self, options: [UIApplicationOpenURLOptionUniversalLinksOnly:true]) { (completed) in
        let scheme = self.scheme ?? ""
        if !completed && (scheme == "http" || scheme == "https") {
          let controller = SFSafariViewController(url: self)
          CHUtils.getTopController()?.present(controller, animated: true, completion: nil)
        } else {
          UIApplication.shared.openURL(self)
        }
      }
    } else {
      let controller = SFSafariViewController(url: self)
      CHUtils.getTopController()?.present(controller, animated: true, completion: nil)
    }
  }
  
  func open() {
    guard UIApplication.shared.canOpenURL(self) else { return }
    
    if let scheme = self.scheme, scheme == "http" || scheme == "https" {
      let controller = SFSafariViewController(url: self)
      CHUtils.getTopController()?.present(controller, animated: true, completion: nil)
    } else {
      UIApplication.shared.openURL(self)
    }
    
  }
}
