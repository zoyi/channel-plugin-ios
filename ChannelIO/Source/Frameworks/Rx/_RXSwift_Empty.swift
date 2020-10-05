//
//  Empty.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

     - seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence with no elements.
     */
    static func empty() -> _RXSwift_Observable<Element> {
        return EmptyProducer<Element>()
    }
}

final private class EmptyProducer<Element>: _RXSwift_Producer<Element> {
    override func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        observer.on(.completed)
        return _RXSwift_Disposables.create()
    }
}
