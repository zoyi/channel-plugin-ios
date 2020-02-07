//
//  UIFont+Traits.swift
//  Pods
//
//  Created by Ivan Bruel on 19/07/16.
//
//
import UIKit

extension UIFont {
  func withTraits(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
    let descriptor = fontDescriptor
      .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
    return UIFont(descriptor: descriptor!, size: 0)
  }

  func bold() -> UIFont {
    return UIFont.boldSystemFont(ofSize: self.pointSize)
  }

  func italic() -> UIFont {
    //you can use withTraits but it doesn't work on non-english font
    let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(self.pointSize * CGFloat.pi / 180))), d: 1, tx: 0, ty: 0)
    let descriptor = self.fontDescriptor.withMatrix(matrix)
    return UIFont(descriptor: descriptor, size: self.pointSize)
  }

  func boldItalic() -> UIFont {
    let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(self.pointSize * CGFloat.pi / 180))), d: 1, tx: 0, ty: 0)
    let descriptor = self.bold().fontDescriptor.withMatrix(matrix)
    return UIFont(descriptor: descriptor, size: self.pointSize)
  }
}
