//
//  distinct+RxCocoa.swift
//  RxSwiftExt
//
//  Created by Rafael Ferreira on 3/8/17.
//  Copyright © 2017 RxSwift Community. All rights reserved.
//

//import RxCocoa

extension _RXSwift_SharedSequence {
    /**
     Suppress duplicate items emitted by an SharedSequence
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     - parameter predicate: predicate determines whether element distinct

     - returns: An shared sequence only containing the distinct contiguous elements, based on predicate, from the source sequence.
     */
    func distinct(_ predicate: @escaping (Element) -> Bool) -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        var cache = [Element]()

        return flatMap { element -> _RXSwift_SharedSequence<SharingStrategy, Element> in
            if cache.contains(where: predicate) {
                return _RXSwift_SharedSequence<SharingStrategy, Element>.empty()
            } else {
                cache.append(element)

                return _RXSwift_SharedSequence<SharingStrategy, Element>.just(element)
            }
        }
    }
}

extension _RXSwift_SharedSequence where Element: Equatable {
    /**
     Suppress duplicate items emitted by an SharedSequence
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     - returns: An shared sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    func distinct() -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        var cache = [Element]()

        return flatMap { element -> _RXSwift_SharedSequence<SharingStrategy, Element> in
            if cache.contains(element) {
                return _RXSwift_SharedSequence<SharingStrategy, Element>.empty()
            } else {
                cache.append(element)

                return _RXSwift_SharedSequence<SharingStrategy, Element>.just(element)
            }
        }
    }
}
