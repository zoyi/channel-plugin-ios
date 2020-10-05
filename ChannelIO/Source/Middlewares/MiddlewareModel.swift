//
//  MiddlewareModel.swift
//  ch-desk-ios
//
//  Created by R3alFr3e on 9/16/19.
//  Copyright © 2019 ZOYI. All rights reserved.
//

import Foundation

typealias SimpleMiddleware<State: ReSwift_StateType> = (ReSwift_Action, MiddlewareContext<State>) -> ReSwift_Action?

struct MiddlewareContext<State: ReSwift_StateType> {
  let dispatch: ReSwift_DispatchFunction
  let getState: () -> State?
  let next: ReSwift_DispatchFunction
  var state: State? {
    return getState()
  }
}

func createMiddleware<State: ReSwift_StateType>(_ middleware: @escaping SimpleMiddleware<State>) -> ReSwift_Middleware<State> {
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
