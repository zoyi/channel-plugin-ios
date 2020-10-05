//
//  StartWith.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Prepends a sequence of values to an observable sequence.

     - seealso: [startWith operator on reactivex.io](http://reactivex.io/documentation/operators/startwith.html)

     - parameter elements: Elements to prepend to the specified sequence.
     - returns: The source sequence prepended with the specified values.
     */
    func startWith(_ elements: Element ...)
        -> _RXSwift_Observable<Element> {
            return StartWith(source: self.asObservable(), elements: elements)
    }
}

final private class StartWith<Element>: _RXSwift_Producer<Element> {
    let elements: [Element]
    let source: _RXSwift_Observable<Element>

    init(source: _RXSwift_Observable<Element>, elements: [Element]) {
        self.source = source
        self.elements = elements
        super.init()
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        for e in self.elements {
            observer.on(.next(e))
        }

        return (sink: _RXSwift_Disposables.create(), subscription: self.source.subscribe(observer))
    }
}
