//
//  ObservableConvertibleType+SharedSequence.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 11/1/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

extension _RXSwift_ObservableConvertibleType {
    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
     - returns: Driving observable sequence.
     */
    func asSharedSequence<S>(sharingStrategy: S.Type = S.self, onErrorJustReturn: Element) -> _RXSwift_SharedSequence<S, Element> {
        let source = self
            .asObservable()
            .observeOn(S.scheduler)
            .catchErrorJustReturn(onErrorJustReturn)
        return _RXSwift_SharedSequence(source)
    }

    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorDriveWith: SharedSequence that provides elements of the sequence in case of error.
     - returns: Driving observable sequence.
     */
    func asSharedSequence<S>(sharingStrategy: S.Type = S.self, onErrorDriveWith: _RXSwift_SharedSequence<S, Element>) -> _RXSwift_SharedSequence<S, Element> {
        let source = self
            .asObservable()
            .observeOn(S.scheduler)
            .catchError { _ in
                onErrorDriveWith.asObservable()
            }
        return _RXSwift_SharedSequence(source)
    }

    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: Driving observable sequence.
     */
    func asSharedSequence<S>(sharingStrategy: S.Type = S.self, onErrorRecover: @escaping (_ error: Swift.Error) -> _RXSwift_SharedSequence<S, Element>) -> _RXSwift_SharedSequence<S, Element> {
        let source = self
            .asObservable()
            .observeOn(S.scheduler)
            .catchError { error in
                onErrorRecover(error).asObservable()
            }
        return _RXSwift_SharedSequence(source)
    }
}