//
//  CompositeDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a group of disposable resources that are disposed together.
 final class _RXSwift_CompositeDisposable : _RXSwift_DisposeBase, _RXSwift_Cancelable {
    /// Key used to remove disposable from composite disposable
     struct DisposeKey {
        fileprivate let key: _RXPlatform_BagKey
        fileprivate init(key: _RXPlatform_BagKey) {
            self.key = key
        }
    }

    private var _lock = _RXSwift_SpinLock()
    
    // state
    private var _disposables: _RXPlatform_Bag<_RXSwift_Disposable>? = _RXPlatform_Bag()

     var isDisposed: Bool {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposables == nil
    }
    
     override init() {
    }
    
    /// Initializes a new instance of composite disposable with the specified number of disposables.
     init(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable) {
        // This overload is here to make sure we are using optimized version up to 4 arguments.
        _ = self._disposables!.insert(disposable1)
        _ = self._disposables!.insert(disposable2)
    }
    
    /// Initializes a new instance of composite disposable with the specified number of disposables.
     init(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable, _ disposable3: _RXSwift_Disposable) {
        // This overload is here to make sure we are using optimized version up to 4 arguments.
        _ = self._disposables!.insert(disposable1)
        _ = self._disposables!.insert(disposable2)
        _ = self._disposables!.insert(disposable3)
    }
    
    /// Initializes a new instance of composite disposable with the specified number of disposables.
     init(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable, _ disposable3: _RXSwift_Disposable, _ disposable4: _RXSwift_Disposable, _ disposables: _RXSwift_Disposable...) {
        // This overload is here to make sure we are using optimized version up to 4 arguments.
        _ = self._disposables!.insert(disposable1)
        _ = self._disposables!.insert(disposable2)
        _ = self._disposables!.insert(disposable3)
        _ = self._disposables!.insert(disposable4)
        
        for disposable in disposables {
            _ = self._disposables!.insert(disposable)
        }
    }
    
    /// Initializes a new instance of composite disposable with the specified number of disposables.
     init(disposables: [_RXSwift_Disposable]) {
        for disposable in disposables {
            _ = self._disposables!.insert(disposable)
        }
    }

    /**
     Adds a disposable to the CompositeDisposable or disposes the disposable if the CompositeDisposable is disposed.
     
     - parameter disposable: Disposable to add.
     - returns: Key that can be used to remove disposable from composite disposable. In case dispose bag was already
     disposed `nil` will be returned.
     */
     func insert(_ disposable: _RXSwift_Disposable) -> DisposeKey? {
        let key = self._insert(disposable)
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    private func _insert(_ disposable: _RXSwift_Disposable) -> DisposeKey? {
        self._lock.lock(); defer { self._lock.unlock() }

        let bagKey = self._disposables?.insert(disposable)
        return bagKey.map(DisposeKey.init)
    }
    
    /// - returns: Gets the number of disposables contained in the `CompositeDisposable`.
     var count: Int {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposables?.count ?? 0
    }
    
    /// Removes and disposes the disposable identified by `disposeKey` from the CompositeDisposable.
    ///
    /// - parameter disposeKey: Key used to identify disposable to be removed.
     func remove(for disposeKey: DisposeKey) {
        self._remove(for: disposeKey)?.dispose()
    }
    
    private func _remove(for disposeKey: DisposeKey) -> _RXSwift_Disposable? {
        self._lock.lock(); defer { self._lock.unlock() }
        return self._disposables?.removeKey(disposeKey.key)
    }
    
    /// Disposes all disposables in the group and removes them from the group.
     func dispose() {
        if let disposables = self._dispose() {
            disposeAll(in: disposables)
        }
    }

    private func _dispose() -> _RXPlatform_Bag<_RXSwift_Disposable>? {
        self._lock.lock(); defer { self._lock.unlock() }

        let disposeBag = self._disposables
        self._disposables = nil

        return disposeBag
    }
}

extension _RXSwift_Disposables {

    /// Creates a disposable with the given disposables.
     static func create(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable, _ disposable3: _RXSwift_Disposable) -> _RXSwift_Cancelable {
        return _RXSwift_CompositeDisposable(disposable1, disposable2, disposable3)
    }
    
    /// Creates a disposable with the given disposables.
     static func create(_ disposable1: _RXSwift_Disposable, _ disposable2: _RXSwift_Disposable, _ disposable3: _RXSwift_Disposable, _ disposables: _RXSwift_Disposable ...) -> _RXSwift_Cancelable {
        var disposables = disposables
        disposables.append(disposable1)
        disposables.append(disposable2)
        disposables.append(disposable3)
        return _RXSwift_CompositeDisposable(disposables: disposables)
    }
    
    /// Creates a disposable with the given disposables.
     static func create(_ disposables: [_RXSwift_Disposable]) -> _RXSwift_Cancelable {
        switch disposables.count {
        case 2:
            return _RXSwift_Disposables.create(disposables[0], disposables[1])
        default:
            return _RXSwift_CompositeDisposable(disposables: disposables)
        }
    }
}
