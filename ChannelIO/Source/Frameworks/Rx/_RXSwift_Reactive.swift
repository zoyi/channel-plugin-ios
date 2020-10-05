//
//  Reactive.swift
//  RxSwift
//
//  Created by Yury Korolev on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

/**
 Use `Reactive` proxy as customization point for constrained protocol extensions.

 General pattern would be:

 // 1. Extend Reactive protocol with constrain on Base
 // Read as: Reactive Extension where Base is a SomeType
 extension Reactive where Base: SomeType {
 // 2. Put any specific reactive extension for SomeType here
 }

 With this approach we can have more specialized methods and properties using
 `Base` and not just specialized on common base type.

 */

 struct _RXSwift_Reactive<Base> {
    /// Base object to extend.
     let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
     init(_ base: Base) {
        self.base = base
    }
}

/// A type that has reactive extensions.
 protocol _RXSwift_ReactiveCompatible {
    /// Extended type
    associatedtype ReactiveBase

    @available(*, deprecated, renamed: "ReactiveBase")
    typealias CompatibleType = ReactiveBase

    /// Reactive extensions.
    static var rx: _RXSwift_Reactive<ReactiveBase>.Type { get set }

    /// Reactive extensions.
    var rx: _RXSwift_Reactive<ReactiveBase> { get set }
}

extension _RXSwift_ReactiveCompatible {
    /// Reactive extensions.
     static var rx: _RXSwift_Reactive<Self>.Type {
        get {
            return _RXSwift_Reactive<Self>.self
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // this enables using Reactive to "mutate" base type
        }
    }

    /// Reactive extensions.
     var rx: _RXSwift_Reactive<Self> {
        get {
            return _RXSwift_Reactive(self)
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

import class Foundation.NSObject

/// Extend NSObject with `rx` proxy.
extension NSObject: _RXSwift_ReactiveCompatible { }
