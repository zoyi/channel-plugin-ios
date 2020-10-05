//
//  BooleanDisposable.swift
//  RxSwift
//
//  Created by Junior B. on 10/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable resource that can be checked for disposal status.
final class _RXSwift_BooleanDisposable : _RXSwift_Cancelable {

    internal static let BooleanDisposableTrue = _RXSwift_BooleanDisposable(isDisposed: true)
    private var _isDisposed = false
    
    /// Initializes a new instance of the `BooleanDisposable` class
    init() {
    }
    
    /// Initializes a new instance of the `BooleanDisposable` class with given value
    init(isDisposed: Bool) {
        self._isDisposed = isDisposed
    }
    
    /// - returns: Was resource disposed.
    var isDisposed: Bool {
        return self._isDisposed
    }
    
    /// Sets the status to disposed, which can be observer through the `isDisposed` property.
    func dispose() {
        self._isDisposed = true
    }
}
