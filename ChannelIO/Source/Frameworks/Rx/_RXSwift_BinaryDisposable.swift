//
//  BinaryDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents two disposable resources that are disposed together.
private final class BinaryDisposable : _RXSwift_DisposeBase, _RXSwift_Cancelable {

    private let _isDisposed = _RXPlatform_AtomicInt(0)

    // state
    private var _disposable1: _RXSwift_Disposable?
    private var _disposable2: _RXSwift_Disposable?

    /// - returns: Was resource disposed.
    var isDisposed: Bool {
        return isFlagSet(self._isDisposed, 1)
    }

    /// Constructs new binary disposable from two disposables.
    ///
    /// - parameter disposable1: First disposable
    /// - parameter disposable2: Second disposable
    init(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable) {
        self._disposable1 = disposable1
        self._disposable2 = disposable2
        super.init()
    }

    /// Calls the disposal action if and only if the current instance hasn't been disposed yet.
    ///
    /// After invoking disposal action, disposal action will be dereferenced.
    func dispose() {
        if fetchOr(self._isDisposed, 1) == 0 {
            self._disposable1?.dispose()
            self._disposable2?.dispose()
            self._disposable1 = nil
            self._disposable2 = nil
        }
    }
}

extension _RXSwift_Disposables {

    /// Creates a disposable with the given disposables.
    static func create(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable) -> _RXSwift_Cancelable {
        return BinaryDisposable(disposable1, disposable2)
    }

}
