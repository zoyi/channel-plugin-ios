//
//  UIImage+Extensions.swift
//  CHPlugin
//
//  Created by Haeun Chung on 19/05/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import UIKit

extension UIImage {
  func overlayWith(color: UIColor) -> UIImage? {
    let maskImage = cgImage!
    
    let width = size.width
    let height = size.height
    let bounds = CGRect(x: 0, y: 0, width: width, height: height)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    let context = CGContext(
      data: nil,
      width: Int(width),
      height: Int(height),
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: bitmapInfo.rawValue)!
    
    context.clip(to: bounds, mask: maskImage)
    context.setFillColor(color.cgColor)
    context.fill(bounds)
    
    if let cgImage = context.makeImage() {
      let coloredImage = UIImage(cgImage: cgImage)
      return coloredImage
    } else {
      return nil
    }
  }
  
  func normalizedImage() -> UIImage {
    if (self.imageOrientation == UIImageOrientation.up) {
      return self
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    self.draw(in: rect)
    
    let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return normalizedImage
  }
}

extension UIImage {
  func tint(with color: UIColor?) -> UIImage {
    guard let color = color else { return self }
    return modifiedImage { context, rect in
      context.setBlendMode(.multiply)
      context.clip(to: rect, mask: self.cgImage!)
      color.setFill()
      context.fill(rect)
    }
  }
  
  private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
    
    // using scale correctly preserves retina images
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    defer { UIGraphicsEndImageContext() }
    guard let context = UIGraphicsGetCurrentContext() else { return self }
    
    // correctly rotate image
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    
    let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    
    draw(context, rect)
    
    guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
    return newImage
  }
  
}
