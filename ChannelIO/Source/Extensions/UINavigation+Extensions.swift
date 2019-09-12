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
  
  func popToRootViewController(animated: Bool, completion: @escaping () -> ()) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    self.popToRootViewController(animated: animated)
    CATransaction.commit()
  }
  
  func dropShadow() {
    self.navigationBar.dropShadow(with: CHColors.black10, opacity: 0.5, offset: CGSize(width:0, height:2), radius: 2)
  }
  
  func removeShadow() {
    self.navigationBar.removeShadow()
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

extension UINavigationBar {
  func setGradientBackground(
    colors: [UIColor],
    startPoint: CAGradientLayer.Point = .topLeft,
    endPoint: CAGradientLayer.Point = .bottomLeft) {
    var updatedFrame = bounds
    updatedFrame.size.height += self.frame.origin.y
    let gradientLayer = CAGradientLayer(
      frame: updatedFrame,
      colors: colors,
      startPoint: startPoint,
      endPoint: endPoint
    )
    gradientLayer.isOpaque = true
    setBackgroundImage(gradientLayer.createGradientImage(),for: .default)
  }
}

extension UIViewController {
  func isVisible() -> Bool {
    return self.isViewLoaded && self.view.window != nil
  }
}
