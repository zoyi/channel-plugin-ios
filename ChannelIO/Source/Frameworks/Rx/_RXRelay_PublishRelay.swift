//
//  PublishRelay.swift
//  RxRelay
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

/// PublishRelay is a wrapper for `PublishSubject`.
///
/// Unlike `PublishSubject` it can't terminate with error or completed.
final class _RXRelay_PublishRelay<Element>: _RXSwift_ObservableType {
    private let _subject: _RXSwift_PublishSubject<Element>
    
    // Accepts `event` and emits it to subscribers
    func accept(_ event: Element) {
        self._subject.onNext(event)
    }
    
    /// Initializes with internal empty subject.
    init() {
        self._subject = _RXSwift_PublishSubject()
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
