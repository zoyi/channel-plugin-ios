//
//  Sink.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class _RXSwift_Sink<Observer: _RXSwift_ObserverType> : _RXSwift_Disposable {
    fileprivate let _observer: Observer
    fileprivate let _cancel: _RXSwift_Cancelable
    private let _disposed = _RXPlatform_AtomicInt(0)

    #if DEBUG
        private let _synchronizationTracker = _RXSwift_SynchronizationTracker()
    #endif

    init(observer: Observer, cancel: _RXSwift_Cancelable) {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
        self._observer = observer
        self._cancel = cancel
    }

    final func forwardOn(_ event: _RXSwift_Event<Observer.Element>) {
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        if isFlagSet(self._disposed, 1) {
            return
        }
        self._observer.on(event)
    }

    final func forwarder() -> _RXSwift_SinkForward<Observer> {
        return _RXSwift_SinkForward(forward: self)
    }

    final var disposed: Bool {
        return isFlagSet(self._disposed, 1)
    }

    func dispose() {
        fetchOr(self._disposed, 1)
        self._cancel.dispose()
    }

    deinit {
#if TRACE_RESOURCES
       _ =  Resources.decrementTotal()
#endif
    }
}

final class _RXSwift_SinkForward<Observer: _RXSwift_ObserverType>: _RXSwift_ObserverType {
    typealias Element = Observer.Element 

    private let _forward: _RXSwift_Sink<Observer>

    init(forward: _RXSwift_Sink<Observer>) {
        self._forward = forward
    }

    final func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._forward._observer.on(event)
        case .error, .completed:
            self._forward._observer.on(event)
            self._forward._cancel.dispose()
        }
    }
}
