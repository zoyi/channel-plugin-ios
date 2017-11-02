//
//  UserAction.swift
//  CHPlugin
//
//  Created by Haeun Chung on 16/02/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

import RxSwift

protocol DialogAction {
  func signalForAction() -> PublishSubject<Any?>
}

class DialogActionView : BaseView, DialogAction {
  func signalForAction() -> PublishSubject<Any?> {
    assert(false)
    return PublishSubject<Any?>()
  }
}
