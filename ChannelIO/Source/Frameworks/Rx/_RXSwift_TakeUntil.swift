//
//  TakeUntil.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Returns the elements from the source observable sequence until the other observable sequence produces an element.

     - seealso: [takeUntil operator on reactivex.io](http://reactivex.io/documentation/operators/takeuntil.html)

     - parameter other: Observable sequence that terminates propagation of elements of the source sequence.
     - returns: An observable sequence containing the elements of the source sequence up to the point the other sequence interrupted further propagation.
     */
    func takeUntil<Source: _RXSwift_ObservableType>(_ other: Source)
        -> _RXSwift_Observable<Element> {
        return TakeUntil(source: self.asObservable(), other: other.asObservable())
    }

    /**
     Returns elements from an observable sequence until the specified condition is true.

     - seealso: [takeUntil operator on reactivex.io](http://reactivex.io/documentation/operators/takeuntil.html)

     - parameter behavior: Whether or not to include the last element matching the predicate.
     - parameter predicate: A function to test each element for a condition.
     - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test passes.
     */
    func takeUntil(_ behavior: TakeUntilBehavior,
                          predicate: @escaping (Element) throws -> Bool)
        -> _RXSwift_Observable<Element> {
        return TakeUntilPredicate(source: self.asObservable(),
                                  behavior: behavior,
                                  predicate: predicate)
    }
}

/// Behaviors for the `takeUntil(_ behavior:predicate:)` operator.
enum TakeUntilBehavior {
    /// Include the last element matching the predicate.
    case inclusive

    /// Exclude the last element matching the predicate.
    case exclusive
}

// MARK: - TakeUntil Observable
final private class TakeUntilSinkOther<Other, Observer: _RXSwift_ObserverType>
    : _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias Parent = TakeUntilSink<Other, Observer>
    typealias Element = Other
    
    private let _parent: Parent

    var _lock: _RXPlatform_RecursiveLock {
        return self._parent._lock
    }
    
    fileprivate let _subscription = _RXSwift_SingleAssignmentDisposable()
    
    init(parent: Parent) {
        self._parent = parent
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._parent.forwardOn(.completed)
            self._parent.dispose()
        case .error(let e):
            self._parent.forwardOn(.error(e))
            self._parent.dispose()
        case .completed:
            self._subscription.dispose()
        }
    }
    
#if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
#endif
}

final private class TakeUntilSink<Other, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_LockOwnerType
    , _RXSwift_ObserverType
    , _RXSwift_SynchronizedOnType {
    typealias Element = Observer.Element 
    typealias Parent = TakeUntil<Element, Other>
    
    private let _parent: Parent
 
    let _lock = _RXPlatform_RecursiveLock()
    
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
    func run() -> _RXSwift_Disposable {
        let otherObserver = TakeUntilSinkOther(parent: self)
        let otherSubscription = self._parent._other.subscribe(otherObserver)
        otherObserver._subscription.setDisposable(otherSubscription)
        let sourceSubscription = self._parent._source.subscribe(self)
        
        return _RXSwift_Disposables.create(sourceSubscription, otherObserver._subscription)
    }
}

final private class TakeUntil<Element, Other>: _RXSwift_Producer<Element> {
    
    fileprivate let _source: _RXSwift_Observable<Element>
    fileprivate let _other: _RXSwift_Observable<Other>
    
    init(source: _RXSwift_Observable<Element>, other: _RXSwift_Observable<Other>) {
        self._source = source
        self._other = other
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = TakeUntilSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

// MARK: - TakeUntil Predicate
final private class TakeUntilPredicateSink<Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = TakeUntilPredicate<Element>

    private let _parent: Parent
    private var _running = true

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            if !self._running {
                return
            }

            do {
                self._running = try !self._parent._predicate(value)
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
                return
            }

            if self._running {
                self.forwardOn(.next(value))
            } else {
                if self._parent._behavior == .inclusive {
                    self.forwardOn(.next(value))
                }

                self.forwardOn(.completed)
                self.dispose()
            }
        case .error, .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }

}

final private class TakeUntilPredicate<Element>: _RXSwift_Producer<Element> {
    typealias Predicate = (Element) throws -> Bool

    private let _source: _RXSwift_Observable<Element>
    fileprivate let _predicate: Predicate
    fileprivate let _behavior: TakeUntilBehavior

    init(source: _RXSwift_Observable<Element>,
         behavior: TakeUntilBehavior,
         predicate: @escaping Predicate) {
        self._source = source
        self._behavior = behavior
        self._predicate = predicate
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = TakeUntilPredicateSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
