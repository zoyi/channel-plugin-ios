//
//  SingleAssignmentDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
Represents a disposable resource which only allows a single assignment of its underlying disposable resource.

If an underlying disposable resource has already been set, future attempts to set the underlying disposable resource will throw an exception.
*/
 final class _RXSwift_SingleAssignmentDisposable : _RXSwift_DisposeBase, _RXSwift_Cancelable {

    private enum DisposeState: Int32 {
        case disposed = 1
        case disposableSet = 2
    }

    // state
    private let _state = _RXPlatform_AtomicInt(0)
    private var _disposable = nil as _RXSwift_Disposable?

    /// - returns: A value that indicates whether the object is disposed.
     var isDisposed: Bool {
        return isFlagSet(self._state, DisposeState.disposed.rawValue)
    }

    /// Initializes a new instance of the `SingleAssignmentDisposable`.
     override init() {
        super.init()
    }

    /// Gets or sets the underlying disposable. After disposal, the result of getting this property is undefined.
    ///
    /// **Throws exception if the `SingleAssignmentDisposable` has already been assigned to.**
     func setDisposable(_ disposable: _RXSwift_Disposable) {
        self._disposable = disposable

        let previousState = fetchOr(self._state, DisposeState.disposableSet.rawValue)

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            _RXSwift_rxFatalError("oldState.disposable != nil")
        }

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            disposable.dispose()
            self._disposable = nil
        }
    }

    /// Disposes the underlying disposable.
     func dispose() {
        let previousState = fetchOr(self._state, DisposeState.disposed.rawValue)

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            guard let disposable = self._disposable else {
                _RXSwift_rxFatalError("Disposable not set")
            }
            disposable.dispose()
            self._disposable = nil
        }
    }

}
