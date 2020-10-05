//
//  DefaultIfEmpty.swift
//  RxSwift
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Emits elements from the source observable sequence, or a default element if the source observable sequence is empty.

     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)

     - parameter default: Default element to be sent if the source does not emit any elements
     - returns: An observable sequence which emits default element end completes in case the original sequence is empty
     */
    func ifEmpty(default: Element) -> _RXSwift_Observable<Element> {
        return DefaultIfEmpty(source: self.asObservable(), default: `default`)
    }
}

final private class DefaultIfEmptySink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    private let _default: Element
    private var _isEmpty = true
    
    init(default: Element, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._default = `default`
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._isEmpty = false
            self.forwardOn(event)
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            if self._isEmpty {
                self.forwardOn(.next(self._default))
            }
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class DefaultIfEmpty<SourceType>: _RXSwift_Producer<SourceType> {
    private let _source: _RXSwift_Observable<SourceType>
    private let _default: SourceType
    
    init(source: _RXSwift_Observable<SourceType>, `default`: SourceType) {
        self._source = source
        self._default = `default`
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == SourceType {
        let sink = DefaultIfEmptySink(default: self._default, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
