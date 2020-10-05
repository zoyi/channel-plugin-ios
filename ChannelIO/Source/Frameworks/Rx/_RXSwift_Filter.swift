//
//  Filter.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Filters the elements of an observable sequence based on a predicate.

     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    func filter(_ predicate: @escaping (Element) throws -> Bool)
        -> _RXSwift_Observable<Element> {
        return Filter(source: self.asObservable(), predicate: predicate)
    }
}

extension _RXSwift_ObservableType {

    /**
     Skips elements and completes (or errors) when the observable sequence completes (or errors). Equivalent to filter that always returns false.

     - seealso: [ignoreElements operator on reactivex.io](http://reactivex.io/documentation/operators/ignoreelements.html)

     - returns: An observable sequence that skips all elements of the source sequence.
     */
    func ignoreElements()
        -> _RXSwift_Completable {
            return self.flatMap { _ in
                return _RXSwift_Observable<Never>.empty()
            }
            .asCompletable()
    }
}

final private class FilterSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Predicate = (Element) throws -> Bool
    typealias Element = Observer.Element
    
    private let _predicate: Predicate
    
    init(predicate: @escaping Predicate, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._predicate = predicate
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            do {
                let satisfies = try self._predicate(value)
                if satisfies {
                    self.forwardOn(.next(value))
                }
            }
            catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case .completed, .error:
            self.forwardOn(event)
            self.dispose()
        }
    }
}

final private class Filter<Element>: _RXSwift_Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    
    private let _source: _RXSwift_Observable<Element>
    private let _predicate: Predicate
    
    init(source: _RXSwift_Observable<Element>, predicate: @escaping Predicate) {
        self._source = source
        self._predicate = predicate
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = FilterSink(predicate: self._predicate, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
