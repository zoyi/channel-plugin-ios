//
//  Single.swift
//  RxSwift
//
//  Created by sergdort on 19/08/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if DEBUG
import Foundation
#endif

/// Sequence containing exactly 1 element
enum _RXSwift_SingleTrait { }
/// Represents a push style sequence containing 1 element.
typealias _RXSwift_Single<Element> = _RXSwift_PrimitiveSequence<_RXSwift_SingleTrait, Element>

enum _RXSwift_SingleEvent<Element> {
    /// One and only sequence element is produced. (underlying observable sequence emits: `.next(Element)`, `.completed`)
    case success(Element)
    
    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    typealias SingleObserver = (_RXSwift_SingleEvent<Element>) -> Void
    
    /**
     Creates an observable sequence from a specified subscribe method implementation.
     
     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)
     
     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    static func create(subscribe: @escaping (@escaping SingleObserver) -> _RXSwift_Disposable) -> _RXSwift_Single<Element> {
        let source = _RXSwift_Observable<Element>.create { observer in
            return subscribe { event in
                switch event {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .error(let error):
                    observer.on(.error(error))
                }
            }
        }
        
        return _RXSwift_PrimitiveSequence(raw: source)
    }
    
    
    /**
     Subscribes `observer` to receive events for this sequence.
     
     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
    func subscribe(_ observer: @escaping (_RXSwift_SingleEvent<Element>) -> Void) -> _RXSwift_Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            if stopped { return }
            stopped = true
            
            switch event {
            case .next(let element):
                observer(.success(element))
            case .error(let error):
                observer(.error(error))
            case .completed:
                _RXSwift_rxFatalErrorInDebug("Singles can't emit a completion event")
            }
        }
    }
    
    /**
     Subscribes a success handler, and an error handler for this sequence.
     
     - parameter onSuccess: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    func subscribe(onSuccess: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil) -> _RXSwift_Disposable {
        #if DEBUG
             let callStack = _RXSwift_Hooks.recordCallStackOnError ? Thread.callStackSymbols : []
        #else
            let callStack = [String]()
        #endif
    
        return self.primitiveSequence.subscribe { event in
            switch event {
            case .success(let element):
                onSuccess?(element)
            case .error(let error):
                if let onError = onError {
                    onError(error)
                } else {
                    _RXSwift_Hooks.defaultErrorHandler(callStack, error)
                }
            }
        }
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {
    /**
     Returns an observable sequence that contains a single element.
     
     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)
     
     - parameter element: Single element in the resulting observable sequence.
     - returns: An observable sequence containing the single specified element.
     */
    static func just(_ element: Element) -> _RXSwift_Single<Element> {
        return _RXSwift_Single(raw: _RXSwift_Observable.just(element))
    }
    
    /**
     Returns an observable sequence that contains a single element.
     
     - seealso: [just operator on reactivex.io](http://reactivex.io/documentation/operators/just.html)
     
     - parameter element: Single element in the resulting observable sequence.
     - parameter scheduler: Scheduler to send the single element on.
     - returns: An observable sequence containing the single specified element.
     */
    static func just(_ element: Element, scheduler: _RXSwift_ImmediateSchedulerType) -> _RXSwift_Single<Element> {
        return _RXSwift_Single(raw: _RXSwift_Observable.just(element, scheduler: scheduler))
    }

    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
    static func error(_ error: Swift.Error) -> _RXSwift_Single<Element> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.error(error))
    }

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    static func never() -> _RXSwift_Single<Element> {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.never())
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_SingleTrait {

    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)

     - parameter onSuccess: Action to invoke for each element in the observable sequence.
     - parameter afterSuccess: Action to invoke for each element after the observable has passed an onNext event along to its downstream.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter afterError: Action to invoke after errored termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    func `do`(onSuccess: ((Element) throws -> Void)? = nil,
                     afterSuccess: ((Element) throws -> Void)? = nil,
                     onError: ((Swift.Error) throws -> Void)? = nil,
                     afterError: ((Swift.Error) throws -> Void)? = nil,
                     onSubscribe: (() -> Void)? = nil,
                     onSubscribed: (() -> Void)? = nil,
                     onDispose: (() -> Void)? = nil)
        -> _RXSwift_Single<Element> {
            return _RXSwift_Single(raw: self.primitiveSequence.source.do(
                onNext: onSuccess,
                afterNext: afterSuccess,
                onError: onError,
                afterError: afterError,
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose)
            )
    }

    /**
     Filters the elements of an observable sequence based on a predicate.
     
     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
     
     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    func filter(_ predicate: @escaping (Element) throws -> Bool)
        -> _RXSwift_Maybe<Element> {
            return _RXSwift_Maybe(raw: self.primitiveSequence.source.filter(predicate))
    }

    /**
     Projects each element of an observable sequence into a new form.
     
     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)
     
     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     
     */
    func map<Result>(_ transform: @escaping (Element) throws -> Result)
        -> _RXSwift_Single<Result> {
            return _RXSwift_Single(raw: self.primitiveSequence.source.map(transform))
    }
    
    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    func compactMap<Result>(_ transform: @escaping (Element) throws -> Result?)
        -> _RXSwift_Maybe<Result> {
        return _RXSwift_Maybe(raw: self.primitiveSequence.source.compactMap(transform))
    }
    
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     
     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)
     
     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    func flatMap<Result>(_ selector: @escaping (Element) throws -> _RXSwift_Single<Result>)
        -> _RXSwift_Single<Result> {
            return _RXSwift_Single<Result>(raw: self.primitiveSequence.source.flatMap(selector))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    func flatMapMaybe<Result>(_ selector: @escaping (Element) throws -> _RXSwift_Maybe<Result>)
        -> _RXSwift_Maybe<Result> {
            return _RXSwift_Maybe<Result>(raw: self.primitiveSequence.source.flatMap(selector))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    func flatMapCompletable(_ selector: @escaping (Element) throws -> _RXSwift_Completable)
        -> _RXSwift_Completable {
            return _RXSwift_Completable(raw: self.primitiveSequence.source.flatMap(selector))
    }

    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.
     
     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    static func zip<Collection: Swift.Collection, Result>(_ collection: Collection, resultSelector: @escaping ([Element]) throws -> Result) -> _RXSwift_PrimitiveSequence<Trait, Result> where Collection.Element == _RXSwift_PrimitiveSequence<Trait, Element> {
        
        if collection.isEmpty {
            return _RXSwift_PrimitiveSequence<Trait, Result>.deferred {
                return _RXSwift_PrimitiveSequence<Trait, Result>(raw: .just(try resultSelector([])))
            }
        }
        
        let raw = _RXSwift_Observable.zip(collection.map { $0.asObservable() }, resultSelector: resultSelector)
        return _RXSwift_PrimitiveSequence<Trait, Result>(raw: raw)
    }
    
    /**
     Merges the specified observable sequences into one observable sequence all of the observable sequences have produced an element at a corresponding index.
     
     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    static func zip<Collection: Swift.Collection>(_ collection: Collection) -> _RXSwift_PrimitiveSequence<Trait, [Element]> where Collection.Element == _RXSwift_PrimitiveSequence<Trait, Element> {
        
        if collection.isEmpty {
            return _RXSwift_PrimitiveSequence<Trait, [Element]>(raw: .just([]))
        }
        
        let raw = _RXSwift_Observable.zip(collection.map { $0.asObservable() })
        return _RXSwift_PrimitiveSequence(raw: raw)
    }

    /**
     Continues an observable sequence that is terminated by an error with a single element.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter element: Last element in an observable sequence in case error occurs.
     - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
     */
    func catchErrorJustReturn(_ element: Element)
        -> _RXSwift_PrimitiveSequence<Trait, Element> {
        return _RXSwift_PrimitiveSequence(raw: self.primitiveSequence.source.catchErrorJustReturn(element))
    }

    /// Converts `self` to `Maybe` trait.
    ///
    /// - returns: Maybe trait that represents `self`.
    func asMaybe() -> _RXSwift_Maybe<Element> {
        return _RXSwift_Maybe(raw: self.primitiveSequence.source)
    }

    /// Converts `self` to `Completable` trait.
    ///
    /// - returns: Completable trait that represents `self`.
    func asCompletable() -> _RXSwift_Completable {
        return self.primitiveSequence.source.ignoreElements()
    }
}
