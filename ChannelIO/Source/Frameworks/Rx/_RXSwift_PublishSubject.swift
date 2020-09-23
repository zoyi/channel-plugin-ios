//
//  PublishSubject.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an object that is both an observable sequence as well as an observer.
///
/// Each notification is broadcasted to all subscribed observers.
 final class _RXSwift_PublishSubject<Element>
    : _RXSwift_Observable<Element>
    , _RXSwift_SubjectType
    , _RXSwift_Cancelable
    , _RXSwift_ObserverType
    , _RXSwift_SynchronizedUnsubscribeType {
     typealias SubjectObserverType = _RXSwift_PublishSubject<Element>

    typealias Observers = _RXSwift_AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType
    
    /// Indicates whether the subject has any observers
     var hasObservers: Bool {
        self._lock.lock()
        let count = self._observers.count > 0
        self._lock.unlock()
        return count
    }
    
    private let _lock = _RXPlatform_RecursiveLock()
    
    // state
    private var _isDisposed = false
    private var _observers = Observers()
    private var _stopped = false
    private var _stoppedEvent = nil as _RXSwift_Event<Element>?

    #if DEBUG
        private let _synchronizationTracker = _RXSwift_SynchronizationTracker()
    #endif

    /// Indicates whether the subject has been isDisposed.
     var isDisposed: Bool {
        return self._isDisposed
    }
    
    /// Creates a subject.
     override init() {
        super.init()
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }
    
    /// Notifies all subscribed observers about next event.
    ///
    /// - parameter event: Event to send to the observers.
     func on(_ event: _RXSwift_Event<Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        dispatch(self._synchronized_on(event), event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) -> Observers {
        self._lock.lock(); defer { self._lock.unlock() }
        switch event {
        case .next:
            if self._isDisposed || self._stopped {
                return Observers()
            }
            
            return self._observers
        case .completed, .error:
            if self._stoppedEvent == nil {
                self._stoppedEvent = event
                self._stopped = true
                let observers = self._observers
                self._observers.removeAll()
                return observers
            }

            return Observers()
        }
    }
    
    /**
    Subscribes an observer to the subject.
    
    - parameter observer: Observer to subscribe to the subject.
    - returns: Disposable object that can be used to unsubscribe the observer from the subject.
    */
     override func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        self._lock.lock()
        let subscription = self._synchronized_subscribe(observer)
        self._lock.unlock()
        return subscription
    }

    func _synchronized_subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        if let stoppedEvent = self._stoppedEvent {
            observer.on(stoppedEvent)
            return _RXSwift_Disposables.create()
        }
        
        if self._isDisposed {
            observer.on(.error(_RXSwift_RxError.disposed(object: self)))
            return _RXSwift_Disposables.create()
        }
        
        let key = self._observers.insert(observer.on)
        return _RXSwift_SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        self._lock.lock()
        self._synchronized_unsubscribe(disposeKey)
        self._lock.unlock()
    }

    func _synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        _ = self._observers.removeKey(disposeKey)
    }
    
    /// Returns observer interface for subject.
     func asObserver() -> _RXSwift_PublishSubject<Element> {
        return self
    }
    
    /// Unsubscribe all observers and release resources.
     func dispose() {
        self._lock.lock()
        self._synchronized_dispose()
        self._lock.unlock()
    }

    final func _synchronized_dispose() {
        self._isDisposed = true
        self._observers.removeAll()
        self._stoppedEvent = nil
    }

    #if TRACE_RESOURCES
        deinit {
            _ = Resources.decrementTotal()
        }
    #endif
}
