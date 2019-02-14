//
//  UINavigation+Extensions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 6/20/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
  func popViewController(animated: Bool, completion: @escaping ()->()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.popViewController(animated: animated)
    CATransaction.commit()
  }
  func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping ()->()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}

extension UIViewController {
  var isModal: Bool {
    let presentingIsModal = presentingViewController != nil
    let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
    let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
    return presentingIsModal || presentingIsNavigation || presentingIsTabBar || false
  }
  
  var baseController: UIViewController {
    if let tabBarViewController = self.tabBarController {
      return tabBarViewController
    }
    if let navigationController = self.navigationController {
      return navigationController
    }
    return self
  }
}

