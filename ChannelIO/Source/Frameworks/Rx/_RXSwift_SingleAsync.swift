//
//  SingleAsync.swift
//  RxSwift
//
//  Created by Junior B. on 09/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     The single operator is similar to first, but throws a `RxError.noElements` or `RxError.moreThanOneElement`
     if the source Observable does not emit exactly one element before successfully completing.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - returns: An observable sequence that emits a single element or throws an exception if more (or none) of them are emitted.
     */
    func single()
        -> _RXSwift_Observable<Element> {
        return SingleAsync(source: self.asObservable())
    }

    /**
     The single operator is similar to first, but throws a `RxError.NoElements` or `RxError.MoreThanOneElement`
     if the source Observable does not emit exactly one element before successfully completing.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that emits a single element or throws an exception if more (or none) of them are emitted.
     */
    func single(_ predicate: @escaping (Element) throws -> Bool)
        -> _RXSwift_Observable<Element> {
        return SingleAsync(source: self.asObservable(), predicate: predicate)
    }
}

private final class SingleAsyncSink<Observer: _RXSwift_ObserverType> : _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element
    typealias Parent = SingleAsync<Element>
    
    private let _parent: Parent
    private var _seenValue: Bool = false
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let value):
            do {
                let forward = try self._parent._predicate?(value) ?? true
                if !forward {
                    return
                }
            }
            catch let error {
                self.forwardOn(.error(error as Swift.Error))
                self.dispose()
                return
            }

            if self._seenValue {
                self.forwardOn(.error(_RXSwift_RxError.moreThanOneElement))
                self.dispose()
                return
            }

            self._seenValue = true
            self.forwardOn(.next(value))
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            if self._seenValue {
                self.forwardOn(.completed)
            } else {
                self.forwardOn(.error(_RXSwift_RxError.noElements))
            }
            self.dispose()
        }
    }
}

final class SingleAsync<Element>: _RXSwift_Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    
    private let _source: _RXSwift_Observable<Element>
    fileprivate let _predicate: Predicate?
    
    init(source: _RXSwift_Observable<Element>, predicate: Predicate? = nil) {
        self._source = source
        self._predicate = predicate
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = SingleAsyncSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
