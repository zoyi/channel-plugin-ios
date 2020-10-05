//
//  BehaviorRelay.swift
//  RxRelay
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

/// BehaviorRelay is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error or completed.
final class _RXRelay_BehaviorRelay<Element>: _RXSwift_ObservableType {
    private let _subject: _RXSwift_BehaviorSubject<Element>

    /// Accepts `event` and emits it to subscribers
    func accept(_ event: Element) {
        self._subject.onNext(event)
    }

    /// Current value of behavior subject
    var value: Element {
        // this try! is ok because subject can't error out or be disposed
        return try! self._subject.value()
    }

    /// Initializes behavior relay with initial value.
    init(value: Element) {
        self._subject = _RXSwift_BehaviorSubject(value: value)
    }

    /// Subscribes observer
    func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        return self._subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    func asObservable() -> _RXSwift_Observable<Element> {
        return self._subject.asObservable()
    }
}
