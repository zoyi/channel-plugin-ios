//
//  NSObject+Rx+KVORepresentable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 11/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)

import Foundation.NSObject
//import RxSwift

/// Key value observing options
struct _RXCocoa_KeyValueObservingOptions: OptionSet {
    /// Raw value
    let rawValue: UInt

    init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// Whether a sequence element should be sent to the observer immediately, before the subscribe method even returns.
    static let initial = _RXCocoa_KeyValueObservingOptions(rawValue: 1 << 0)
    /// Whether to send updated values.
    static let new = _RXCocoa_KeyValueObservingOptions(rawValue: 1 << 1)
}

extension _RXSwift_Reactive where Base: NSObject {

    /**
     Specialization of generic `observe` method.

     This is a special overload because to observe values of some type (for example `Int`), first values of KVO type
     need to be observed (`NSNumber`), and then converted to result type.

     For more information take a look at `observe` method.
     */
    func observe<Element: _RXCocoa_KVORepresentable>(_ type: Element.Type, _ keyPath: String, options: _RXCocoa_KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> _RXSwift_Observable<Element?> {
        return self.observe(Element.KVOType.self, keyPath, options: options, retainSelf: retainSelf)
            .map(Element.init)
    }
}

#if !DISABLE_SWIZZLING && !os(Linux)
    // KVO
    extension _RXSwift_Reactive where Base: NSObject {
        /**
        Specialization of generic `observeWeakly` method.

        For more information take a look at `observeWeakly` method.
        */
        func observeWeakly<Element: _RXCocoa_KVORepresentable>(_ type: Element.Type, _ keyPath: String, options: _RXCocoa_KeyValueObservingOptions = [.new, .initial]) -> _RXSwift_Observable<Element?> {
            return self.observeWeakly(Element.KVOType.self, keyPath, options: options)
                .map(Element.init)
        }
    }
#endif

#endif
