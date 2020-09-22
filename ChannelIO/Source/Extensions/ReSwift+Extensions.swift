//
//  ReSwift+Extensions.swift
//  CHPlugin
//
//  Created by Haeun Chung on 07/12/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

extension ReSwift_Store {
  func dispatch(_ action: ReSwift_Action, delay: Double) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
      self.dispatch(action)
    })
  }
  
  func dispatchOnMain(_ action: ReSwift_Action) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
      self.dispatch(action)
    })
  }
}
