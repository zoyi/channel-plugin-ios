//
//  UIButton+Extensions.swift
//  CHPlugin
//
//  Created by R3alFr3e on 6/20/17.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation
import UIKit
//import RxSwift

extension UIButton {
  func alignVertical(spacing: CGFloat = 6.0) {
    guard let imageSize = self.imageView?.image?.size,
      let text = self.titleLabel?.text,
      let font = self.titleLabel?.font
      else { return }
    self.titleEdgeInsets = UIEdgeInsets(
      top: 0.0, left: -imageSize.width,
      bottom: -(imageSize.height + spacing), right: 0.0)
    let labelString = NSString(string: text)
    let titleSize = labelString.size(withAttributes: [.font: font])
    self.imageEdgeInsets = UIEdgeInsets(
      top: -(titleSize.height + spacing), left: 0.0,
      bottom: 0.0, right: -titleSize.width)
    let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
    self.contentEdgeInsets = UIEdgeInsets(
      top: edgeOffset, left: 0.0,
      bottom: edgeOffset, right: 0.0)
  }
  
  private func imageWithColor(_ color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0.0, y:0.0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
  
  func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
    self.setBackgroundImage(imageWithColor(color), for: state)
  }
  
  var bottomHeightOffset: CGFloat {
    let height = bounds.size.height

    // adjust the button so its content is aligned w/ the bottom of the text view
    let titleLabelMaxY: CGFloat
    if let titleBounds = titleLabel?.frame, titleBounds != .zero {
        titleLabelMaxY = titleBounds.maxY
    } else {
        titleLabelMaxY = height
    }

    let imageViewMaxY: CGFloat
    if let imageBounds = imageView?.frame, imageBounds != .zero {
        imageViewMaxY = imageBounds.maxY
    } else {
        imageViewMaxY = height
    }

    return max(height - titleLabelMaxY, height - imageViewMaxY)
  }
}

extension _RXSwift_Reactive where Base: UIButton {
  var isHighlighted: _RXSwift_Observable<Bool> {
    let anyObservable = self.base.rx.methodInvoked(#selector(setter: self.base.isHighlighted))

    let boolObservable = anyObservable
      .flatMap { _RXSwift_Observable.from(optional: $0.first as? Bool) }
      .startWith(self.base.isHighlighted)
      .distinctUntilChanged()
      .share()

    return boolObservable
  }
  
  var isEnabled: _RXSwift_Observable<Bool> {
    let anyObservable = self.base.rx.methodInvoked(#selector(setter: self.base.isEnabled))

    let boolObservable = anyObservable
      .flatMap { _RXSwift_Observable.from(optional: $0.first as? Bool) }
      .startWith(self.base.isEnabled)
      .distinctUntilChanged()
      .share()

    return boolObservable
  }
}
