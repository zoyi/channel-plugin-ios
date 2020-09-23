//
//  SerialDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable resource whose underlying disposable resource can be replaced by another disposable resource, causing automatic disposal of the previous underlying disposable resource.
 final class _RXSwift_SerialDisposable : _RXSwift_DisposeBase, _RXSwift_Cancelable {
    private var _lock = _RXSwift_SpinLock()
    
    // state
    private var _current = nil as _RXSwift_Disposable?
    private var _isDisposed = false
    
    /// - returns: Was resource disposed.
     var isDisposed: Bool {
        return self._isDisposed
    }
    
    /// Initializes a new instance of the `SerialDisposable`.
    override  init() {
        super.init()
    }
    
    /**
    Gets or sets the underlying disposable.
    
    Assigning this property disposes the previous disposable object.
    
    If the `SerialDisposable` has already been disposed, assignment to this property causes immediate disposal of the given disposable object.
    */
     var disposable: _RXSwift_Disposable {
        get {
            return self._lock.calculateLocked {
                return self._current ?? _RXSwift_Disposables.create()
            }
        }
        set (newDisposable) {
            let disposable: _RXSwift_Disposable? = self._lock.calculateLocked {
                if self._isDisposed {
                    return newDisposable
                }
                else {
                    let toDispose = self._current
                    self._current = newDisposable
                    return toDispose
                }
            }
            
            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }
    
    /// Disposes the underlying disposable as well as all future replacements.
     func dispose() {
        self._dispose()?.dispose()
    }

    private func _dispose() -> _RXSwift_Disposable? {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            return nil
        }
        else {
            self._isDisposed = true
            let current = self._current
            self._current = nil
            return current
        }
    }
}
