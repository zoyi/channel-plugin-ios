//
//  KVORepresentable+Swift.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 11/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSNumber

extension Int : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.int32Value)
    }
}

extension Int32 : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.int32Value)
    }
}

extension Int64 : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.int64Value)
    }
}

extension UInt : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.uintValue)
    }
}

extension UInt32 : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.uint32Value)
    }
}

extension UInt64 : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.uint64Value)
    }
}

extension Bool : _RXCocoa_KVORepresentable {
    typealias KVOType = NSNumber

    /// Constructs `Self` using KVO value.
    init?(KVOValue: KVOType) {
        self.init(KVOValue.boolValue)
    }
}


extension RawRepresentable where RawValue: _RXCocoa_KVORepresentable {
    /// Constructs `Self` using optional KVO value.
    init?(KVOValue: RawValue.KVOType?) {
        guard let KVOValue = KVOValue else {
            return nil
        }

        guard let rawValue = RawValue(KVOValue: KVOValue) else {
            return nil
        }

        self.init(rawValue: rawValue)
    }
}
