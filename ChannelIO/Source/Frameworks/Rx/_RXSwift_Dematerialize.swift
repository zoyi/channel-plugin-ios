//
//  Dematerialize.swift
//  RxSwift
//
//  Created by Jamie Pinkham on 3/13/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType where Element: _RXSwift_EventConvertible {
    /**
     Convert any previously materialized Observable into it's original form.
     - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
     - returns: The dematerialized observable sequence.
     */
    func dematerialize() -> _RXSwift_Observable<Element.Element> {
        return Dematerialize(source: self.asObservable())
    }

}

private final class DematerializeSink<T: _RXSwift_EventConvertible, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Observer.Element == T.Element {
    fileprivate func on(_ event: _RXSwift_Event<T>) {
        switch event {
        case .next(let element):
            self.forwardOn(element.event)
            if element.event.isStopEvent {
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

final private class Dematerialize<T: _RXSwift_EventConvertible>: _RXSwift_Producer<T.Element> {
    private let _source: _RXSwift_Observable<T>

    init(source: _RXSwift_Observable<T>) {
        self._source = source
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == T.Element {
        let sink = DematerializeSink<T, Observer>(observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
