//
//  TakeLast.swift
//  RxSwift
//
//  Created by Tomi Koskinen on 25/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Returns a specified number of contiguous elements from the end of an observable sequence.

     This operator accumulates a buffer with a length enough to store elements count elements. Upon completion of the source sequence, this buffer is drained on the result sequence. This causes the elements to be delayed.

     - seealso: [takeLast operator on reactivex.io](http://reactivex.io/documentation/operators/takelast.html)

     - parameter count: Number of elements to take from the end of the source sequence.
     - returns: An observable sequence containing the specified number of elements from the end of the source sequence.
     */
    func takeLast(_ count: Int)
        -> _RXSwift_Observable<Element> {
        return TakeLast(source: self.asObservable(), count: count)
    }
}

final private class TakeLastSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = TakeLast<Element>
    
    private let _parent: Parent
    
    private var _elements: _RXSwift_Queue<Element>
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        self._elements = _RXSwift_Queue<Element>(capacity: parent._count + 1)
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            self._elements.enqueue(value)
            if self._elements.count > self._parent._count {
                _ = self._elements.dequeue()
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            for e in self._elements {
                self.forwardOn(.next(e))
            }
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class TakeLast<Element>: _RXSwift_Producer<Element> {
    private let _source: _RXSwift_Observable<Element>
    fileprivate let _count: Int
    
    init(source: _RXSwift_Observable<Element>, count: Int) {
        if count < 0 {
            _RXSwift_rxFatalError("count can't be negative")
        }
        self._source = source
        self._count = count
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = TakeLastSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
