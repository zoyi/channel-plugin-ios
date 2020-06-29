//
//  UIView+Transition.swift
//  CHPlugin
//
//  Created by Haeun Chung on 14/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit

enum UIViewTransition : Int {
  case TopToBottom
  case BottomToTop
  case LeftToRight
  case RightToLeft
}

internal extension UIView {
  func insert(on view: UIView, animated: Bool) {
    view.addSubview(self)
    
    if !animated {
      self.alpha = 1
      return
    }
    
    self.alpha = 0
    UIView.transition(with: self, duration: 0.5, options: .curveEaseOut, animations: {
      self.alpha = 1
    }) { (completed) in
      
    }
  }
  
  func remove(animated: Bool) {
    if !animated {
      self.removeFromSuperview()
      return
    }
    
    UIView.transition(with: self, duration: 0.5, options: .curveEaseOut, animations: {
      self.alpha = 0
    }) { (completed) in
      self.removeFromSuperview()
    }
  }
  
  func show(animated: Bool) {
    self.isHidden = false
    
    if !animated {
      self.alpha = 1
      return
    }
    
    UIView.animate(withDuration: 0.5) {
      self.alpha = 1
    }
  }
  
  func hide(animated: Bool, completion: (() -> ())? = nil) {
    guard animated else {
      self.alpha = 0
      completion?()
      return
    }

    UIView.animate(withDuration: 0.5, animations: {
      self.alpha = 0
    }) { (completed) in
      completion?()
    }
  }
  
  private static let kRotationAnimationKey = "ch_rotationanimationkey"
  
  func rotate(duration: Double = 1) {
    if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
      let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
      
      rotationAnimation.fromValue = 0.0
      rotationAnimation.toValue = Float.pi * 2.0
      rotationAnimation.duration = duration
      rotationAnimation.repeatCount = Float.infinity
      
      layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
    }
  }
  
  func stopRotating() {
    if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
      layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
    }
  }
}

internal extension UIView {
  func fadeTransition(_ duration:CFTimeInterval) {
    let animation = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
      .easeInEaseOut)
    animation.type = .fade
    animation.duration = duration
    layer.add(animation, forKey: CATransitionType.fade.rawValue)
  }
}
