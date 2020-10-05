//
//  AnonymousDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an Action-based disposable.
///
/// When dispose method is called, disposal action will be dereferenced.
private final class AnonymousDisposable : _RXSwift_DisposeBase, _RXSwift_Cancelable {
     typealias DisposeAction = () -> Void

    private let _isDisposed = _RXPlatform_AtomicInt(0)
    private var _disposeAction: DisposeAction?

    /// - returns: Was resource disposed.
     var isDisposed: Bool {
        return isFlagSet(self._isDisposed, 1)
    }

    /// Constructs a new disposable with the given action used for disposal.
    ///
    /// - parameter disposeAction: Disposal action which will be run upon calling `dispose`.
    private init(_ disposeAction: @escaping DisposeAction) {
        self._disposeAction = disposeAction
        super.init()
    }

    // Non-deprecated version of the constructor, used by `Disposables.create(with:)`
    fileprivate init(disposeAction: @escaping DisposeAction) {
        self._disposeAction = disposeAction
        super.init()
    }

    /// Calls the disposal action if and only if the current instance hasn't been disposed yet.
    ///
    /// After invoking disposal action, disposal action will be dereferenced.
    fileprivate func dispose() {
        if fetchOr(self._isDisposed, 1) == 0 {
            if let action = self._disposeAction {
                self._disposeAction = nil
                action()
            }
        }
    }
}

extension _RXSwift_Disposables {

    /// Constructs a new disposable with the given action used for disposal.
    ///
    /// - parameter dispose: Disposal action which will be run upon calling `dispose`.
     static func create(with dispose: @escaping () -> Void) -> _RXSwift_Cancelable {
        return AnonymousDisposable(disposeAction: dispose)
    }

}
