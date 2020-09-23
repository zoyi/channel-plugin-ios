//
//  DelaySubscription.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Time shifts the observable sequence by delaying the subscription with the specified relative time duration, using the specified scheduler to run timers.

     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)

     - parameter dueTime: Relative time shift of the subscription.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: Time-shifted sequence.
     */
    func delaySubscription(_ dueTime: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<Element> {
        return DelaySubscription(source: self.asObservable(), dueTime: dueTime, scheduler: scheduler)
    }
}

final private class DelaySubscriptionSink<Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.forwardOn(event)
        if event.isStopEvent {
            self.dispose()
        }
    }
    
}

final private class DelaySubscription<Element>: _RXSwift_Producer<Element> {
    private let _source: _RXSwift_Observable<Element>
    private let _dueTime: _RXSwift_RxTimeInterval
    private let _scheduler: _RXSwift_SchedulerType
    
    init(source: _RXSwift_Observable<Element>, dueTime: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType) {
        self._source = source
        self._dueTime = dueTime
        self._scheduler = scheduler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = DelaySubscriptionSink(observer: observer, cancel: cancel)
        let subscription = self._scheduler.scheduleRelative((), dueTime: self._dueTime) { _ in
            return self._source.subscribe(sink)
        }

        return (sink: sink, subscription: subscription)
    }
}
