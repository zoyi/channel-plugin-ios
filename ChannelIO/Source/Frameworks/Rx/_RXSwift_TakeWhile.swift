//
//  TakeWhile.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Returns elements from an observable sequence as long as a specified condition is true.

     - seealso: [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)

     - parameter predicate: A function to test each element for a condition.
     - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
     */
    func takeWhile(_ predicate: @escaping (Element) throws -> Bool)
        -> _RXSwift_Observable<Element> {
        return TakeWhile(source: self.asObservable(), predicate: predicate)
    }
}

final private class TakeWhileSink<Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = TakeWhile<Element>

    private let _parent: Parent

    private var _running = true

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            if !self._running {
                return
            }
            
            do {
                self._running = try self._parent._predicate(value)
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
                return
            }
            
            if self._running {
                self.forwardOn(.next(value))
            } else {
                self.forwardOn(.completed)
                self.dispose()
            }
        case .error, .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
}

final private class TakeWhile<Element>: _RXSwift_Producer<Element> {
    typealias Predicate = (Element) throws -> Bool

    private let _source: _RXSwift_Observable<Element>
    fileprivate let _predicate: Predicate

    init(source: _RXSwift_Observable<Element>, predicate: @escaping Predicate) {
        self._source = source
        self._predicate = predicate
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = TakeWhileSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
