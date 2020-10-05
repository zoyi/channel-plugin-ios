//
//  ObservableType+PrimitiveSequence.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/17/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     The `asSingle` operator throws a `RxError.noElements` or `RxError.moreThanOneElement`
     if the source Observable does not emit exactly one element before successfully completing.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - returns: An observable sequence that emits a single element when the source Observable has completed, or throws an exception if more (or none) of them are emitted.
     */
     func asSingle() -> _RXSwift_Single<Element> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_AsSingle(source: self.asObservable()))
    }
    
    /**
     The `first` operator emits only the very first item emitted by this Observable,
     or nil if this Observable completes without emitting anything.
     
     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)
     
     - returns: An observable sequence that emits a single element or nil if the source observable sequence completes without emitting any items.
     */
     func first() -> _RXSwift_Single<Element?> {
        return _RXSwift_PrimitiveSequence(raw: First(source: self.asObservable()))
    }

    /**
     The `asMaybe` operator throws a `RxError.moreThanOneElement`
     if the source Observable does not emit at most one element before successfully completing.

     - seealso: [single operator on reactivex.io](http://reactivex.io/documentation/operators/first.html)

     - returns: An observable sequence that emits a single element, completes when the source Observable has completed, or throws an exception if more of them are emitted.
     */
     func asMaybe() -> _RXSwift_Maybe<Element> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_AsMaybe(source: self.asObservable()))
    }
}

extension _RXSwift_ObservableType where Element == Never {
    /**
     - returns: An observable sequence that completes.
     */
     func asCompletable()
        -> _RXSwift_Completable {
            return _RXSwift_PrimitiveSequence(raw: self.asObservable())
    }
}
