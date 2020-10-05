//
//  ToArray.swift
//  RxSwift
//
//  Created by Junior B. on 20/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


extension _RXSwift_ObservableType {

    /**
    Converts an Observable into a Single that emits the whole sequence as a single array and then terminates.
    
    For aggregation behavior see `reduce`.

    - seealso: [toArray operator on reactivex.io](http://reactivex.io/documentation/operators/to.html)
    
    - returns: A Single sequence containing all the emitted elements as array.
    */
    func toArray()
        -> _RXSwift_Single<[Element]> {
        return _RXSwift_PrimitiveSequence(raw: ToArray(source: self.asObservable()))
    }
}

final private class ToArraySink<SourceType, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Observer.Element == [SourceType] {
    typealias Parent = ToArray<SourceType>
    
    let _parent: Parent
    var _list = [SourceType]()
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<SourceType>) {
        switch event {
        case .next(let value):
            self._list.append(value)
        case .error(let e):
            self.forwardOn(.error(e))
            self.dispose()
        case .completed:
            self.forwardOn(.next(self._list))
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class ToArray<SourceType>: _RXSwift_Producer<[SourceType]> {
    let _source: _RXSwift_Observable<SourceType>

    init(source: _RXSwift_Observable<SourceType>) {
        self._source = source
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == [SourceType] {
        let sink = ToArraySink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
