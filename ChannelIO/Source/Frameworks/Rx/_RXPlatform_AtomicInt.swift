//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSLock

final class _RXPlatform_AtomicInt: NSLock {
    fileprivate var value: Int32
    init(_ value: Int32 = 0) {
        self.value = value
    }
}

@discardableResult
@inline(__always)
func add(_ this: _RXPlatform_AtomicInt, _ value: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value += value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
func sub(_ this: _RXPlatform_AtomicInt, _ value: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value -= value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
func fetchOr(_ this: _RXPlatform_AtomicInt, _ mask: Int32) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.value |= mask
    this.unlock()
    return oldValue
}

@inline(__always)
func load(_ this: _RXPlatform_AtomicInt) -> Int32 {
    this.lock()
    let oldValue = this.value
    this.unlock()
    return oldValue
}

@discardableResult
@inline(__always)
func increment(_ this: _RXPlatform_AtomicInt) -> Int32 {
    return add(this, 1)
}

@discardableResult
@inline(__always)
func decrement(_ this: _RXPlatform_AtomicInt) -> Int32 {
    return sub(this, 1)
}

@inline(__always)
func isFlagSet(_ this: _RXPlatform_AtomicInt, _ mask: Int32) -> Bool {
    return (load(this) & mask) != 0
}
