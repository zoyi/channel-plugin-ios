//
//  LockOwnerType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_LockOwnerType : class, _RXSwift_Lock {
    var _lock: _RXPlatform_RecursiveLock { get }
}

extension _RXSwift_LockOwnerType {
    func lock() {
        self._lock.lock()
    }

    func unlock() {
        self._lock.unlock()
    }
}
