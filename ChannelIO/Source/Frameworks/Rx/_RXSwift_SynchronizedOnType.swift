//
//  SynchronizedOnType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_SynchronizedOnType : class, _RXSwift_ObserverType, _RXSwift_Lock {
    func _synchronized_on(_ event: _RXSwift_Event<Element>)
}

extension _RXSwift_SynchronizedOnType {
    func synchronizedOn(_ event: _RXSwift_Event<Element>) {
        self.lock(); defer { self.unlock() }
        self._synchronized_on(event)
    }
}
