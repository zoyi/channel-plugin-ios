//
//  Array+Extensions.swift
//  CHPlugin
//
//  Created by Haeun Chung on 10/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import Foundation

extension Array {
  func get (index: Int) -> Element? {
    return index >= 0 && index < count ? self[index] : nil
  }
  
  mutating func popLastIf<T>(_ ele: T.Type) -> T? {
    if self.last is T {
      return self.popLast() as? T
    }
    return nil
  }
}
