//
//  NopDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable that does nothing on disposal.
///
/// Nop = No Operation
private struct NopDisposable : _RXSwift_Disposable {
 
    fileprivate static let noOp: _RXSwift_Disposable = NopDisposable()
    
    private init() {
        
    }
    
    /// Does nothing.
    public func dispose() {
    }
}

extension _RXSwift_Disposables {
    /**
     Creates a disposable that does nothing on disposal.
     */
    static public func create() -> _RXSwift_Disposable {
        return NopDisposable.noOp
    }
}
