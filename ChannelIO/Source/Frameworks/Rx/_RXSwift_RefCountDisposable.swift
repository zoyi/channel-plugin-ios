//
//  RefCountDisposable.swift
//  RxSwift
//
//  Created by Junior B. on 10/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable resource that only disposes its underlying disposable resource when all dependent disposable objects have been disposed.
 final class _RXSwift_RefCountDisposable : _RXSwift_DisposeBase, _RXSwift_Cancelable {
    private var _lock = _RXSwift_SpinLock()
    private var _disposable = nil as _RXSwift_Disposable?
    private var _primaryDisposed = false
    private var _count = 0

    /// - returns: Was resource disposed.
     var isDisposed: Bool {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposable == nil
    }

    /// Initializes a new instance of the `RefCountDisposable`.
     init(disposable: _RXSwift_Disposable) {
        self._disposable = disposable
        super.init()
    }

    /**
     Holds a dependent disposable that when disposed decreases the refcount on the underlying disposable.

     When getter is called, a dependent disposable contributing to the reference count that manages the underlying disposable's lifetime is returned.
     */
     func retain() -> _RXSwift_Disposable {
        return self._lock.calculateLocked {
            if self._disposable != nil {
                do {
                    _ = try _RXSwift_incrementChecked(&self._count)
                } catch {
                    _RXSwift_rxFatalError("RefCountDisposable increment failed")
                }

                return _RXSwift_RefCountInnerDisposable(self)
            } else {
                return _RXSwift_Disposables.create()
            }
        }
    }

    /// Disposes the underlying disposable only when all dependent disposables have been disposed.
     func dispose() {
        let oldDisposable: _RXSwift_Disposable? = self._lock.calculateLocked {
            if let oldDisposable = self._disposable, !self._primaryDisposed {
                self._primaryDisposed = true

                if self._count == 0 {
                    self._disposable = nil
                    return oldDisposable
                }
            }

            return nil
        }

        if let disposable = oldDisposable {
            disposable.dispose()
        }
    }

    fileprivate func release() {
        let oldDisposable: _RXSwift_Disposable? = self._lock.calculateLocked {
            if let oldDisposable = self._disposable {
                do {
                    _ = try _RXSwift_decrementChecked(&self._count)
                } catch {
                    _RXSwift_rxFatalError("RefCountDisposable decrement on release failed")
                }

                guard self._count >= 0 else {
                    _RXSwift_rxFatalError("RefCountDisposable counter is lower than 0")
                }

                if self._primaryDisposed && self._count == 0 {
                    self._disposable = nil
                    return oldDisposable
                }
            }

            return nil
        }

        if let disposable = oldDisposable {
            disposable.dispose()
        }
    }
}

internal final class _RXSwift_RefCountInnerDisposable: _RXSwift_DisposeBase, _RXSwift_Disposable
{
    private let _parent: _RXSwift_RefCountDisposable
    private let _isDisposed = _RXPlatform_AtomicInt(0)

    init(_ parent: _RXSwift_RefCountDisposable) {
        self._parent = parent
        super.init()
    }

    internal func dispose()
    {
        if fetchOr(self._isDisposed, 1) == 0 {
            self._parent.release()
        }
    }
}
