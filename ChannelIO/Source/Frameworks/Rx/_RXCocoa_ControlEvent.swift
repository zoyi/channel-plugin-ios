//
//  ControlEvent.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

/// A protocol that extends `ControlEvent`.
protocol _RXCocoa_ControlEventType : _RXSwift_ObservableType {

    /// - returns: `ControlEvent` interface
    func asControlEvent() -> _RXCocoa_ControlEvent<Element>
}

/**
    A trait for `Observable`/`ObservableType` that represents an event on a UI element.

    Properties:

    - it doesn’t send any initial value on subscription,
    - it `Complete`s the sequence when the control deallocates,
    - it never errors out
    - it delivers events on `MainScheduler.instance`.

    **The implementation of `ControlEvent` will ensure that sequence of events is being subscribed on main scheduler
     (`subscribeOn(ConcurrentMainScheduler.instance)` behavior).**

    **It is the implementor’s responsibility to make sure that all other properties enumerated above are satisfied.**

    **If they aren’t, using this trait will communicate wrong properties, and could potentially break someone’s code.**

    **If the `events` observable sequence passed into the initializer doesn’t satisfy all enumerated
     properties, don’t use this trait.**
*/
struct _RXCocoa_ControlEvent<PropertyType> : _RXCocoa_ControlEventType {
    typealias Element = PropertyType

    let _events: _RXSwift_Observable<PropertyType>

    /// Initializes control event with a observable sequence that represents events.
    ///
    /// - parameter events: Observable sequence that represents events.
    /// - returns: Control event created with a observable sequence of events.
    init<Ev: _RXSwift_ObservableType>(events: Ev) where Ev.Element == Element {
        self._events = events.subscribeOn(_RXSwift_ConcurrentMainScheduler.instance)
    }

    /// Subscribes an observer to control events.
    ///
    /// - parameter observer: Observer to subscribe to events.
    /// - returns: Disposable object that can be used to unsubscribe the observer from receiving control events.
    func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        return self._events.subscribe(observer)
    }

    /// - returns: `Observable` interface.
    func asObservable() -> _RXSwift_Observable<Element> {
        return self._events
    }

    /// - returns: `ControlEvent` interface.
    func asControlEvent() -> _RXCocoa_ControlEvent<Element> {
        return self
    }
}
