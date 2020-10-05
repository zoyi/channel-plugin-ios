//
//  CurrentThreadScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSObject
import protocol Foundation.NSCopying
import class Foundation.Thread
import Dispatch

#if os(Linux)
    import struct Foundation.pthread_key_t
    import func Foundation.pthread_setspecific
    import func Foundation.pthread_getspecific
    import func Foundation.pthread_key_create
    
    fileprivate enum CurrentThreadSchedulerQueueKey {
        fileprivate static let instance = "RxSwift.CurrentThreadScheduler.Queue"
    }
#else
    private class CurrentThreadSchedulerQueueKey: NSObject, NSCopying {
        static let instance = CurrentThreadSchedulerQueueKey()
        private override init() {
            super.init()
        }

        override var hash: Int {
            return 0
        }

         func copy(with zone: NSZone? = nil) -> Any {
            return self
        }
    }
#endif

/// Represents an object that schedules units of work on the current thread.
///
/// This is the default scheduler for operators that generate elements.
///
/// This scheduler is also sometimes called `trampoline scheduler`.
 class _RXSwift_CurrentThreadScheduler : _RXSwift_ImmediateSchedulerType {
    typealias ScheduleQueue = _RXSwift_RxMutableBox<_RXSwift_Queue<_RXSwift_ScheduledItemType>>

    /// The singleton instance of the current thread scheduler.
     static let instance = _RXSwift_CurrentThreadScheduler()

    private static var isScheduleRequiredKey: pthread_key_t = { () -> pthread_key_t in
        let key = UnsafeMutablePointer<pthread_key_t>.allocate(capacity: 1)
        defer { key.deallocate() }
                                                               
        guard pthread_key_create(key, nil) == 0 else {
            _RXSwift_rxFatalError("isScheduleRequired key creation failed")
        }

        return key.pointee
    }()

    private static var scheduleInProgressSentinel: UnsafeRawPointer = { () -> UnsafeRawPointer in
        return UnsafeRawPointer(UnsafeMutablePointer<Int>.allocate(capacity: 1))
    }()

    static var queue : ScheduleQueue? {
        get {
            return Thread._RXPlatform_getThreadLocalStorageValueForKey(CurrentThreadSchedulerQueueKey.instance)
        }
        set {
            Thread._RXPlatform_setThreadLocalStorageValue(newValue, forKey: CurrentThreadSchedulerQueueKey.instance)
        }
    }

    /// Gets a value that indicates whether the caller must call a `schedule` method.
     static private(set) var isScheduleRequired: Bool {
        get {
            return pthread_getspecific(_RXSwift_CurrentThreadScheduler.isScheduleRequiredKey) == nil
        }
        set(isScheduleRequired) {
            if pthread_setspecific(_RXSwift_CurrentThreadScheduler.isScheduleRequiredKey, isScheduleRequired ? nil : scheduleInProgressSentinel) != 0 {
                _RXSwift_rxFatalError("pthread_setspecific failed")
            }
        }
    }

    /**
    Schedules an action to be executed as soon as possible on current thread.

    If this method is called on some thread that doesn't have `CurrentThreadScheduler` installed, scheduler will be
    automatically installed and uninstalled after all work is performed.

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        if _RXSwift_CurrentThreadScheduler.isScheduleRequired {
            _RXSwift_CurrentThreadScheduler.isScheduleRequired = false

            let disposable = action(state)

            defer {
                _RXSwift_CurrentThreadScheduler.isScheduleRequired = true
                _RXSwift_CurrentThreadScheduler.queue = nil
            }

            guard let queue = _RXSwift_CurrentThreadScheduler.queue else {
                return disposable
            }

            while let latest = queue.value.dequeue() {
                if latest.isDisposed {
                    continue
                }
                latest.invoke()
            }

            return disposable
        }

        let existingQueue = _RXSwift_CurrentThreadScheduler.queue

        let queue: _RXSwift_RxMutableBox<_RXSwift_Queue<_RXSwift_ScheduledItemType>>
        if let existingQueue = existingQueue {
            queue = existingQueue
        }
        else {
            queue = _RXSwift_RxMutableBox(_RXSwift_Queue<_RXSwift_ScheduledItemType>(capacity: 1))
            _RXSwift_CurrentThreadScheduler.queue = queue
        }

        let scheduledItem = _RXSwift_ScheduledItem(action: action, state: state)
        queue.value.enqueue(scheduledItem)

        return scheduledItem
    }
}
