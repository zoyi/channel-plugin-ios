//
//  ElementAt.swift
//  RxSwift
//
//  Created by Junior B. on 21/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Returns a sequence emitting only element _n_ emitted by an Observable

     - seealso: [elementAt operator on reactivex.io](http://reactivex.io/documentation/operators/elementat.html)

     - parameter index: The index of the required element (starting from 0).
     - returns: An observable sequence that emits the desired element as its own sole emission.
     */
    func elementAt(_ index: Int)
        -> _RXSwift_Observable<Element> {
        return ElementAt(source: self.asObservable(), index: index, throwOnEmpty: true)
    }
}

final private class ElementAtSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias SourceType = Observer.Element
    typealias Parent = ElementAt<SourceType>
    
    let _parent: Parent
    var _i: Int
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        self._i = parent._index
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<SourceType>) {
        switch event {
        case .next:

            if self._i == 0 {
                self.forwardOn(event)
                self.forwardOn(.completed)
                self.dispose()
            }
            
            do {
                _ = try _RXSwift_decrementChecked(&self._i)
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
                return
            }
            
        case .error(let e):
            self.forwardOn(.error(e))
            self.dispose()
        case .completed:
            if self._parent._throwOnEmpty {
                self.forwardOn(.error(_RXSwift_RxError.argumentOutOfRange))
            } else {
                self.forwardOn(.completed)
            }
            
            self.dispose()
        }
    }
}

final private class ElementAt<SourceType>: _RXSwift_Producer<SourceType> {
    let _source: _RXSwift_Observable<SourceType>
    let _throwOnEmpty: Bool
    let _index: Int
    
    init(source: _RXSwift_Observable<SourceType>, index: Int, throwOnEmpty: Bool) {
        if index < 0 {
            _RXSwift_rxFatalError("index can't be negative")
        }

        self._source = source
        self._index = index
        self._throwOnEmpty = throwOnEmpty
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == SourceType {
        let sink = ElementAtSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
