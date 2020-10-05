//
//  SharedSequence.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

/**
    Trait that represents observable sequence that shares computation resources with following properties:

    - it never fails
    - it delivers events on `SharingStrategy.scheduler`
    - sharing strategy is customizable using `SharingStrategy.share` behavior

    `SharedSequence<Element>` can be considered a builder pattern for observable sequences that share computation resources.

    To find out more about units and how to use them, please visit `Documentation/Traits.md`.
*/
 struct _RXSwift_SharedSequence<SharingStrategy: _RXSwift_SharingStrategyProtocol, Element> : _RXSwift_SharedSequenceConvertibleType {
    let _source: _RXSwift_Observable<Element>

    init(_ source: _RXSwift_Observable<Element>) {
        self._source = SharingStrategy.share(source)
    }

    init(raw: _RXSwift_Observable<Element>) {
        self._source = raw
    }

    #if EXPANDABLE_SHARED_SEQUENCE
    /**
     This method is extension hook in case this unit needs to extended from outside the library.
     
     By defining `EXPANDABLE_SHARED_SEQUENCE` one agrees that it's up to them to ensure shared sequence
     properties are preserved after extension.
    */
     static func createUnsafe<Source: ObservableType>(source: Source) -> SharedSequence<SharingStrategy, Source.Element> {
        return SharedSequence<SharingStrategy, Source.Element>(raw: source.asObservable())
    }
    #endif

    /**
    - returns: Built observable sequence.
    */
     func asObservable() -> _RXSwift_Observable<Element> {
        return self._source
    }

    /**
    - returns: `self`
    */
     func asSharedSequence() -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return self
    }
}

/**
 Different `SharedSequence` sharing strategies must conform to this protocol.
 */
 protocol _RXSwift_SharingStrategyProtocol {
    /**
     Scheduled on which all sequence events will be delivered.
    */
    static var scheduler: _RXSwift_SchedulerType { get }

    /**
     Computation resources sharing strategy for multiple sequence observers.
     
     E.g. One can choose `share(replay:scope:)`
     as sequence event sharing strategies, but also do something more exotic, like
     implementing promises or lazy loading chains.
    */
    static func share<Element>(_ source: _RXSwift_Observable<Element>) -> _RXSwift_Observable<Element>
}

/**
A type that can be converted to `SharedSequence`.
*/
 protocol _RXSwift_SharedSequenceConvertibleType : _RXSwift_ObservableConvertibleType {
    associatedtype SharingStrategy: _RXSwift_SharingStrategyProtocol

    /**
    Converts self to `SharedSequence`.
    */
    func asSharedSequence() -> _RXSwift_SharedSequence<SharingStrategy, Element>
}

extension _RXSwift_SharedSequenceConvertibleType {
     func asObservable() -> _RXSwift_Observable<Element> {
        return self.asSharedSequence().asObservable()
    }
}


extension _RXSwift_SharedSequence {

    /**
    Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

    - returns: An observable sequence with no elements.
    */
     static func empty() -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return _RXSwift_SharedSequence(raw: _RXSwift_Observable.empty().subscribeOn(SharingStrategy.scheduler))
    }

    /**
    Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

    - returns: An observable sequence whose observers will never get called.
    */
     static func never() -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return _RXSwift_SharedSequence(raw: _RXSwift_Observable.never())
    }

    /**
    Returns an observable sequence that contains a single element.

    - parameter element: Single element in the resulting observable sequence.
    - returns: An observable sequence containing the single specified element.
    */
     static func just(_ element: Element) -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return _RXSwift_SharedSequence(raw: _RXSwift_Observable.just(element).subscribeOn(SharingStrategy.scheduler))
    }

    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
     static func deferred(_ observableFactory: @escaping () -> _RXSwift_SharedSequence<SharingStrategy, Element>)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return _RXSwift_SharedSequence(_RXSwift_Observable.deferred { observableFactory().asObservable() })
    }

    /**
    This method creates a new Observable instance with a variable number of elements.

    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

    - parameter elements: Elements to generate.
    - returns: The observable sequence whose elements are pulled from the given arguments.
    */
     static func of(_ elements: Element ...) -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        let source = _RXSwift_Observable.from(elements, scheduler: SharingStrategy.scheduler)
        return _RXSwift_SharedSequence(raw: source)
    }
}

extension _RXSwift_SharedSequence {
    
    /**
    This method converts an array to an observable sequence.
     
    - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)
     
    - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
     */
     static func from(_ array: [Element]) -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        let source = _RXSwift_Observable.from(array, scheduler: SharingStrategy.scheduler)
        return _RXSwift_SharedSequence(raw: source)
    }
    
    /**
     This method converts a sequence to an observable sequence.
     
     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)
     
     - returns: The observable sequence whose elements are pulled from the given enumerable sequence.
    */
     static func from<Sequence: Swift.Sequence>(_ sequence: Sequence) -> _RXSwift_SharedSequence<SharingStrategy, Element> where Sequence.Element == Element {
        let source = _RXSwift_Observable.from(sequence, scheduler: SharingStrategy.scheduler)
        return _RXSwift_SharedSequence(raw: source)
    }
    
    /**
     This method converts a optional to an observable sequence.
     
     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)
     
     - parameter optional: Optional element in the resulting observable sequence.
     
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
     static func from(optional: Element?) -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        let source = _RXSwift_Observable.from(optional: optional, scheduler: SharingStrategy.scheduler)
        return _RXSwift_SharedSequence(raw: source)
    }
}

extension _RXSwift_SharedSequence where Element : _RXSwift_RxAbstractInteger {
    /**
     Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.

     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)

     - parameter period: Period for producing the values in the resulting sequence.
     - returns: An observable sequence that produces a value after each period.
     */
     static func interval(_ period: _RXSwift_RxTimeInterval)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return _RXSwift_SharedSequence(_RXSwift_Observable.interval(period, scheduler: SharingStrategy.scheduler))
    }
}

// MARK: timer

extension _RXSwift_SharedSequence where Element: _RXSwift_RxAbstractInteger {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.

     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)

     - parameter dueTime: Relative time at which to produce the first value.
     - parameter period: Period to produce subsequent values.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
     static func timer(_ dueTime: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return _RXSwift_SharedSequence(_RXSwift_Observable.timer(dueTime, period: period, scheduler: SharingStrategy.scheduler))
    }
}

