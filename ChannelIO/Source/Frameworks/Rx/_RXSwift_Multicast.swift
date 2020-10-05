//
//  Multicast.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
 Represents an observable wrapper that can be connected and disconnected from its underlying observable sequence.
 */
class _RXSwift_ConnectableObservable<Element>
    : _RXSwift_Observable<Element>
    , _RXSwift_ConnectableObservableType {

    /**
     Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.

     - returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
     */
    func connect() -> _RXSwift_Disposable {
        _RXSwift_rxAbstractMethod()
    }
}

extension _RXSwift_ObservableType {

    /**
    Multicasts the source sequence notifications through an instantiated subject into all uses of the sequence within a selector function.

    Each subscription to the resulting sequence causes a separate multicast invocation, exposing the sequence resulting from the selector function's invocation.

    For specializations with fixed subject types, see `publish` and `replay`.

    - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

    - parameter subjectSelector: Factory function to create an intermediate subject through which the source sequence's elements will be multicast to the selector function.
    - parameter selector: Selector function which can use the multicasted source sequence subject to the policies enforced by the created subject.
    - returns: An observable sequence that contains the elements of a sequence produced by multicasting the source sequence within a selector function.
    */
    func multicast<Subject: _RXSwift_SubjectType, Result>(_ subjectSelector: @escaping () throws -> Subject, selector: @escaping (_RXSwift_Observable<Subject.Element>) throws -> _RXSwift_Observable<Result>)
        -> _RXSwift_Observable<Result> where Subject.Observer.Element == Element {
        return Multicast(
            source: self.asObservable(),
            subjectSelector: subjectSelector,
            selector: selector
        )
    }
}

extension _RXSwift_ObservableType {

    /**
    Returns a connectable observable sequence that shares a single subscription to the underlying sequence.

    This operator is a specialization of `multicast` using a `PublishSubject`.

    - seealso: [publish operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

    - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
    */
    func publish() -> _RXSwift_ConnectableObservable<Element> {
        return self.multicast { _RXSwift_PublishSubject() }
    }
}

extension _RXSwift_ObservableType {

    /**
     Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying bufferSize elements.

     This operator is a specialization of `multicast` using a `ReplaySubject`.

     - seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - parameter bufferSize: Maximum element count of the replay buffer.
     - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
     */
    func replay(_ bufferSize: Int)
        -> _RXSwift_ConnectableObservable<Element> {
        return self.multicast { _RXSwift_ReplaySubject.create(bufferSize: bufferSize) }
    }

    /**
     Returns a connectable observable sequence that shares a single subscription to the underlying sequence replaying all elements.

     This operator is a specialization of `multicast` using a `ReplaySubject`.

     - seealso: [replay operator on reactivex.io](http://reactivex.io/documentation/operators/replay.html)

     - returns: A connectable observable sequence that shares a single subscription to the underlying sequence.
     */
    func replayAll()
        -> _RXSwift_ConnectableObservable<Element> {
        return self.multicast { _RXSwift_ReplaySubject.createUnbounded() }
    }
}

extension _RXSwift_ConnectableObservableType {

    /**
    Returns an observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.

    - seealso: [refCount operator on reactivex.io](http://reactivex.io/documentation/operators/refcount.html)

    - returns: An observable sequence that stays connected to the source as long as there is at least one subscription to the observable sequence.
    */
    func refCount() -> _RXSwift_Observable<Element> {
        return RefCount(source: self)
    }
}

extension _RXSwift_ObservableType {

    /**
     Multicasts the source sequence notifications through the specified subject to the resulting connectable observable.

     Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.

     For specializations with fixed subject types, see `publish` and `replay`.

     - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

     - parameter subject: Subject to push source elements into.
     - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
     */
    func multicast<Subject: _RXSwift_SubjectType>(_ subject: Subject)
        -> _RXSwift_ConnectableObservable<Subject.Element> where Subject.Observer.Element == Element {
        return ConnectableObservableAdapter(source: self.asObservable(), makeSubject: { subject })
    }

    /**
     Multicasts the source sequence notifications through an instantiated subject to the resulting connectable observable.

     Upon connection of the connectable observable, the subject is subscribed to the source exactly one, and messages are forwarded to the observers registered with the connectable observable.

     Subject is cleared on connection disposal or in case source sequence produces terminal event.

     - seealso: [multicast operator on reactivex.io](http://reactivex.io/documentation/operators/publish.html)

     - parameter makeSubject: Factory function used to instantiate a subject for each connection.
     - returns: A connectable observable sequence that upon connection causes the source sequence to push results into the specified subject.
     */
    func multicast<Subject: _RXSwift_SubjectType>(makeSubject: @escaping () -> Subject)
        -> _RXSwift_ConnectableObservable<Subject.Element> where Subject.Observer.Element == Element {
        return ConnectableObservableAdapter(source: self.asObservable(), makeSubject: makeSubject)
    }
}

final private class Connection<Subject: _RXSwift_SubjectType>: _RXSwift_ObserverType, _RXSwift_Disposable {
    typealias Element = Subject.Observer.Element

    private var _lock: _RXPlatform_RecursiveLock
    // state
    private var _parent: ConnectableObservableAdapter<Subject>?
    private var _subscription : _RXSwift_Disposable?
    private var _subjectObserver: Subject.Observer

    private let _disposed = _RXPlatform_AtomicInt(0)

    init(parent: ConnectableObservableAdapter<Subject>, subjectObserver: Subject.Observer, lock: _RXPlatform_RecursiveLock, subscription: _RXSwift_Disposable) {
        self._parent = parent
        self._subscription = subscription
        self._lock = lock
        self._subjectObserver = subjectObserver
    }

    func on(_ event: _RXSwift_Event<Subject.Observer.Element>) {
        if isFlagSet(self._disposed, 1) {
            return
        }
        if event.isStopEvent {
            self.dispose()
        }
        self._subjectObserver.on(event)
    }

    func dispose() {
        _lock.lock(); defer { _lock.unlock() } // {
        fetchOr(self._disposed, 1)
        guard let parent = _parent else {
            return
        }

        if parent._connection === self {
            parent._connection = nil
            parent._subject = nil
        }
        self._parent = nil

        self._subscription?.dispose()
        self._subscription = nil
        // }
    }
}

final private class ConnectableObservableAdapter<Subject: _RXSwift_SubjectType>
    : _RXSwift_ConnectableObservable<Subject.Element> {
    typealias ConnectionType = Connection<Subject>

    private let _source: _RXSwift_Observable<Subject.Observer.Element>
    private let _makeSubject: () -> Subject

    fileprivate let _lock = _RXPlatform_RecursiveLock()
    fileprivate var _subject: Subject?

    // state
    fileprivate var _connection: ConnectionType?

    init(source: _RXSwift_Observable<Subject.Observer.Element>, makeSubject: @escaping () -> Subject) {
        self._source = source
        self._makeSubject = makeSubject
        self._subject = nil
        self._connection = nil
    }

    override func connect() -> _RXSwift_Disposable {
        return self._lock.calculateLocked {
            if let connection = self._connection {
                return connection
            }

            let singleAssignmentDisposable = _RXSwift_SingleAssignmentDisposable()
            let connection = Connection(parent: self, subjectObserver: self.lazySubject.asObserver(), lock: self._lock, subscription: singleAssignmentDisposable)
            self._connection = connection
            let subscription = self._source.subscribe(connection)
            singleAssignmentDisposable.setDisposable(subscription)
            return connection
        }
    }

    private var lazySubject: Subject {
        if let subject = self._subject {
            return subject
        }

        let subject = self._makeSubject()
        self._subject = subject
        return subject
    }

    override func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Subject.Element {
        return self.lazySubject.subscribe(observer)
    }
}

final private class RefCountSink<ConnectableSource: _RXSwift_ConnectableObservableType, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType where ConnectableSource.Element == Observer.Element {
    typealias Element = Observer.Element 
    typealias Parent = RefCount<ConnectableSource>

    private let _parent: Parent

    private var _connectionIdSnapshot: Int64 = -1

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> _RXSwift_Disposable {
        let subscription = self._parent._source.subscribe(self)
        self._parent._lock.lock(); defer { self._parent._lock.unlock() } // {

        self._connectionIdSnapshot = self._parent._connectionId

        if self.disposed {
            return _RXSwift_Disposables.create()
        }

        if self._parent._count == 0 {
            self._parent._count = 1
            self._parent._connectableSubscription = self._parent._source.connect()
        }
        else {
            self._parent._count += 1
        }
        // }

        return _RXSwift_Disposables.create {
            subscription.dispose()
            self._parent._lock.lock(); defer { self._parent._lock.unlock() } // {
            if self._parent._connectionId != self._connectionIdSnapshot {
                return
            }
            if self._parent._count == 1 {
                self._parent._count = 0
                guard let connectableSubscription = self._parent._connectableSubscription else {
                    return
                }

                connectableSubscription.dispose()
                self._parent._connectableSubscription = nil
            }
            else if self._parent._count > 1 {
                self._parent._count -= 1
            }
            else {
                _RXSwift_rxFatalError("Something went wrong with RefCount disposing mechanism")
            }
            // }
        }
    }

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .error, .completed:
            self._parent._lock.lock() // {
                if self._parent._connectionId == self._connectionIdSnapshot {
                    let connection = self._parent._connectableSubscription
                    defer { connection?.dispose() }
                    self._parent._count = 0
                    self._parent._connectionId = self._parent._connectionId &+ 1
                    self._parent._connectableSubscription = nil
                }
            // }
            self._parent._lock.unlock()
            self.forwardOn(event)
            self.dispose()
        }
    }
}

final private class RefCount<ConnectableSource: _RXSwift_ConnectableObservableType>: _RXSwift_Producer<ConnectableSource.Element> {
    fileprivate let _lock = _RXPlatform_RecursiveLock()

    // state
    fileprivate var _count = 0
    fileprivate var _connectionId: Int64 = 0
    fileprivate var _connectableSubscription = nil as _RXSwift_Disposable?

    fileprivate let _source: ConnectableSource

    init(source: ConnectableSource) {
        self._source = source
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable)
             where Observer.Element == ConnectableSource.Element {
        let sink = RefCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class MulticastSink<Subject: _RXSwift_SubjectType, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias ResultType = Element
    typealias MutlicastType = Multicast<Subject, Observer.Element>

    private let _parent: MutlicastType

    init(parent: MutlicastType, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> _RXSwift_Disposable {
        do {
            let subject = try self._parent._subjectSelector()
            let connectable = ConnectableObservableAdapter(source: self._parent._source, makeSubject: { subject })

            let observable = try self._parent._selector(connectable)

            let subscription = observable.subscribe(self)
            let connection = connectable.connect()

            return _RXSwift_Disposables.create(subscription, connection)
        }
        catch let e {
            self.forwardOn(.error(e))
            self.dispose()
            return _RXSwift_Disposables.create()
        }
    }

    func on(_ event: _RXSwift_Event<ResultType>) {
        self.forwardOn(event)
        switch event {
        case .next: break
        case .error, .completed:
            self.dispose()
        }
    }
}

final private class Multicast<Subject: _RXSwift_SubjectType, Result>: _RXSwift_Producer<Result> {
    typealias SubjectSelectorType = () throws -> Subject
    typealias SelectorType = (_RXSwift_Observable<Subject.Element>) throws -> _RXSwift_Observable<Result>

    fileprivate let _source: _RXSwift_Observable<Subject.Observer.Element>
    fileprivate let _subjectSelector: SubjectSelectorType
    fileprivate let _selector: SelectorType

    init(source: _RXSwift_Observable<Subject.Observer.Element>, subjectSelector: @escaping SubjectSelectorType, selector: @escaping SelectorType) {
        self._source = source
        self._subjectSelector = subjectSelector
        self._selector = selector
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Result {
        let sink = MulticastSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
