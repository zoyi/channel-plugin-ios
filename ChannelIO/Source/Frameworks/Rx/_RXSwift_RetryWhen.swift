//
//  RetryWhen.swift
//  RxSwift
//
//  Created by Junior B. on 06/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
     func retryWhen<TriggerObservable: _RXSwift_ObservableType, Error: Swift.Error>(_ notificationHandler: @escaping (_RXSwift_Observable<Error>) -> TriggerObservable)
        -> _RXSwift_Observable<Element> {
        return RetryWhenSequence(sources: _RXPlatform_InfiniteSequence(repeatedValue: self.asObservable()), notificationHandler: notificationHandler)
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
     func retryWhen<TriggerObservable: _RXSwift_ObservableType>(_ notificationHandler: @escaping (_RXSwift_Observable<Swift.Error>) -> TriggerObservable)
        -> _RXSwift_Observable<Element> {
        return RetryWhenSequence(sources: _RXPlatform_InfiniteSequence(repeatedValue: self.asObservable()), notificationHandler: notificationHandler)
    }
}

final private class RetryTriggerSink<Sequence: Swift.Sequence, Observer: _RXSwift_ObserverType, TriggerObservable: _RXSwift_ObservableType, Error>
    : _RXSwift_ObserverType where Sequence.Element: _RXSwift_ObservableType, Sequence.Element.Element == Observer.Element {
    typealias Element = TriggerObservable.Element
    
    typealias Parent = RetryWhenSequenceSinkIter<Sequence, Observer, TriggerObservable, Error>
    
    private let _parent: Parent

    init(parent: Parent) {
        self._parent = parent
    }

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._parent._parent._lastError = nil
            self._parent._parent.schedule(.moveNext)
        case .error(let e):
            self._parent._parent.forwardOn(.error(e))
            self._parent._parent.dispose()
        case .completed:
            self._parent._parent.forwardOn(.completed)
            self._parent._parent.dispose()
        }
    }
}

final private class RetryWhenSequenceSinkIter<Sequence: Swift.Sequence, Observer: _RXSwift_ObserverType, TriggerObservable: _RXSwift_ObservableType, Error>
    : _RXSwift_ObserverType
    , _RXSwift_Disposable where Sequence.Element: _RXSwift_ObservableType, Sequence.Element.Element == Observer.Element {
    typealias Element = Observer.Element 
    typealias Parent = RetryWhenSequenceSink<Sequence, Observer, TriggerObservable, Error>

    fileprivate let _parent: Parent
    private let _errorHandlerSubscription = _RXSwift_SingleAssignmentDisposable()
    private let _subscription: _RXSwift_Disposable

    init(parent: Parent, subscription: _RXSwift_Disposable) {
        self._parent = parent
        self._subscription = subscription
    }

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._parent.forwardOn(event)
        case .error(let error):
            self._parent._lastError = error

            if let failedWith = error as? Error {
                // dispose current subscription
                self._subscription.dispose()

                let errorHandlerSubscription = self._parent._notifier.subscribe(RetryTriggerSink(parent: self))
                self._errorHandlerSubscription.setDisposable(errorHandlerSubscription)
                self._parent._errorSubject.on(.next(failedWith))
            }
            else {
                self._parent.forwardOn(.error(error))
                self._parent.dispose()
            }
        case .completed:
            self._parent.forwardOn(event)
            self._parent.dispose()
        }
    }

    final func dispose() {
        self._subscription.dispose()
        self._errorHandlerSubscription.dispose()
    }
}

final private class RetryWhenSequenceSink<Sequence: Swift.Sequence, Observer: _RXSwift_ObserverType, TriggerObservable: _RXSwift_ObservableType, Error>
    : _RXSwift_TailRecursiveSink<Sequence, Observer> where Sequence.Element: _RXSwift_ObservableType, Sequence.Element.Element == Observer.Element {
    typealias Element = Observer.Element 
    typealias Parent = RetryWhenSequence<Sequence, TriggerObservable, Error>
    
    let _lock = _RXPlatform_RecursiveLock()
    
    private let _parent: Parent
    
    fileprivate var _lastError: Swift.Error?
    fileprivate let _errorSubject = _RXSwift_PublishSubject<Error>()
    private let _handler: _RXSwift_Observable<TriggerObservable.Element>
    fileprivate let _notifier = _RXSwift_PublishSubject<TriggerObservable.Element>()

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        self._handler = parent._notificationHandler(self._errorSubject).asObservable()
        super.init(observer: observer, cancel: cancel)
    }
    
    override func done() {
        if let lastError = self._lastError {
            self.forwardOn(.error(lastError))
            self._lastError = nil
        }
        else {
            self.forwardOn(.completed)
        }

        self.dispose()
    }
    
    override func extract(_ observable: _RXSwift_Observable<Element>) -> SequenceGenerator? {
        // It is important to always return `nil` here because there are sideffects in the `run` method
        // that are dependant on particular `retryWhen` operator so single operator stack can't be reused in this
        // case.
        return nil
    }

    override func subscribeToNext(_ source: _RXSwift_Observable<Element>) -> _RXSwift_Disposable {
        let subscription = _RXSwift_SingleAssignmentDisposable()
        let iter = RetryWhenSequenceSinkIter(parent: self, subscription: subscription)
        subscription.setDisposable(source.subscribe(iter))
        return iter
    }

    override func run(_ sources: SequenceGenerator) -> _RXSwift_Disposable {
        let triggerSubscription = self._handler.subscribe(self._notifier.asObserver())
        let superSubscription = super.run(sources)
        return _RXSwift_Disposables.create(superSubscription, triggerSubscription)
    }
}

final private class RetryWhenSequence<Sequence: Swift.Sequence, TriggerObservable: _RXSwift_ObservableType, Error>: _RXSwift_Producer<Sequence.Element.Element> where Sequence.Element: _RXSwift_ObservableType {
    typealias Element = Sequence.Element.Element
    
    private let _sources: Sequence
    fileprivate let _notificationHandler: (_RXSwift_Observable<Error>) -> TriggerObservable
    
    init(sources: Sequence, notificationHandler: @escaping (_RXSwift_Observable<Error>) -> TriggerObservable) {
        self._sources = sources
        self._notificationHandler = notificationHandler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = RetryWhenSequenceSink<Sequence, Observer, TriggerObservable, Error>(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run((self._sources.makeIterator(), nil))
        return (sink: sink, subscription: subscription)
    }
}
