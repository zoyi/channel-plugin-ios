//
//  ObservableConvertibleType+Driver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

extension _RXSwift_ObservableConvertibleType {
    /**
    Converts observable sequence to `Driver` trait.
    
    - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
    - returns: Driver trait.
    */
    func asDriver(onErrorJustReturn: Element) -> _RXCocoa_Driver<Element> {
        let source = self
            .asObservable()
            .observeOn(_RXCocoa_DriverSharingStrategy.scheduler)
            .catchErrorJustReturn(onErrorJustReturn)
        return _RXCocoa_Driver(source)
    }
    
    /**
    Converts observable sequence to `Driver` trait.
    
    - parameter onErrorDriveWith: Driver that continues to drive the sequence in case of error.
    - returns: Driver trait.
    */
    func asDriver(onErrorDriveWith: _RXCocoa_Driver<Element>) -> _RXCocoa_Driver<Element> {
        let source = self
            .asObservable()
            .observeOn(_RXCocoa_DriverSharingStrategy.scheduler)
            .catchError { _ in
                onErrorDriveWith.asObservable()
            }
        return _RXCocoa_Driver(source)
    }

    /**
    Converts observable sequence to `Driver` trait.
    
    - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
    - returns: Driver trait.
    */
    func asDriver(onErrorRecover: @escaping (_ error: Swift.Error) -> _RXCocoa_Driver<Element>) -> _RXCocoa_Driver<Element> {
        let source = self
            .asObservable()
            .observeOn(_RXCocoa_DriverSharingStrategy.scheduler)
            .catchError { error in
                onErrorRecover(error).asObservable()
            }
        return _RXCocoa_Driver(source)
    }
}
