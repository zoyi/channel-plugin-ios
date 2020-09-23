//
//  CHView.swift
//  ChannelIO
//
//  Created by Haeun Chung on 08/05/2019.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
//import RxSwift
//import RxCocoa

struct CHView {
  static func gradientImageView(
    named: String,
    colors: [UIColor],
    startPoint: CAGradientLayer.Point,
    endPoint: CAGradientLayer.Point,
    radius: CGFloat = 30.f) -> UIView {
    
    let view = UIView()
    view.layer.cornerRadius = radius
    
    let gradientView = CAGradientLayer()
    gradientView.cornerRadius = radius
    gradientView.colors = colors.map { $0.cgColor }
    gradientView.startPoint = startPoint.value
    gradientView.endPoint = endPoint.value
    
    let imageView = UIImageView()
    imageView.image = CHAssets.getImage(named: named)
    
    view.layer.addSublayer(gradientView)
    view.addSubview(imageView)
    
    _ = view.rx.observe(CGRect.self, #keyPath(UIView.bounds))
      .takeUntil(view.rx.deallocated)
      .subscribe(onNext: { bounds in
        guard let bounds = bounds else { return }
        gradientView.frame = CGRect(x: 0, y:0, width: bounds.width, height: bounds.height)
        imageView.frame = CGRect(x: 0, y:0, width: bounds.width, height: bounds.height)
      })
    
    return view
  }
}
