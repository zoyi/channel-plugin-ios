//
//  ConcurrentDispatchQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.TimeInterval
import Dispatch

/// Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. You can also pass a serial dispatch queue, it shouldn't cause any problems.
///
/// This scheduler is suitable when some work needs to be performed in background.
 class _RXSwift_ConcurrentDispatchQueueScheduler: _RXSwift_SchedulerType {
     typealias TimeInterval = Foundation.TimeInterval
     typealias Time = Date
    
     var now : Date {
        return Date()
    }

    let configuration: _RXSwift_DispatchQueueConfiguration
    
    /// Constructs new `ConcurrentDispatchQueueScheduler` that wraps `queue`.
    ///
    /// - parameter queue: Target dispatch queue.
    /// - parameter leeway: The amount of time, in nanoseconds, that the system will defer the timer.
     init(queue: DispatchQueue, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.configuration = _RXSwift_DispatchQueueConfiguration(queue: queue, leeway: leeway)
    }
    
    /// Convenience init for scheduler that wraps one of the global concurrent dispatch queues.
    ///
    /// - parameter qos: Target global dispatch queue, by quality of service class.
    /// - parameter leeway: The amount of time, in nanoseconds, that the system will defer the timer.
    @available(iOS 8, OSX 10.10, *)
     convenience init(qos: DispatchQoS, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.init(queue: DispatchQueue(
            label: "rxswift.queue.\(qos)",
            qos: qos,
            attributes: [DispatchQueue.Attributes.concurrent],
            target: nil),
            leeway: leeway
        )
    }

    /**
    Schedules an action to be executed immediately.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     final func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        return self.configuration.schedule(state, action: action)
    }
    
    /**
    Schedules an action to be executed.
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     final func scheduleRelative<StateType>(_ state: StateType, dueTime: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        return self.configuration.scheduleRelative(state, dueTime: dueTime, action: action)
    }
    
    /**
    Schedules a periodic piece of work.
    
    - parameter state: State passed to the action to be executed.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     func schedulePeriodic<StateType>(_ state: StateType, startAfter: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> StateType) -> _RXSwift_Disposable {
        return self.configuration.schedulePeriodic(state, startAfter: startAfter, period: period, action: action)
    }
}