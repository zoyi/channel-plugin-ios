//
//  materialized+elements.swift
//  RxSwiftExt
//
//  Created by Andy Chou on 1/5/17.
//  Copyright © 2017 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_ObservableType where Element: _RXSwift_EventConvertible {

	/**
	 Returns an observable sequence containing only next elements from its input
	 - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
	 */
	func elements() -> _RXSwift_Observable<Element.Element> {
		return compactMap { $0.event.element }
	}

	/**
	 Returns an observable sequence containing only error elements from its input
	 - seealso: [materialize operator on reactivex.io](http://reactivex.io/documentation/operators/materialize-dematerialize.html)
	 */
	func errors() -> _RXSwift_Observable<Swift.Error> {
		return compactMap { $0.event.error }
	}
}
