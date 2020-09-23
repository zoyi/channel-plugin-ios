//
//  Enumerated.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Enumerates the elements of an observable sequence.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - returns: An observable sequence that contains tuples of source sequence elements and their indexes.
     */
     func enumerated()
        -> _RXSwift_Observable<(index: Int, element: Element)> {
        return Enumerated(source: self.asObservable())
    }
}

final private class EnumeratedSink<Element, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Observer.Element == (index: Int, element: Element) {
    var index = 0
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            do {
                let nextIndex = try _RXSwift_incrementChecked(&self.index)
                let next = (index: nextIndex, element: value)
                self.forwardOn(.next(next))
            }
            catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case .completed:
            self.forwardOn(.completed)
            self.dispose()
        case .error(let error):
            self.forwardOn(.error(error))
            self.dispose()
        }
    }
}

final private class Enumerated<Element>: _RXSwift_Producer<(index: Int, element: Element)> {
    private let _source: _RXSwift_Observable<Element>

    init(source: _RXSwift_Observable<Element>) {
        self._source = source
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == (index: Int, element: Element) {
        let sink = EnumeratedSink<Element, Observer>(observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
