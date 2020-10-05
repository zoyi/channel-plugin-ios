//
//  ignoreErrors.swift
//  RxSwiftExt
//
//  Created by Florent Pillet on 18/05/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

//import RxSwift

extension _RXSwift_ObservableType {
    /**
     Unconditionally ignore all errors produced by the source observable, effectively producing a sequence
     that never fails (any error will simply have no effect on the sequence).
     
     - returns: An observable sequence that never fails
     - seealso: `retry` operator
     */
    func ignoreErrors() -> _RXSwift_Observable<Element> {
        return retry()
    }

    /**
     Conditionally ignore errors produced by the source observable
     
     - parameter predicate a predicate called when an error occurs and returns `true` to ignore the error (continuing), `false` to terminate the sequence with the given error.
     - returns: An observable sequence that errors only when `predicate` returns `false`
     */
    func ignoreErrors(_ predicate : @escaping (Error) -> Bool) -> _RXSwift_Observable<Element> {
        return retryWhen {
            return $0.flatMap { error -> _RXSwift_Observable<Bool> in
                return predicate(error) ?  _RXSwift_Observable.just(true) : _RXSwift_Observable<Bool>.error(error)
            }
        }
    }
}
