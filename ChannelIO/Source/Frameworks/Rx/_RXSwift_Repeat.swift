//
//  Repeat.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Generates an observable sequence that repeats the given element infinitely, using the specified scheduler to send out observer messages.

     - seealso: [repeat operator on reactivex.io](http://reactivex.io/documentation/operators/repeat.html)

     - parameter element: Element to repeat.
     - parameter scheduler: Scheduler to run the producer loop on.
     - returns: An observable sequence that repeats the given element infinitely.
     */
    static func repeatElement(_ element: Element, scheduler: _RXSwift_ImmediateSchedulerType = _RXSwift_CurrentThreadScheduler.instance) -> _RXSwift_Observable<Element> {
        return RepeatElement(element: element, scheduler: scheduler)
    }
}

final private class RepeatElement<Element>: _RXSwift_Producer<Element> {
    fileprivate let _element: Element
    fileprivate let _scheduler: _RXSwift_ImmediateSchedulerType
    
    init(element: Element, scheduler: _RXSwift_ImmediateSchedulerType) {
        self._element = element
        self._scheduler = scheduler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = RepeatElementSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()

        return (sink: sink, subscription: subscription)
    }
}

final private class RepeatElementSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer> {
    typealias Parent = RepeatElement<Observer.Element>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        return self._parent._scheduler.scheduleRecursive(self._parent._element) { e, recurse in
            self.forwardOn(.next(e))
            recurse(e)
        }
    }
}
