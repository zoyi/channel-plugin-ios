//
//  GradientView.swift
//  ChannelIO
//
//  Created by Jam on 2019/12/16.
//

import Foundation
import UIKit

@IBDesignable class GradientView: BaseView {
  private var gradientLayer: CAGradientLayer?

  enum GradientAxis {
    case horizontal
    case vertical
  }

  @IBInspectable var topColor: UIColor = .red {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var bottomColor: UIColor = .yellow {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var shadowColor: UIColor = .clear {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var shadowX: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var shadowY: CGFloat = -3 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var shadowBlur: CGFloat = 3 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var startPointX: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var startPointY: CGFloat = 0.5 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var endPointX: CGFloat = 1 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var endPointY: CGFloat = 0.5 {
    didSet {
      setNeedsLayout()
    }
  }

  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      setNeedsLayout()
    }
  }

  var axis: GradientAxis = .vertical {
    didSet {
      switch self.axis {
      case .vertical:
        self.startPointX = 0.5
        self.startPointY = 0.0
        self.endPointX = 0.5
        self.endPointY = 1.0
      case .horizontal:
        self.startPointX = 0.0
        self.startPointY = 0.5
        self.endPointX = 1.0
        self.endPointY = 0.5
      }
    }
  }

  override class var layerClass: AnyClass {
    return CAGradientLayer.self
  }

  override func layoutSubviews() {
    self.gradientLayer = self.layer as? CAGradientLayer
    self.gradientLayer?.colors = [topColor.cgColor, bottomColor.cgColor]
    self.gradientLayer?.startPoint = CGPoint(x: startPointX, y: startPointY)
    self.gradientLayer?.endPoint = CGPoint(x: endPointX, y: endPointY)
    self.layer.cornerRadius = cornerRadius
    self.layer.shadowColor = shadowColor.cgColor
    self.layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
    self.layer.shadowRadius = shadowBlur
    self.layer.shadowOpacity = 1
  }

  func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
    let fromColors = self.gradientLayer?.colors
    let toColors: [AnyObject] = [ newTopColor.cgColor, newBottomColor.cgColor]
    self.gradientLayer?.colors = toColors
    let animation = CABasicAnimation(keyPath: "colors")
    animation.fromValue = fromColors
    animation.toValue = toColors
    animation.duration = duration
    animation.isRemovedOnCompletion = true
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    self.gradientLayer?.add(animation, forKey: "animateGradient")
  }
}
