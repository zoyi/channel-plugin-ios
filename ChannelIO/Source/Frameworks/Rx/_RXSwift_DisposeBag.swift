//
//  DisposeBag.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_Disposable {
    /// Adds `self` to `bag`
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
     func disposed(by bag: _RXSwift_DisposeBag) {
        bag.insert(self)
    }
}

/**
Thread safe bag that disposes added disposables on `deinit`.

This returns ARC (RAII) like resource management to `RxSwift`.

In case contained disposables need to be disposed, just put a different dispose bag
or create a new one in its place.

    self.existingDisposeBag = DisposeBag()

In case explicit disposal is necessary, there is also `CompositeDisposable`.
*/
 final class _RXSwift_DisposeBag: _RXSwift_DisposeBase {
    
    private var _lock = _RXSwift_SpinLock()
    
    // state
    private var _disposables = [_RXSwift_Disposable]()
    private var _isDisposed = false
    
    /// Constructs new empty dispose bag.
     override init() {
        super.init()
    }

    /// Adds `disposable` to be disposed when dispose bag is being deinited.
    ///
    /// - parameter disposable: Disposable to add.
     func insert(_ disposable: _RXSwift_Disposable) {
        self._insert(disposable)?.dispose()
    }
    
    private func _insert(_ disposable: _RXSwift_Disposable) -> _RXSwift_Disposable? {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            return disposable
        }

        self._disposables.append(disposable)

        return nil
    }

    /// This is internal on purpose, take a look at `CompositeDisposable` instead.
    private func dispose() {
        let oldDisposables = self._dispose()

        for disposable in oldDisposables {
            disposable.dispose()
        }
    }

    private func _dispose() -> [_RXSwift_Disposable] {
        self._lock.lock(); defer { self._lock.unlock() }

        let disposables = self._disposables
        
        self._disposables.removeAll(keepingCapacity: false)
        self._isDisposed = true
        
        return disposables
    }
    
    deinit {
        self.dispose()
    }
}

extension _RXSwift_DisposeBag {

    /// Convenience init allows a list of disposables to be gathered for disposal.
     convenience init(disposing disposables: _RXSwift_Disposable...) {
        self.init()
        self._disposables += disposables
    }

    /// Convenience init allows an array of disposables to be gathered for disposal.
     convenience init(disposing disposables: [_RXSwift_Disposable]) {
        self.init()
        self._disposables += disposables
    }

    /// Convenience function allows a list of disposables to be gathered for disposal.
     func insert(_ disposables: _RXSwift_Disposable...) {
        self.insert(disposables)
    }

    /// Convenience function allows an array of disposables to be gathered for disposal.
     func insert(_ disposables: [_RXSwift_Disposable]) {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            disposables.forEach { $0.dispose() }
        } else {
            self._disposables += disposables
        }
    }
}
