//
//  AnyObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// A type-erased `ObserverType`.
///
/// Forwards operations to an arbitrary underlying observer with the same `Element` type, hiding the specifics of the underlying observer type.
 struct _RXSwift_AnyObserver<Element> : _RXSwift_ObserverType {
    /// Anonymous event handler type.
     typealias EventHandler = (_RXSwift_Event<Element>) -> Void

    private let observer: EventHandler

    /// Construct an instance whose `on(event)` calls `eventHandler(event)`
    ///
    /// - parameter eventHandler: Event handler that observes sequences events.
     init(eventHandler: @escaping EventHandler) {
        self.observer = eventHandler
    }
    
    /// Construct an instance whose `on(event)` calls `observer.on(event)`
    ///
    /// - parameter observer: Observer that receives sequence events.
     init<Observer: _RXSwift_ObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }
    
    /// Send `event` to this observer.
    ///
    /// - parameter event: Event instance.
     func on(_ event: _RXSwift_Event<Element>) {
        return self.observer(event)
    }

    /// Erases type of observer and returns canonical observer.
    ///
    /// - returns: type erased observer.
     func asObserver() -> _RXSwift_AnyObserver<Element> {
        return self
    }
}

extension _RXSwift_AnyObserver {
    /// Collection of `AnyObserver`s
    typealias s = _RXPlatform_Bag<(_RXSwift_Event<Element>) -> Void>
}

extension _RXSwift_ObserverType {
    /// Erases type of observer and returns canonical observer.
    ///
    /// - returns: type erased observer.
     func asObserver() -> _RXSwift_AnyObserver<Element> {
        return _RXSwift_AnyObserver(self)
    }

    /// Transforms observer of type R to type E using custom transform method.
    /// Each event sent to result observer is transformed and sent to `self`.
    ///
    /// - returns: observer that transforms events.
     func mapObserver<Result>(_ transform: @escaping (Result) throws -> Element) -> _RXSwift_AnyObserver<Result> {
        return _RXSwift_AnyObserver { e in
            self.on(e.map(transform))
        }
    }
}
