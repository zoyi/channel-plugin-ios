//
//  fromAsync.swift
//  RxSwiftExt
//
//  Created by Vincent on 12/08/2017.
//  Copyright © 2017 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_Observable {

    /**
     Transforms an async function that returns data through a completionHandler in a function that returns data through an Observable
     - The returned function will thake the same arguments than asyncRequest, minus the last one
     */
    static func fromAsync(_ asyncRequest: @escaping (@escaping (Element) -> Void) -> Void) -> _RXSwift_Observable<Element> {
        return _RXSwift_Observable.create({ (o) -> _RXSwift_Disposable in
            asyncRequest({ (result) in
                o.onNext(result)
                o.onCompleted()
            })

            return _RXSwift_Disposables.create()
        })
    }

    static func fromAsync<A>(_ asyncRequest: @escaping (A, @escaping (Element) -> Void) -> Void) -> (A) -> _RXSwift_Observable<Element> {
        return { (a: A) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)) }
    }

    static func fromAsync<A, B>(_ asyncRequest: @escaping (A, B, @escaping (Element) -> Void) -> Void) -> (A, B) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)) }
    }

    static func fromAsync<A, B, C>(_ asyncRequest: @escaping (A, B, C, @escaping (Element) -> Void) -> Void) -> (A, B, C) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)) }
    }

    static func fromAsync<A, B, C, D>(_ asyncRequest: @escaping (A, B, C, D, @escaping (Element) -> Void) -> Void) -> (A, B, C, D) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)) }
    }

    static func fromAsync<A, B, C, D, E>(_ asyncRequest: @escaping (A, B, C, D, E, @escaping (Element) -> Void) -> Void) -> (A, B, C, D, E) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D, e: E) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)) }
    }

    static func fromAsync<A, B, C, D, E, F>(_ asyncRequest: @escaping (A, B, C, D, E, F, @escaping (Element) -> Void) -> Void) -> (A, B, C, D, E, F) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)) }
    }

    static func fromAsync<A, B, C, D, E, F, G>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, @escaping (Element) -> Void) -> Void) -> (A, B, C, D, E, F, G) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, H>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, H, @escaping (Element) -> Void) -> Void) -> (A, B, C, D, E, F, G, H) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G, h: H) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)(h)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, H, I>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, H, I, @escaping (Element) -> Void) -> Void) -> (A, B, C, D, E, F, G, H, I) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G, h: H, i: I) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)(h)(i)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, H, I, J>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, H, I, J, @escaping (Element) -> Void) -> Void) -> (A, B, C, D, E, F, G, H, I, J) -> _RXSwift_Observable<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G, h: H, i: I, j: J) in _RXSwift_Observable.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)) }
    }
}

enum _RXEXt_FromAsyncError: Error {
    /// Both result & error can't be nil
    case inconsistentCompletionResult
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
     Transforms an async function that returns data or error through a completionHandler in a function that returns data through a Single
     - The returned function will thake the same arguments than asyncRequest, minus the last one
     */
    static func fromAsync<Er: Error>(_ asyncRequest: @escaping (@escaping (Element?, Er?) -> Void) -> Void) -> _RXSwift_Single<Element> {
        return .create { single in
            asyncRequest { result, error in
                switch (result, error) {
                case let (.some(result), nil):
                    single(.success(result))
                case let (nil, .some(error)):
                    single(.error(error))
                default:
                    single(.error(_RXEXt_FromAsyncError.inconsistentCompletionResult))
                }
            }
            return _RXSwift_Disposables.create()
        }
    }

    static func fromAsync<A, Er: Error>(_ asyncRequest: @escaping (A, @escaping (Element?, Er?) -> Void) -> Void) -> (A) -> _RXSwift_Single<Element> {
        return { (a: A) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)) }
    }

    static func fromAsync<A, B, Er: Error>(_ asyncRequest: @escaping (A, B, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B) -> _RXSwift_Single<Element> {
        return { (a: A, b: B) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)) }
    }

    static func fromAsync<A, B, C, Er: Error>(_ asyncRequest: @escaping (A, B, C, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)) }
    }

    static func fromAsync<A, B, C, D, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)) }
    }

    static func fromAsync<A, B, C, D, E, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, E, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D, E) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D, e: E) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)) }
    }

    static func fromAsync<A, B, C, D, E, F, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, E, F, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D, E, F) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D, E, F, G) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, H, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, H, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D, E, F, G, H) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G, h: H) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)(h)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, H, I, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, H, I, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D, E, F, G, H, I) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G, h: H, i: I) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)(h)(i)) }
    }

    static func fromAsync<A, B, C, D, E, F, G, H, I, J, Er: Error>(_ asyncRequest: @escaping (A, B, C, D, E, F, G, H, I, J, @escaping (Element?, Er?) -> Void) -> Void) -> (A, B, C, D, E, F, G, H, I, J) -> _RXSwift_Single<Element> {
        return { (a: A, b: B, c: C, d: D, e: E, f: F, g: G, h: H, i: I, j: J) in _RXSwift_Single.fromAsync(_RXEXt_curry(asyncRequest)(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)) }
    }
}
