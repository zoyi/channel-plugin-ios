//
//  NSTextStorage+Rx.swift
//  RxCocoa
//
//  Created by Segii Shulga on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
//    import RxSwift
    import UIKit
    
    extension _RXSwift_Reactive where Base: NSTextStorage {

        /// Reactive wrapper for `delegate`.
        ///
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        var delegate: _RXCocoa_DelegateProxy<NSTextStorage, NSTextStorageDelegate> {
            return _RXCocoa_RxTextStorageDelegateProxy.proxy(for: base)
        }

        /// Reactive wrapper for `delegate` message.
        var didProcessEditingRangeChangeInLength: _RXSwift_Observable<(editedMask: NSTextStorage.EditActions, editedRange: NSRange, delta: Int)> {
            return delegate
                .methodInvoked(#selector(NSTextStorageDelegate.textStorage(_:didProcessEditing:range:changeInLength:)))
                .map { a in
                    let editedMask = NSTextStorage.EditActions(rawValue: try _RXCocoa_castOrThrow(UInt.self, a[1]) )
                    let editedRange = try _RXCocoa_castOrThrow(NSValue.self, a[2]).rangeValue
                    let delta = try _RXCocoa_castOrThrow(Int.self, a[3])
                    
                    return (editedMask, editedRange, delta)
                }
        }
    }
#endif
