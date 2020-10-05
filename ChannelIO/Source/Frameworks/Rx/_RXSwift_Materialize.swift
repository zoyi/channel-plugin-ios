//
//  Materialize.swift
//  RxSwift
//
//  Created by sergdort on 08/03/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Convert any Observable into an Observable of its events.
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     - returns: An observable sequence that wraps events in an Event<E>. The returned Observable never errors, but it does complete after observing all of the events of the underlying Observable.
     */
    func materialize() -> _RXSwift_Observable<_RXSwift_Event<Element>> {
        return Materialize(source: self.asObservable())
    }
}

private final class MaterializeSink<Element, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Observer.Element == _RXSwift_Event<Element> {

    func on(_ event: _RXSwift_Event<Element>) {
        self.forwardOn(.next(event))
        if event.isStopEvent {
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final private class Materialize<T>: _RXSwift_Producer<_RXSwift_Event<T>> {
    private let _source: _RXSwift_Observable<T>

    init(source: _RXSwift_Observable<T>) {
        self._source = source
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = MaterializeSink(observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)

        return (sink: sink, subscription: subscription)
    }
}
