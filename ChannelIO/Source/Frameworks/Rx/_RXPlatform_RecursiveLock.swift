//
//  RecursiveLock.swift
//  Platform
//
//  Created by Krunoslav Zaher on 12/18/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSRecursiveLock

#if TRACE_RESOURCES
    class _RXPlatform_RecursiveLock: NSRecursiveLock {
        override init() {
            _ = Resources.incrementTotal()
            super.init()
        }

        override func lock() {
            super.lock()
            _ = Resources.incrementTotal()
        }

        override func unlock() {
            super.unlock()
            _ = Resources.decrementTotal()
        }

        deinit {
            _ = Resources.decrementTotal()
        }
    }
#else
    typealias _RXPlatform_RecursiveLock = NSRecursiveLock
#endif
