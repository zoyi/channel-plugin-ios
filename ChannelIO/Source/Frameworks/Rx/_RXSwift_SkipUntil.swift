//
//  SkipUntil.swift
//  RxSwift
//
//  Created by Yury Korolev on 10/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Returns the elements from the source observable sequence that are emitted after the other observable sequence produces an element.

     - seealso: [skipUntil operator on reactivex.io](http://reactivex.io/documentation/operators/skipuntil.html)

     - parameter other: Observable sequence that starts propagation of elements of the source sequence.
     - returns: An observable sequence containing the elements of the source sequence that are emitted after the other sequence emits an item.
     */
     func skipUntil<Source: _RXSwift_ObservableType>(_ other: Source)
        -> _RXSwift_Observable<Element> {
        return SkipUntil(source: self.asObservable(), other: other.asObservable())
    }
}

final private class SkipUntilSinkOther<Other, Observer: _RXSwift_ObserverType>
    : _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias Parent = SkipUntilSink<Other, Observer>
    typealias Element = Other
    
    private let _parent: Parent

    var _lock: _RXPlatform_RecursiveLock {
        return self._parent._lock
    }
    
    let _subscription = _RXSwift_SingleAssignmentDisposable()

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
            self._parent._forwardElements = true
            self._subscription.dispose()
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


final private class SkipUntilSink<Other, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias Element = Observer.Element
    typealias Parent = SkipUntil<Element, Other>
    
    let _lock = _RXPlatform_RecursiveLock()
    private let _parent: Parent
    fileprivate var _forwardElements = false
    
    private let _sourceSubscription = _RXSwift_SingleAssignmentDisposable()

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
            if self._forwardElements {
                self.forwardOn(event)
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            if self._forwardElements {
                self.forwardOn(event)
            }
            self.dispose()
        }
    }
    
    func run() -> _RXSwift_Disposable {
        let sourceSubscription = self._parent._source.subscribe(self)
        let otherObserver = SkipUntilSinkOther(parent: self)
        let otherSubscription = self._parent._other.subscribe(otherObserver)
        self._sourceSubscription.setDisposable(sourceSubscription)
        otherObserver._subscription.setDisposable(otherSubscription)
        
        return _RXSwift_Disposables.create(_sourceSubscription, otherObserver._subscription)
    }
}

final private class SkipUntil<Element, Other>: _RXSwift_Producer<Element> {
    
    fileprivate let _source: _RXSwift_Observable<Element>
    fileprivate let _other: _RXSwift_Observable<Other>
    
    init(source: _RXSwift_Observable<Element>, other: _RXSwift_Observable<Other>) {
        self._source = source
        self._other = other
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = SkipUntilSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
