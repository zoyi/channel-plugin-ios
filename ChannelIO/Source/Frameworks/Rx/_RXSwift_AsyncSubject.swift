//
//  AsyncSubject.swift
//  RxSwift
//
//  Created by Victor Galán on 07/01/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

/// An AsyncSubject emits the last value (and only the last value) emitted by the source Observable,
/// and only after that source Observable completes.
///
/// (If the source Observable does not emit any values, the AsyncSubject also completes without emitting any values.)
 final class _RXSwift_AsyncSubject<Element>
    : _RXSwift_Observable<Element>
    , _RXSwift_SubjectType
    , _RXSwift_ObserverType
    , _RXSwift_SynchronizedUnsubscribeType {
     typealias SubjectObserverType = _RXSwift_AsyncSubject<Element>

    typealias Observers = _RXSwift_AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    /// Indicates whether the subject has any observers
     var hasObservers: Bool {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._observers.count > 0
    }

    let _lock = _RXPlatform_RecursiveLock()

    // state
    private var _observers = Observers()
    private var _isStopped = false
    private var _stoppedEvent = nil as _RXSwift_Event<Element>? {
        didSet {
            self._isStopped = self._stoppedEvent != nil
        }
    }
    private var _lastElement: Element?

    #if DEBUG
        private let _synchronizationTracker = _RXSwift_SynchronizationTracker()
    #endif


    /// Creates a subject.
     override init() {
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
        super.init()
    }

    /// Notifies all subscribed observers about next event.
    ///
    /// - parameter event: Event to send to the observers.
     func on(_ event: _RXSwift_Event<Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        let (observers, event) = self._synchronized_on(event)
        switch event {
        case .next:
            dispatch(observers, event)
            dispatch(observers, .completed)
        case .completed:
            dispatch(observers, event)
        case .error:
            dispatch(observers, event)
        }
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) -> (Observers, _RXSwift_Event<Element>) {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isStopped {
            return (Observers(), .completed)
        }

        switch event {
        case .next(let element):
            self._lastElement = element
            return (Observers(), .completed)
        case .error:
            self._stoppedEvent = event

            let observers = self._observers
            self._observers.removeAll()

            return (observers, event)
        case .completed:

            let observers = self._observers
            self._observers.removeAll()

            if let lastElement = self._lastElement {
                self._stoppedEvent = .next(lastElement)
                return (observers, .next(lastElement))
            }
            else {
                self._stoppedEvent = event
                return (observers, .completed)
            }
        }
    }

    /// Subscribes an observer to the subject.
    ///
    /// - parameter observer: Observer to subscribe to the subject.
    /// - returns: Disposable object that can be used to unsubscribe the observer from the subject.
     override func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._synchronized_subscribe(observer)
    }

    func _synchronized_subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        if let stoppedEvent = self._stoppedEvent {
            switch stoppedEvent {
            case .next:
                observer.on(stoppedEvent)
                observer.on(.completed)
            case .completed:
                observer.on(stoppedEvent)
            case .error:
                observer.on(stoppedEvent)
            }
            return _RXSwift_Disposables.create()
        }

        let key = self._observers.insert(observer.on)

        return _RXSwift_SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        self._lock.lock(); defer { self._lock.unlock() }
        self._synchronized_unsubscribe(disposeKey)
    }
    
    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        _ = self._observers.removeKey(disposeKey)
    }
    
    /// Returns observer interface for subject.
     func asObserver() -> _RXSwift_AsyncSubject<Element> {
        return self
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}

