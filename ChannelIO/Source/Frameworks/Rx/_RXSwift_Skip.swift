//
//  Skip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.

     - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

     - parameter count: The number of elements to skip before returning the remaining elements.
     - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
     */
    func skip(_ count: Int)
        -> _RXSwift_Observable<Element> {
        return SkipCount(source: self.asObservable(), count: count)
    }
}

extension _RXSwift_ObservableType {

    /**
     Skips elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.

     - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

     - parameter duration: Duration for skipping elements from the start of the sequence.
     - parameter scheduler: Scheduler to run the timer on.
     - returns: An observable sequence with the elements skipped during the specified duration from the start of the source sequence.
     */
    func skip(_ duration: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<Element> {
        return SkipTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// count version

final private class SkipCountSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = SkipCount<Element>
    
    let parent: Parent
    
    var remaining: Int
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self.parent = parent
        self.remaining = parent.count
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            
            if self.remaining <= 0 {
                self.forwardOn(.next(value))
            }
            else {
                self.remaining -= 1
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
}

final private class SkipCount<Element>: _RXSwift_Producer<Element> {
    let source: _RXSwift_Observable<Element>
    let count: Int
    
    init(source: _RXSwift_Observable<Element>, count: Int) {
        self.source = source
        self.count = count
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = SkipCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self.source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }
}

// time version

final private class SkipTimeSink<Element, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Observer.Element == Element {
    typealias Parent = SkipTime<Element>

    let parent: Parent
    
    // state
    var open = false
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            if self.open {
                self.forwardOn(.next(value))
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
    func tick() {
        self.open = true
    }
    
    func run() -> _RXSwift_Disposable {
        let disposeTimer = self.parent.scheduler.scheduleRelative((), dueTime: self.parent.duration) { _ in 
            self.tick()
            return _RXSwift_Disposables.create()
        }
        
        let disposeSubscription = self.parent.source.subscribe(self)
        
        return _RXSwift_Disposables.create(disposeTimer, disposeSubscription)
    }
}

final private class SkipTime<Element>: _RXSwift_Producer<Element> {
    let source: _RXSwift_Observable<Element>
    let duration: _RXSwift_RxTimeInterval
    let scheduler: _RXSwift_SchedulerType
    
    init(source: _RXSwift_Observable<Element>, duration: _RXSwift_RxTimeInterval, scheduler: _RXSwift_SchedulerType) {
        self.source = source
        self.scheduler = scheduler
        self.duration = duration
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = SkipTimeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
