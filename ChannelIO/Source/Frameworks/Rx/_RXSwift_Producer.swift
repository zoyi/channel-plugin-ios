//
//  Producer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class _RXSwift_Producer<Element> : _RXSwift_Observable<Element> {
    override init() {
        super.init()
    }

    override func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        if !_RXSwift_CurrentThreadScheduler.isScheduleRequired {
            // The returned disposable needs to release all references once it was disposed.
            let disposer = SinkDisposer()
            let sinkAndSubscription = self.run(observer, cancel: disposer)
            disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

            return disposer
        }
        else {
            return _RXSwift_CurrentThreadScheduler.instance.schedule(()) { _ in
                let disposer = SinkDisposer()
                let sinkAndSubscription = self.run(observer, cancel: disposer)
                disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

                return disposer
            }
        }
    }

    func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        _RXSwift_rxAbstractMethod()
    }
}

private final class SinkDisposer: _RXSwift_Cancelable {
    private enum DisposeState: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }

    private let _state = _RXPlatform_AtomicInt(0)
    private var _sink: _RXSwift_Disposable?
    private var _subscription: _RXSwift_Disposable?

    var isDisposed: Bool {
        return isFlagSet(self._state, DisposeState.disposed.rawValue)
    }

    func setSinkAndSubscription(sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) {
        self._sink = sink
        self._subscription = subscription

        let previousState = fetchOr(self._state, DisposeState.sinkAndSubscriptionSet.rawValue)
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            _RXSwift_rxFatalError("Sink and subscription were already set")
        }

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            sink.dispose()
            subscription.dispose()
            self._sink = nil
            self._subscription = nil
        }
    }

    func dispose() {
        let previousState = fetchOr(self._state, DisposeState.disposed.rawValue)

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            guard let sink = self._sink else {
                _RXSwift_rxFatalError("Sink not set")
            }
            guard let subscription = self._subscription else {
                _RXSwift_rxFatalError("Subscription not set")
            }

            sink.dispose()
            subscription.dispose()

            self._sink = nil
            self._subscription = nil
        }
    }
}
