//
//  Deferred.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
     static func deferred(_ observableFactory: @escaping () throws -> _RXSwift_Observable<Element>)
        -> _RXSwift_Observable<Element> {
        return Deferred(observableFactory: observableFactory)
    }
}

final private class DeferredSink<Source: _RXSwift_ObservableType, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Source.Element == Observer.Element {
    typealias Element = Observer.Element 

    private let _observableFactory: () throws -> Source

    init(observableFactory: @escaping () throws -> Source, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._observableFactory = observableFactory
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        do {
            let result = try self._observableFactory()
            return result.subscribe(self)
        }
        catch let e {
            self.forwardOn(.error(e))
            self.dispose()
            return _RXSwift_Disposables.create()
        }
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.forwardOn(event)
        
        switch event {
        case .next:
            break
        case .error:
            self.dispose()
        case .completed:
            self.dispose()
        }
    }
}

final private class Deferred<Source: _RXSwift_ObservableType>: _RXSwift_Producer<Source.Element> {
    typealias Factory = () throws -> Source
    
    private let _observableFactory : Factory
    
    init(observableFactory: @escaping Factory) {
        self._observableFactory = observableFactory
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable)
             where Observer.Element == Source.Element {
        let sink = DeferredSink(observableFactory: self._observableFactory, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
