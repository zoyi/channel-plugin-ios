// This file is autogenerated. Take a look at `Preprocessor` target in RxSwift project 
//
//  _RXSwift_PrimitiveSequence+Zip+arity.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//



// 2

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, resultSelector: @escaping (E1, E2) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, resultSelector: @escaping (E1, E2) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable())
            )
    }
}




// 3

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, resultSelector: @escaping (E1, E2, E3) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, resultSelector: @escaping (E1, E2, E3) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable())
            )
    }
}




// 4

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, resultSelector: @escaping (E1, E2, E3, E4) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, resultSelector: @escaping (E1, E2, E3, E4) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable())
            )
    }
}




// 5

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, resultSelector: @escaping (E1, E2, E3, E4, E5) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, resultSelector: @escaping (E1, E2, E3, E4, E5) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable())
            )
    }
}




// 6

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, resultSelector: @escaping (E1, E2, E3, E4, E5, E6) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5, E6)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, resultSelector: @escaping (E1, E2, E3, E4, E5, E6) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5, E6)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable())
            )
    }
}




// 7

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>, resultSelector: @escaping (E1, E2, E3, E4, E5, E6, E7) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5, E6, E7)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>, resultSelector: @escaping (E1, E2, E3, E4, E5, E6, E7) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5, E6, E7)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable())
            )
    }
}




// 8

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7, E8>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>, _ source8: _RXSwift_PrimitiveSequence<Trait, E8>, resultSelector: @escaping (E1, E2, E3, E4, E5, E6, E7, E8) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(), source8.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_SingleTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7, E8>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>, _ source8: _RXSwift_PrimitiveSequence<Trait, E8>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5, E6, E7, E8)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(), source8.asObservable())
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7, E8>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>, _ source8: _RXSwift_PrimitiveSequence<Trait, E8>, resultSelector: @escaping (E1, E2, E3, E4, E5, E6, E7, E8) throws -> Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
            return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
            source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(), source8.asObservable(),
                resultSelector: resultSelector)
            )
    }
}

extension _RXSwift_PrimitiveSequenceType where Element == Any, Trait == _RXSwift_MaybeTrait {
    /**
    Merges the specified observable sequences into one observable sequence of tuples whenever all of the observable sequences have produced an element at a corresponding index.

    - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

    - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
    */
    static func zip<E1, E2, E3, E4, E5, E6, E7, E8>(_ source1: _RXSwift_PrimitiveSequence<Trait, E1>, _ source2: _RXSwift_PrimitiveSequence<Trait, E2>, _ source3: _RXSwift_PrimitiveSequence<Trait, E3>, _ source4: _RXSwift_PrimitiveSequence<Trait, E4>, _ source5: _RXSwift_PrimitiveSequence<Trait, E5>, _ source6: _RXSwift_PrimitiveSequence<Trait, E6>, _ source7: _RXSwift_PrimitiveSequence<Trait, E7>, _ source8: _RXSwift_PrimitiveSequence<Trait, E8>)
        -> _RXSwift_PrimitiveSequence<Trait, (E1, E2, E3, E4, E5, E6, E7, E8)> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.zip(
                source1.asObservable(), source2.asObservable(), source3.asObservable(), source4.asObservable(), source5.asObservable(), source6.asObservable(), source7.asObservable(), source8.asObservable())
            )
    }
}


