//
//  Sequence.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    // MARK: of

    /**
     This method creates a new Observable instance with a variable number of elements.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter elements: Elements to generate.
     - parameter scheduler: Scheduler to send elements on. If `nil`, elements are sent immediately on subscription.
     - returns: The observable sequence whose elements are pulled from the given arguments.
     */
     static func of(_ elements: Element ..., scheduler: _RXSwift_ImmediateSchedulerType = _RXSwift_CurrentThreadScheduler.instance) -> _RXSwift_Observable<Element> {
        return ObservableSequence(elements: elements, scheduler: scheduler)
    }
}

extension _RXSwift_ObservableType {
    /**
     Converts an array to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
     static func from(_ array: [Element], scheduler: _RXSwift_ImmediateSchedulerType = _RXSwift_CurrentThreadScheduler.instance) -> _RXSwift_Observable<Element> {
        return ObservableSequence(elements: array, scheduler: scheduler)
    }

    /**
     Converts a sequence to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
     static func from<Sequence: Swift.Sequence>(_ sequence: Sequence, scheduler: _RXSwift_ImmediateSchedulerType = _RXSwift_CurrentThreadScheduler.instance) -> _RXSwift_Observable<Element> where Sequence.Element == Element {
        return ObservableSequence(elements: sequence, scheduler: scheduler)
    }
}

final private class ObservableSequenceSink<Sequence: Swift.Sequence, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer> where Sequence.Element == Observer.Element {
    typealias Parent = ObservableSequence<Sequence>

    private let _parent: Parent

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> _RXSwift_Disposable {
        return self._parent._scheduler.scheduleRecursive(self._parent._elements.makeIterator()) { iterator, recurse in
            var mutableIterator = iterator
            if let next = mutableIterator.next() {
                self.forwardOn(.next(next))
                recurse(mutableIterator)
            }
            else {
                self.forwardOn(.completed)
                self.dispose()
            }
        }
    }
}

final private class ObservableSequence<Sequence: Swift.Sequence>: _RXSwift_Producer<Sequence.Element> {
    fileprivate let _elements: Sequence
    fileprivate let _scheduler: _RXSwift_ImmediateSchedulerType

    init(elements: Sequence, scheduler: _RXSwift_ImmediateSchedulerType) {
        self._elements = elements
        self._scheduler = scheduler
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = ObservableSequenceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
