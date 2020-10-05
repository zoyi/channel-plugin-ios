//
//  Timer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType where Element : _RXSwift_RxAbstractInteger {
    /**
     Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)

     - parameter period: Period for producing the values in the resulting sequence.
     - parameter scheduler: Scheduler to run the timer on.
     - returns: An observable sequence that produces a value after each period.
     */
     static func interval(_ period: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<Element> {
        return Timer(
            dueTime: period,
            period: period,
            scheduler: scheduler
        )
    }
}

extension _RXSwift_ObservableType where Element: _RXSwift_RxAbstractInteger {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter period: Period to produce subsequent values.
     - parameter scheduler: Scheduler to run timers on.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
     static func timer(_ dueTime: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval? = nil, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<Element> {
        return Timer(
            dueTime: dueTime,
            period: period,
            scheduler: scheduler
        )
    }
}

import Foundation

final private class TimerSink<Observer: _RXSwift_ObserverType> : _RXSwift_Sink<Observer> where Observer.Element : _RXSwift_RxAbstractInteger  {
    typealias Parent = Timer<Observer.Element>

    private let _parent: Parent
    private let _lock = _RXPlatform_RecursiveLock()

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> _RXSwift_Disposable {
        return self._parent._scheduler.schedulePeriodic(0 as Observer.Element, startAfter: self._parent._dueTime, period: self._parent._period!) { state in
            self._lock.lock(); defer { self._lock.unlock() }
            self.forwardOn(.next(state))
            return state &+ 1
        }
    }
}

final private class TimerOneOffSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer> where Observer.Element: _RXSwift_RxAbstractInteger {
    typealias Parent = Timer<Observer.Element>

    private let _parent: Parent

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> _RXSwift_Disposable {
        return self._parent._scheduler.scheduleRelative(self, dueTime: self._parent._dueTime) { [unowned self] _ -> _RXSwift_Disposable in
            self.forwardOn(.next(0))
            self.forwardOn(.completed)
            self.dispose()

            return _RXSwift_Disposables.create()
        }
    }
}

final private class Timer<Element: _RXSwift_RxAbstractInteger>: _RXSwift_Producer<Element> {
    fileprivate let _scheduler: _RXSwift_SchedulerType
    fileprivate let _dueTime: _RXSwift_RxTimeInterval
    fileprivate let _period: _RXSwift_RxTimeInterval?

    init(dueTime: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval?, scheduler: _RXSwift_SchedulerType) {
        self._scheduler = scheduler
        self._dueTime = dueTime
        self._period = period
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        if self._period != nil {
            let sink = TimerSink(parent: self, observer: observer, cancel: cancel)
            let subscription = sink.run()
            return (sink: sink, subscription: subscription)
        }
        else {
            let sink = TimerOneOffSink(parent: self, observer: observer, cancel: cancel)
            let subscription = sink.run()
            return (sink: sink, subscription: subscription)
        }
    }
}
