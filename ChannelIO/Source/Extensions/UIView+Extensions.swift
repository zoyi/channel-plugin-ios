//
//  UIView+Extensions.swift
//  ChannelIO
//
//  Created by Haeun Chung on 28/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import RxSwift

enum ShimmerDirection: Int {
  case leftToRight
}

internal extension UIView {
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
  
  var util_safeAreaInsets: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return safeAreaInsets
    } else {
      return .zero
    }
  }
  
  var firstResponder: UIView? {
    guard !isFirstResponder else { return self }

    for subview in subviews {
      if let firstResponder = subview.firstResponder {
        return firstResponder
      }
    }

    return nil
  }

  func startShimmeringAnimation(
    animationSpeed: Float = 1.0,
    direction: ShimmerDirection = .leftToRight,
    repeatCount: Float = MAXFLOAT) {
    let lightColor = UIColor.white.cgColor
    let alphaColor = UIColor.white.withAlphaComponent(0.6).cgColor
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [alphaColor, lightColor, alphaColor]
    gradientLayer.frame = CGRect(
      x: -self.bounds.size.width,
      y: -self.bounds.size.height,
      width: 3 * self.bounds.size.width,
      height: 3 * self.bounds.size.height
    )
    
    switch direction {
    case .leftToRight:
      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    gradientLayer.locations =  [0.35, 0.50, 0.65]
    self.layer.mask = gradientLayer
    
    CATransaction.begin()
    let animation = CABasicAnimation(keyPath: "locations")
    animation.fromValue = [0.0, 0.1, 0.2]
    animation.toValue = [0.8, 0.9, 1.0]
    animation.duration = CFTimeInterval(animationSpeed)
    animation.repeatCount = repeatCount
    CATransaction.setCompletionBlock { [weak self] in
      guard let self = self else { return }
      self.layer.mask = nil
    }
    gradientLayer.add(animation, forKey: "shimmerAnimation")
    CATransaction.commit()
  }
  
  func stopShimmeringAnimation() {
    self.layer.mask = nil
  }
}

internal extension UIScrollView {
  var util_adjustedContentInset: UIEdgeInsets {
    if #available(iOS 11.0, *) {
      return adjustedContentInset
    } else {
      return contentInset
    }
  }
  
  func stopScrolling() {
    guard isDragging else { return }

    var offset = contentOffset
    offset.y -= 1
    self.setContentOffset(offset, animated: false)
    offset.y += 1
    self.setContentOffset(offset, animated: false)
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
    view.bringSubviewToFront(insetView)
    
    insetView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    insetView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    insetView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    insetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    insetView.backgroundColor = color
  }
}
