//
//  Create.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    // MARK: create

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    static func create(_ subscribe: @escaping (_RXSwift_AnyObserver<Element>) -> _RXSwift_Disposable) -> _RXSwift_Observable<Element> {
        return AnonymousObservable(subscribe)
    }
}

final private class AnonymousObservableSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = AnonymousObservable<Element>

    // state
    private let _isStopped = _RXPlatform_AtomicInt(0)

    #if DEBUG
        private let _synchronizationTracker = _RXSwift_SynchronizationTracker()
    #endif

    override init(observer: Observer, cancel: _RXSwift_Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: _RXSwift_Event<Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        switch event {
        case .next:
            if load(self._isStopped) == 1 {
                return
            }
            self.forwardOn(event)
        case .error, .completed:
            if fetchOr(self._isStopped, 1) == 0 {
                self.forwardOn(event)
                self.dispose()
            }
        }
    }

    func run(_ parent: Parent) -> _RXSwift_Disposable {
        return parent._subscribeHandler(_RXSwift_AnyObserver(self))
    }
}

final private class AnonymousObservable<Element>: _RXSwift_Producer<Element> {
    typealias SubscribeHandler = (_RXSwift_AnyObserver<Element>) -> _RXSwift_Disposable

    let _subscribeHandler: SubscribeHandler

    init(_ subscribeHandler: @escaping SubscribeHandler) {
        self._subscribeHandler = subscribeHandler
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
}
