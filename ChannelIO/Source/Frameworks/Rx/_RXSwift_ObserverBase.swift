//
//  ObserverBase.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class _RXSwift_ObserverBase<Element> : _RXSwift_Disposable, _RXSwift_ObserverType {
    private let _isStopped = _RXPlatform_AtomicInt(0)

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            if load(self._isStopped) == 0 {
                self.onCore(event)
            }
        case .error, .completed:
            if fetchOr(self._isStopped, 1) == 0 {
                self.onCore(event)
            }
        }
    }

    func onCore(_ event: _RXSwift_Event<Element>) {
        _RXSwift_rxAbstractMethod()
    }

    func dispose() {
        fetchOr(self._isStopped, 1)
    }
}
