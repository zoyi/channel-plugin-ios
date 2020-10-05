//
//  RxTextStorageDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//    import RxSwift
    import UIKit

    extension NSTextStorage: _RXCocoa_HasDelegate {
        typealias Delegate = NSTextStorageDelegate
    }

    class _RXCocoa_RxTextStorageDelegateProxy
        : _RXCocoa_DelegateProxy<NSTextStorage, NSTextStorageDelegate>
        , _RXCocoa_DelegateProxyType
        , NSTextStorageDelegate {

        /// Typed parent object.
        weak private(set) var textStorage: NSTextStorage?

        /// - parameter textStorage: Parent object for delegate proxy.
        init(textStorage: NSTextStorage) {
            self.textStorage = textStorage
            super.init(parentObject: textStorage, delegateProxy: _RXCocoa_RxTextStorageDelegateProxy.self)
        }

        // Register known implementations
        static func registerKnownImplementations() {
            self.register { _RXCocoa_RxTextStorageDelegateProxy(textStorage: $0) }
        }
    }
#endif
