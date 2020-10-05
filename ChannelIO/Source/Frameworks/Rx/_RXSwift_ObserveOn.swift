//
//  ObserveOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http://reactivex.io/documentation/operators/observeon.html)

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
     func observeOn(_ scheduler: _RXSwift_ImmediateSchedulerType)
        -> _RXSwift_Observable<Element> {
            if let scheduler = scheduler as? _RXSwift_SerialDispatchQueueScheduler {
                return ObserveOnSerialDispatchQueue(source: self.asObservable(), scheduler: scheduler)
            }
            else {
                return ObserveOn(source: self.asObservable(), scheduler: scheduler)
            }
    }
}

final private class ObserveOn<Element>: _RXSwift_Producer<Element> {
    let scheduler: _RXSwift_ImmediateSchedulerType
    let source: _RXSwift_Observable<Element>

    init(source: _RXSwift_Observable<Element>, scheduler: _RXSwift_ImmediateSchedulerType) {
        self.scheduler = scheduler
        self.source = source

#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = ObserveOnSink(scheduler: self.scheduler, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }

#if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
#endif
}

enum ObserveOnState : Int32 {
    // pump is not running
    case stopped = 0
    // pump is running
    case running = 1
}

final private class ObserveOnSink<Observer: _RXSwift_ObserverType>: _RXSwift_ObserverBase<Observer.Element> {
    typealias Element = Observer.Element 

    let _scheduler: _RXSwift_ImmediateSchedulerType

    var _lock = _RXSwift_SpinLock()
    let _observer: Observer

    // state
    var _state = ObserveOnState.stopped
    var _queue = _RXSwift_Queue<_RXSwift_Event<Element>>(capacity: 10)

    let _scheduleDisposable = _RXSwift_SerialDisposable()
    let _cancel: _RXSwift_Cancelable

    init(scheduler: _RXSwift_ImmediateSchedulerType, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._scheduler = scheduler
        self._observer = observer
        self._cancel = cancel
    }

    override func onCore(_ event: _RXSwift_Event<Element>) {
        let shouldStart = self._lock.calculateLocked { () -> Bool in
            self._queue.enqueue(event)

            switch self._state {
            case .stopped:
                self._state = .running
                return true
            case .running:
                return false
            }
        }

        if shouldStart {
            self._scheduleDisposable.disposable = self._scheduler.scheduleRecursive((), action: self.run)
        }
    }

    func run(_ state: (), _ recurse: (()) -> Void) {
        let (nextEvent, observer) = self._lock.calculateLocked { () -> (_RXSwift_Event<Element>?, Observer) in
            if !self._queue.isEmpty {
                return (self._queue.dequeue(), self._observer)
            }
            else {
                self._state = .stopped
                return (nil, self._observer)
            }
        }

        if let nextEvent = nextEvent, !self._cancel.isDisposed {
            observer.on(nextEvent)
            if nextEvent.isStopEvent {
                self.dispose()
            }
        }
        else {
            return
        }

        let shouldContinue = self._shouldContinue_synchronized()

        if shouldContinue {
            recurse(())
        }
    }

    func _shouldContinue_synchronized() -> Bool {
        self._lock.lock(); defer { self._lock.unlock() } // {
            if !self._queue.isEmpty {
                return true
            }
            else {
                self._state = .stopped
                return false
            }
        // }
    }

    override func dispose() {
        super.dispose()

        self._cancel.dispose()
        self._scheduleDisposable.dispose()
    }
}

#if TRACE_RESOURCES
    private let _numberOfSerialDispatchQueueObservables = AtomicInt(0)
    extension Resources {
        /**
         Counts number of `SerialDispatchQueueObservables`.

         Purposed for unit tests.
         */
         static var numberOfSerialDispatchQueueObservables: Int32 {
            return load(_numberOfSerialDispatchQueueObservables)
        }
    }
#endif

final private class ObserveOnSerialDispatchQueueSink<Observer: _RXSwift_ObserverType>: _RXSwift_ObserverBase<Observer.Element> {
    let scheduler: _RXSwift_SerialDispatchQueueScheduler
    let observer: Observer

    let cancel: _RXSwift_Cancelable

    var cachedScheduleLambda: (((sink: ObserveOnSerialDispatchQueueSink<Observer>, event: _RXSwift_Event<Element>)) -> _RXSwift_Disposable)!

    init(scheduler: _RXSwift_SerialDispatchQueueScheduler, observer: Observer, cancel: _RXSwift_Cancelable) {
        self.scheduler = scheduler
        self.observer = observer
        self.cancel = cancel
        super.init()

        self.cachedScheduleLambda = { pair in
            guard !cancel.isDisposed else { return _RXSwift_Disposables.create() }

            pair.sink.observer.on(pair.event)

            if pair.event.isStopEvent {
                pair.sink.dispose()
            }

            return _RXSwift_Disposables.create()
        }
    }

    override func onCore(_ event: _RXSwift_Event<Element>) {
        _ = self.scheduler.schedule((self, event), action: self.cachedScheduleLambda!)
    }

    override func dispose() {
        super.dispose()

        self.cancel.dispose()
    }
}

final private class ObserveOnSerialDispatchQueue<Element>: _RXSwift_Producer<Element> {
    let scheduler: _RXSwift_SerialDispatchQueueScheduler
    let source: _RXSwift_Observable<Element>

    init(source: _RXSwift_Observable<Element>, scheduler: _RXSwift_SerialDispatchQueueScheduler) {
        self.scheduler = scheduler
        self.source = source

        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
            _ = increment(_numberOfSerialDispatchQueueObservables)
        #endif
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = ObserveOnSerialDispatchQueueSink(scheduler: self.scheduler, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
        _ = decrement(_numberOfSerialDispatchQueueObservables)
    }
    #endif
}
