//
//  Delay.swift
//  RxSwift
//
//  Created by tarunon on 2016/02/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date

extension _RXSwift_ObservableType {

    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    func delay(_ dueTime: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<Element> {
            return Delay(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

final private class DelaySink<Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Source = _RXSwift_Observable<Element>
    typealias DisposeKey = _RXPlatform_Bag<_RXSwift_Disposable>.KeyType
    
    private let _lock = _RXPlatform_RecursiveLock()

    private let _dueTime: _RXSwift_RxTimeInterval
    private let _scheduler: _RXSwift_SchedulerType
    
    private let _sourceSubscription = _RXSwift_SingleAssignmentDisposable()
    private let _cancelable = _RXSwift_SerialDisposable()

    // is scheduled some action
    private var _active = false
    // is "run loop" on different scheduler running
    private var _running = false
    private var _errorEvent: _RXSwift_Event<Element>?

    // state
    private var _queue = _RXSwift_Queue<(eventTime: _RXSwift_RxTime, event: _RXSwift_Event<Element>)>(capacity: 0)
    private var _disposed = false
    
    init(observer: Observer, dueTime: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType, cancel: _RXSwift_Cancelable) {
        self._dueTime = dueTime
        self._scheduler = scheduler
        super.init(observer: observer, cancel: cancel)
    }

    // All of these complications in this method are caused by the fact that 
    // error should be propagated immediately. Error can be potentially received on different
    // scheduler so this process needs to be synchronized somehow.
    //
    // Another complication is that scheduler is potentially concurrent so internal queue is used.
    func drainQueue(state: (), scheduler: _RXSwift_AnyRecursiveScheduler<()>) {

        self._lock.lock()    // {
            let hasFailed = self._errorEvent != nil
            if !hasFailed {
                self._running = true
            }
        self._lock.unlock()  // }

        if hasFailed {
            return
        }

        var ranAtLeastOnce = false

        while true {
            self._lock.lock() // {
                let errorEvent = self._errorEvent

                let eventToForwardImmediately = ranAtLeastOnce ? nil : self._queue.dequeue()?.event
                let nextEventToScheduleOriginalTime: Date? = ranAtLeastOnce && !self._queue.isEmpty ? self._queue.peek().eventTime : nil

                if errorEvent == nil {
                    if eventToForwardImmediately != nil {
                    }
                    else if nextEventToScheduleOriginalTime != nil {
                        self._running = false
                    }
                    else {
                        self._running = false
                        self._active = false
                    }
                }
            self._lock.unlock() // {

            if let errorEvent = errorEvent {
                self.forwardOn(errorEvent)
                self.dispose()
                return
            }
            else {
                if let eventToForwardImmediately = eventToForwardImmediately {
                    ranAtLeastOnce = true
                    self.forwardOn(eventToForwardImmediately)
                    if case .completed = eventToForwardImmediately {
                        self.dispose()
                        return
                    }
                }
                else if let nextEventToScheduleOriginalTime = nextEventToScheduleOriginalTime {
                    scheduler.schedule((), dueTime: self._dueTime._RXSwift_reduceWithSpanBetween(earlierDate: nextEventToScheduleOriginalTime, laterDate: self._scheduler.now))
                    return
                }
                else {
                    return
                }
            }
        }
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        if event.isStopEvent {
            self._sourceSubscription.dispose()
        }

        switch event {
        case .error:
            self._lock.lock()    // {
                let shouldSendImmediately = !self._running
                self._queue = _RXSwift_Queue(capacity: 0)
                self._errorEvent = event
            self._lock.unlock()  // }

            if shouldSendImmediately {
                self.forwardOn(event)
                self.dispose()
            }
        default:
            self._lock.lock()    // {
                let shouldSchedule = !self._active
                self._active = true
                self._queue.enqueue((self._scheduler.now, event))
            self._lock.unlock()  // }

            if shouldSchedule {
                self._cancelable.disposable = self._scheduler.scheduleRecursive((), dueTime: self._dueTime, action: self.drainQueue)
            }
        }
    }
    
    func run(source: _RXSwift_Observable<Element>) -> _RXSwift_Disposable {
        self._sourceSubscription.setDisposable(source.subscribe(self))
        return _RXSwift_Disposables.create(_sourceSubscription, _cancelable)
    }
}

final private class Delay<Element>: _RXSwift_Producer<Element> {
    private let _source: _RXSwift_Observable<Element>
    private let _dueTime: _RXSwift_RxTimeInterval
    private let _scheduler: _RXSwift_SchedulerType
    
    init(source: _RXSwift_Observable<Element>, dueTime: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType) {
        self._source = source
        self._dueTime = dueTime
        self._scheduler = scheduler
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = DelaySink(observer: observer, dueTime: self._dueTime, scheduler: self._scheduler, cancel: cancel)
        let subscription = sink.run(source: self._source)
        return (sink: sink, subscription: subscription)
    }
}
