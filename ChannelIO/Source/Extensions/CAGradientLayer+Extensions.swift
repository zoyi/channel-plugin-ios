//
//  CAGradientLayer+Extensions.swift
//  Alamofire
//
//  Created by R3alFr3e on 4/24/19.
//

import Foundation

extension CAGradientLayer {
  enum Point {
    case topRight, topLeft
    case bottomRight, bottomLeft
    case top, bottom
    case custom(point: CGPoint)
    
    var value: CGPoint {
      switch self {
      case .topRight: return CGPoint(x: 1, y: 0)
      case .topLeft: return CGPoint(x: 0, y: 0)
      case .bottomRight: return CGPoint(x: 1, y: 1)
      case .bottomLeft: return CGPoint(x: 0, y: 1)
      case .top: return CGPoint(x: 0.5, y: 0)
      case .bottom: return CGPoint(x: 0.5, y: 1)
      case .custom(let point): return point
      }
    }
  }
  
  convenience init(
    frame: CGRect,
    colors: [UIColor],
    startPoint: CGPoint,
    endPoint: CGPoint) {
    self.init()
    self.frame = frame
    self.colors = colors.map { $0.cgColor }
    self.startPoint = startPoint
    self.endPoint = endPoint
  }
  
  convenience init(
    frame: CGRect,
    colors: [UIColor],
    startPoint: Point,
    endPoint: Point) {
    self.init(
      frame: frame,
      colors: colors,
      startPoint: startPoint.value,
      endPoint: endPoint.value
    )
  }
  
  func createGradientImage() -> UIImage? {
    defer { UIGraphicsEndImageContext() }
    UIGraphicsBeginImageContext(bounds.size)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    render(in: context)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}

extension UIView {
  func dropShadow(with color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOpacity = opacity
    self.layer.shadowOffset = offset
    self.layer.shadowRadius = radius
  }
  
  func removeShadow() {
    self.layer.shadowColor = nil
    self.layer.shadowOpacity = 0
    self.layer.shadowOffset = .zero
    self.layer.shadowRadius = 0
  }
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath =  cornerRadius != 0 ?
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath :
        UIBezierPath(rect: rect).cgPath
    }
  }
}
