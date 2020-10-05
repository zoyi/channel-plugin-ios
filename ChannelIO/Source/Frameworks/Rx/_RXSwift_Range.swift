//
//  Range.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType where Element : _RXSwift_RxAbstractInteger {
    /**
     Generates an observable sequence of integral numbers within a specified range, using the specified scheduler to generate and send out observer messages.

     - seealso: [range operator on reactivex.io](http://reactivex.io/documentation/operators/range.html)

     - parameter start: The value of the first integer in the sequence.
     - parameter count: The number of sequential integers to generate.
     - parameter scheduler: Scheduler to run the generator loop on.
     - returns: An observable sequence that contains a range of sequential integral numbers.
     */
    static func range(start: Element, count: Element, scheduler: _RXSwift_ImmediateSchedulerType = _RXSwift_CurrentThreadScheduler.instance) -> _RXSwift_Observable<Element> {
        return RangeProducer<Element>(start: start, count: count, scheduler: scheduler)
    }
}

final private class RangeProducer<Element: _RXSwift_RxAbstractInteger>: _RXSwift_Producer<Element> {
    fileprivate let _start: Element
    fileprivate let _count: Element
    fileprivate let _scheduler: _RXSwift_ImmediateSchedulerType

    init(start: Element, count: Element, scheduler: _RXSwift_ImmediateSchedulerType) {
        guard count >= 0 else {
            _RXSwift_rxFatalError("count can't be negative")
        }

        guard start &+ (count - 1) >= start || count == 0 else {
            _RXSwift_rxFatalError("overflow of count")
        }

        self._start = start
        self._count = count
        self._scheduler = scheduler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = RangeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class RangeSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer> where Observer.Element: _RXSwift_RxAbstractInteger {
    typealias Parent = RangeProducer<Observer.Element>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        return self._parent._scheduler.scheduleRecursive(0 as Observer.Element) { i, recurse in
            if i < self._parent._count {
                self.forwardOn(.next(self._parent._start + i))
                recurse(i + 1)
            }
            else {
                self.forwardOn(.completed)
                self.dispose()
            }
        }
    }
}
