//
//  mapTo+RxCocoa.swift
//  RxSwiftExt
//
//  Created by Rafael Ferreira on 3/7/17.
//  Copyright © 2017 RxSwift Community. All rights reserved.
//

//import RxCocoa

extension _RXSwift_SharedSequenceConvertibleType {
    /**
     Returns an Unit containing as many elements as its input but all of them are the constant provided as a parameter

     - parameter value: A constant that each element of the input sequence is being replaced with
     - returns: An unit containing the values `value` provided as a parameter
     */
    func mapTo<Result>(_ value: Result) -> _RXSwift_SharedSequence<SharingStrategy, Result> {
        return map { _ in value }
    }

    @available(*, deprecated, renamed: "mapTo(_:)")
    func map<Result>(to value: Result) -> _RXSwift_SharedSequence<SharingStrategy, Result> {
        return map { _ in value }
    }
}
