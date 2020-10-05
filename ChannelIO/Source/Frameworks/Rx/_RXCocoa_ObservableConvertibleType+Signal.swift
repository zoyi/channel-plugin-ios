//
//  ObservableConvertibleType+Signal.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

extension _RXSwift_ObservableConvertibleType {
    /**
     Converts observable sequence to `Signal` trait.

     - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
     - returns: Signal trait.
     */
    func asSignal(onErrorJustReturn: Element) -> _RXCocoa_Signal<Element> {
        let source = self
            .asObservable()
            .observeOn(_RXCocoa_SignalSharingStrategy.scheduler)
            .catchErrorJustReturn(onErrorJustReturn)
        return _RXCocoa_Signal(source)
    }

    /**
     Converts observable sequence to `Driver` trait.

     - parameter onErrorDriveWith: Driver that continues to drive the sequence in case of error.
     - returns: Signal trait.
     */
    func asSignal(onErrorSignalWith: _RXCocoa_Signal<Element>) -> _RXCocoa_Signal<Element> {
        let source = self
            .asObservable()
            .observeOn(_RXCocoa_SignalSharingStrategy.scheduler)
            .catchError { _ in
                onErrorSignalWith.asObservable()
            }
        return _RXCocoa_Signal(source)
    }

    /**
     Converts observable sequence to `Driver` trait.

     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: Signal trait.
     */
    func asSignal(onErrorRecover: @escaping (_ error: Swift.Error) -> _RXCocoa_Signal<Element>) -> _RXCocoa_Signal<Element> {
        let source = self
            .asObservable()
            .observeOn(_RXCocoa_SignalSharingStrategy.scheduler)
            .catchError { error in
                onErrorRecover(error).asObservable()
            }
        return _RXCocoa_Signal(source)
    }
}
