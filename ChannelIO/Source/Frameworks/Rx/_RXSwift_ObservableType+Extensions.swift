//
//  ObservableType+Extensions.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if DEBUG
    import Foundation
#endif

extension _RXSwift_ObservableType {
    /**
     Subscribes an event handler to an observable sequence.
     
     - parameter on: Action to invoke for each event in the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
     func subscribe(_ on: @escaping (_RXSwift_Event<Element>) -> Void)
        -> _RXSwift_Disposable {
            let observer = _RXSwift_AnonymousObserver { e in
                on(e)
            }
            return self.asObservable().subscribe(observer)
    }
    
    
    /**
     Subscribes an element handler, an error handler, a completion handler and disposed handler to an observable sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter onDisposed: Action to invoke upon any type of termination of sequence (if the sequence has
     gracefully completed, errored, or if the generation is canceled by disposing subscription).
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
     func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil)
        -> _RXSwift_Disposable {
            let disposable: _RXSwift_Disposable
            
            if let disposed = onDisposed {
                disposable = _RXSwift_Disposables.create(with: disposed)
            }
            else {
                disposable = _RXSwift_Disposables.create()
            }
            
            #if DEBUG
                let synchronizationTracker = _RXSwift_SynchronizationTracker()
            #endif
            
            let callStack = _RXSwift_Hooks.recordCallStackOnError ? _RXSwift_Hooks.customCaptureSubscriptionCallstack() : []
            
            let observer = _RXSwift_AnonymousObserver<Element> { event in
                
                #if DEBUG
                    synchronizationTracker.register(synchronizationErrorMessage: .default)
                    defer { synchronizationTracker.unregister() }
                #endif
                
                switch event {
                case .next(let value):
                    onNext?(value)
                case .error(let error):
                    if let onError = onError {
                        onError(error)
                    }
                    else {
                        _RXSwift_Hooks.defaultErrorHandler(callStack, error)
                    }
                    disposable.dispose()
                case .completed:
                    onCompleted?()
                    disposable.dispose()
                }
            }
            return _RXSwift_Disposables.create(
                self.asObservable().subscribe(observer),
                disposable
            )
    }
}

import class Foundation.NSRecursiveLock

extension _RXSwift_Hooks {
     typealias DefaultErrorHandler = (_ subscriptionCallStack: [String], _ error: Error) -> Void
     typealias CustomCaptureSubscriptionCallstack = () -> [String]

    private static let _lock = _RXPlatform_RecursiveLock()
    private static var _defaultErrorHandler: DefaultErrorHandler = { subscriptionCallStack, error in
        #if DEBUG
            let serializedCallStack = subscriptionCallStack.joined(separator: "\n")
            print("Unhandled error happened: \(error)")
            if !serializedCallStack.isEmpty {
                print("subscription called from:\n\(serializedCallStack)")
            }
        #endif
    }
    private static var _customCaptureSubscriptionCallstack: CustomCaptureSubscriptionCallstack = {
        #if DEBUG
            return Thread.callStackSymbols
        #else
            return []
        #endif
    }

    /// Error handler called in case onError handler wasn't provided.
     static var defaultErrorHandler: DefaultErrorHandler {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _defaultErrorHandler
        }
        set {
            _lock.lock(); defer { _lock.unlock() }
            _defaultErrorHandler = newValue
        }
    }
    
    /// Subscription callstack block to fetch custom callstack information.
     static var customCaptureSubscriptionCallstack: CustomCaptureSubscriptionCallstack {
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _customCaptureSubscriptionCallstack
        }
        set {
            _lock.lock(); defer { _lock.unlock() }
            _customCaptureSubscriptionCallstack = newValue
        }
    }
}

