//
//  GroupedObservable.swift
//  RxSwift
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an observable sequence of elements that have a common key.
struct GroupedObservable<Key, Element> : _RXSwift_ObservableType {
    /// Gets the common key.
    let key: Key

    private let source: _RXSwift_Observable<Element>

    /// Initializes grouped observable sequence with key and source observable sequence.
    ///
    /// - parameter key: Grouped observable sequence key
    /// - parameter source: Observable sequence that represents sequence of elements for the key
    /// - returns: Grouped observable sequence of elements for the specific key
    init(key: Key, source: _RXSwift_Observable<Element>) {
        self.key = key
        self.source = source
    }

    /// Subscribes `observer` to receive events for this sequence.
    func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        return self.source.subscribe(observer)
    }

    /// Converts `self` to `Observable` sequence. 
    func asObservable() -> _RXSwift_Observable<Element> {
        return self.source
    }
}
