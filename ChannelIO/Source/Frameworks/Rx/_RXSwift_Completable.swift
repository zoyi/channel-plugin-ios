//
//  Completable.swift
//  RxSwift
//
//  Created by sergdort on 19/08/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if DEBUG
import Foundation
#endif

/// Sequence containing 0 elements
 enum _RXSwift_CompletableTrait { }
/// Represents a push style sequence containing 0 elements.
 typealias _RXSwift_Completable = _RXSwift_PrimitiveSequence<_RXSwift_CompletableTrait, Swift.Never>

 enum _RXSwift_CompletableEvent {
    /// Sequence terminated with an error. (underlying observable sequence emits: `.error(Error)`)
    case error(Swift.Error)
    
    /// Sequence completed successfully.
    case completed
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_CompletableTrait, Element == Swift.Never {
     typealias CompletableObserver = (_RXSwift_CompletableEvent) -> Void
    
    /**
     Creates an observable sequence from a specified subscribe method implementation.
     
     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)
     
     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
     static func create(subscribe: @escaping (@escaping CompletableObserver) -> _RXSwift_Disposable) -> _RXSwift_PrimitiveSequence<Trait, Element> {
        let source = _RXSwift_Observable<Element>.create { observer in
            return subscribe { event in
                switch event {
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
        }
        
        return _RXSwift_PrimitiveSequence(raw: source)
    }
    
    /**
     Subscribes `observer` to receive events for this sequence.
     
     - returns: Subscription for `observer` that can be used to cancel production of sequence elements and free resources.
     */
     func subscribe(_ observer: @escaping (_RXSwift_CompletableEvent) -> Void) -> _RXSwift_Disposable {
        var stopped = false
        return self.primitiveSequence.asObservable().subscribe { event in
            if stopped { return }
            stopped = true
            
            switch event {
            case .next:
                _RXSwift_rxFatalError("Completables can't emit values")
            case .error(let error):
                observer(.error(error))
            case .completed:
                observer(.completed)
            }
        }
    }
    
    /**
     Subscribes a completion handler and an error handler for this sequence.
     
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
     func subscribe(onCompleted: (() -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil) -> _RXSwift_Disposable {
        #if DEBUG
                let callStack = _RXSwift_Hooks.recordCallStackOnError ? Thread.callStackSymbols : []
        #else
                let callStack = [String]()
        #endif

        return self.primitiveSequence.subscribe { event in
            switch event {
            case .error(let error):
                if let onError = onError {
                    onError(error)
                } else {
                    _RXSwift_Hooks.defaultErrorHandler(callStack, error)
                }
            case .completed:
                onCompleted?()
            }
        }
    }
}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_CompletableTrait, Element == Swift.Never {
    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: The observable sequence that terminates with specified error.
     */
     static func error(_ error: Swift.Error) -> _RXSwift_Completable {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.error(error))
    }

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
     static func never() -> _RXSwift_Completable {
        return _RXSwift_PrimitiveSequence(raw: _RXSwift_Observable.never())
    }

    /**
     Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

     - seealso: [empty operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence with no elements.
     */
     static func empty() -> _RXSwift_Completable {
        return _RXSwift_Completable(raw: _RXSwift_Observable.empty())
    }

}

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_CompletableTrait, Element == Swift.Never {
    /**
     Invokes an action for each event in the observable sequence, and propagates all observer messages through the result sequence.
     
     - seealso: [do operator on reactivex.io](http://reactivex.io/documentation/operators/do.html)
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter afterError: Action to invoke after errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter afterCompleted: Action to invoke after graceful termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
     func `do`(onError: ((Swift.Error) throws -> Void)? = nil,
                     afterError: ((Swift.Error) throws -> Void)? = nil,
                     onCompleted: (() throws -> Void)? = nil,
                     afterCompleted: (() throws -> Void)? = nil,
                     onSubscribe: (() -> Void)? = nil,
                     onSubscribed: (() -> Void)? = nil,
                     onDispose: (() -> Void)? = nil)
        -> _RXSwift_Completable {
            return _RXSwift_Completable(raw: self.primitiveSequence.source.do(
                onError: onError,
                afterError: afterError,
                onCompleted: onCompleted,
                afterCompleted: afterCompleted,
                onSubscribe: onSubscribe,
                onSubscribed: onSubscribed,
                onDispose: onDispose)
            )
    }



    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.
     
     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
     
     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
     func concat(_ second: _RXSwift_Completable) -> _RXSwift_Completable {
        return _RXSwift_Completable.concat(self.primitiveSequence, second)
    }
    
    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
     
     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
     
     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
     static func concat<Sequence: Swift.Sequence>(_ sequence: Sequence) -> _RXSwift_Completable
        where Sequence.Element == _RXSwift_Completable {
            let source = _RXSwift_Observable.concat(sequence.lazy.map { $0.asObservable() })
            return _RXSwift_Completable(raw: source)
    }
    
    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
     
     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
     
     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
     static func concat<Collection: Swift.Collection>(_ collection: Collection) -> _RXSwift_Completable
        where Collection.Element == _RXSwift_Completable {
            let source = _RXSwift_Observable.concat(collection.map { $0.asObservable() })
            return _RXSwift_Completable(raw: source)
    }
    
    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.
     
     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)
     
     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
     static func concat(_ sources: _RXSwift_Completable ...) -> _RXSwift_Completable {
        let source = _RXSwift_Observable.concat(sources.map { $0.asObservable() })
        return _RXSwift_Completable(raw: source)
    }

    /**
     Merges the completion of all Completables from a collection into a single Completable.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
     - note: For `Completable`, `zip` is an alias for `merge`.

     - parameter sources: Collection of Completables to merge.
     - returns: A Completable that merges the completion of all Completables.
     */
     static func zip<Collection: Swift.Collection>(_ sources: Collection) -> _RXSwift_Completable
           where Collection.Element == _RXSwift_Completable {
        let source = _RXSwift_Observable.merge(sources.map { $0.asObservable() })
        return _RXSwift_Completable(raw: source)
    }

    /**
     Merges the completion of all Completables from an array into a single Completable.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
     - note: For `Completable`, `zip` is an alias for `merge`.

     - parameter sources: Array of observable sequences to merge.
     - returns: A Completable that merges the completion of all Completables.
     */
     static func zip(_ sources: [_RXSwift_Completable]) -> _RXSwift_Completable {
        let source = _RXSwift_Observable.merge(sources.map { $0.asObservable() })
        return _RXSwift_Completable(raw: source)
    }

    /**
     Merges the completion of all Completables into a single Completable.

     - seealso: [merge operator on reactivex.io](http://reactivex.io/documentation/operators/merge.html)
     - note: For `Completable`, `zip` is an alias for `merge`.

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
     static func zip(_ sources: _RXSwift_Completable...) -> _RXSwift_Completable {
        let source = _RXSwift_Observable.merge(sources.map { $0.asObservable() })
        return _RXSwift_Completable(raw: source)
    }
}
