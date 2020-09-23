//
//  Lock.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_Lock {
    func lock()
    func unlock()
}

// https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151214/000321.html
typealias _RXSwift_SpinLock = _RXPlatform_RecursiveLock

extension _RXPlatform_RecursiveLock : _RXSwift_Lock {
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        self.lock(); defer { self.unlock() }
        action()
    }

    @inline(__always)
    final func calculateLocked<T>(_ action: () -> T) -> T {
        self.lock(); defer { self.unlock() }
        return action()
    }

    @inline(__always)
    final func calculateLockedOrFail<T>(_ action: () throws -> T) throws -> T {
        self.lock(); defer { self.unlock() }
        let result = try action()
        return result
    }
}
