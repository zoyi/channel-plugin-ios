//
//  Tracking.swift
//  ChannelIO
//
//  Created by Haeun Chung on 16/11/2018.
//  Copyright © 2018 ZOYI. All rights reserved.
//

import Foundation

public extension UIViewController {
  static let swizzleForTracking: Void = {
    let originalSelector = #selector(viewWillAppear(_:))
    let swizzledSelector = #selector(ch_viewWillAppear(_:))
    
    guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector) else { return }
    guard let  swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return }
    
    let didAddMethod = class_addMethod(
      UIViewController.self,
      originalSelector,
      method_getImplementation(swizzledMethod),
      method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
      class_replaceMethod(
        UIViewController.self, swizzledSelector,
        method_getImplementation(originalMethod),
        method_getTypeEncoding(originalMethod)
      )
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  }()
  
  // MARK: - Method Swizzling
  
  @objc
  func ch_viewWillAppear(_ animated: Bool) {
    self.ch_viewWillAppear(animated)
    guard ChannelIO.isValidStatus else { return }
    guard ChannelIO.settings?.enabledTrackDefaultEvent == true else { return }
    //dynamic configuration?
    
    ChannelIO.sendDefaultEvent(.pageView, property: [
      TargetKey.url.rawValue: "\(type(of: self))"
    ])
  }
}
