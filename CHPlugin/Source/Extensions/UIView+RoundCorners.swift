//
//  UIView+RoundCorners.swift
//  CHPlugin
//
//  Created by 이수완 on 2017. 3. 22..
//  Copyright © 2017년 ZOYI. All rights reserved.
//

import UIKit

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    self.layer.setNeedsLayout()
    self.layer.layoutIfNeeded()
    
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
