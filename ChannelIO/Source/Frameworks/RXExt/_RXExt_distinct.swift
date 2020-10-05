//
//  distinct.swift
//  RxSwiftExt
//
//  Created by Segii Shulga on 5/4/16.
//  Copyright © 2017 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_Observable {
    /**
     Suppress duplicate items emitted by an Observable
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     - parameter predicate: predicate determines whether element distinct
     
     - returns: An observable sequence only containing the distinct contiguous elements, based on predicate, from the source sequence.
     */
    func distinct(_ predicate: @escaping (Element) throws -> Bool) -> _RXSwift_Observable<Element> {
        var cache = [Element]()
        return flatMap { element -> _RXSwift_Observable<Element> in
            if try cache.contains(where: predicate) {
                return _RXSwift_Observable<Element>.empty()
            } else {
                cache.append(element)
                return _RXSwift_Observable<Element>.just(element)
            }
        }
    }
}

extension _RXSwift_Observable where Element: Hashable {
    /**
     Suppress duplicate items emitted by an Observable
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    func distinct() -> _RXSwift_Observable<Element> {
        var cache = Set<Element>()
        return flatMap { element -> _RXSwift_Observable<Element> in
            if cache.contains(element) {
                return _RXSwift_Observable<Element>.empty()
            } else {
                cache.insert(element)
                return _RXSwift_Observable<Element>.just(element)
            }
        }
    }
}

extension _RXSwift_Observable where Element: Equatable {
    /**
     Suppress duplicate items emitted by an Observable
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    func distinct() -> _RXSwift_Observable<Element> {
        var cache = [Element]()
        return flatMap { element -> _RXSwift_Observable<Element> in
            if cache.contains(element) {
                return _RXSwift_Observable<Element>.empty()
            } else {
                cache.append(element)
                return _RXSwift_Observable<Element>.just(element)
            }
        }
    }
}
