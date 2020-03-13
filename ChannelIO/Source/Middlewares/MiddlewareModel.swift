//
//  MiddlewareModel.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 9/16/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation
import ReSwift

typealias SimpleMiddleware<State: StateType> = (Action, MiddlewareContext<State>) -> Action?

struct MiddlewareContext<State: StateType> {
  let dispatch: DispatchFunction
  let getState: () -> State?
  let next: DispatchFunction
  var state: State? {
    return getState()
  }
}

func createMiddleware<State: StateType>(_ middleware: @escaping SimpleMiddleware<State>) -> ReSwift.Middleware<State> {
  return { dispatch, getState in
    return { next in
      return { action in
        let context = MiddlewareContext(dispatch: dispatch, getState: getState, next: next)
        if let newAction = middleware(action, context) {
          next(newAction)
        }
      }
    }
  }
}
