//
//  AsMaybe.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

private final class AsMaybeSink<Observer: _RXSwift_ObserverType> : _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element

    private var _element: _RXSwift_Event<Element>?

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            if self._element != nil {
                self.forwardOn(.error(_RXSwift_RxError.moreThanOneElement))
                self.dispose()
            }

            self._element = event
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            if let element = self._element {
                self.forwardOn(element)
            }
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final class _RXSwift_AsMaybe<Element>: _RXSwift_Producer<Element> {
    private let _source: _RXSwift_Observable<Element>

    init(source: _RXSwift_Observable<Element>) {
        self._source = source
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = AsMaybeSink(observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
