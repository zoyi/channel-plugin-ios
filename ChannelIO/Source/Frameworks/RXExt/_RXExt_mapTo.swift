//
//  mapTo.swift
//  RxSwiftExt
//
//  Created by Marin Todorov on 4/12/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_ObservableType {

	/**
	Returns an observable sequence containing as many elements as its input but all of them are the constant provided as a parameter
	
	- parameter value: A constant that each element of the input sequence is being replaced with
	- returns: An observable sequence containing the values `value` provided as a parameter
	*/
	func mapTo<Result>(_ value: Result) -> _RXSwift_Observable<Result> {
		return map { _ in value }
	}
}

extension _RXSwift_PrimitiveSequence where Trait == _RXSwift_SingleTrait {
    /**
     Returns a Single which success event is mapped to constant provided as a parameter

     - parameter value: A constant that element of the input sequence is being replaced with
     - returns: A Single containing the value `value` provided as a parameter in case of success
     */
    func mapTo<Result>(_ value: Result) -> _RXSwift_Single<Result> {
        return map { _ in value }
    }
}

extension _RXSwift_PrimitiveSequence where Trait == _RXSwift_MaybeTrait {
    /**
     Returns a Maybe which success event is mapped to constant provided as a parameter

     - parameter value: A constant that element of the input sequence is being replaced with
     - returns: A Maybe containing the value `value` provided as a parameter in case of success
     */
    func mapTo<Result>(_ value: Result) -> _RXSwift_Maybe<Result> {
        return map { _ in value }
    }
}
