//
//  Error.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    static func error(_ error: Swift.Error) -> _RXSwift_Observable<Element> {
        return ErrorProducer(error: error)
    }
}

final private class ErrorProducer<Element>: _RXSwift_Producer<Element> {
    private let _error: Swift.Error
    
    init(error: Swift.Error) {
        self._error = error
    }
    
    override func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        observer.on(.error(self._error))
        return _RXSwift_Disposables.create()
    }
}
