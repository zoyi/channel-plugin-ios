//
//  SerialDispatchQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.TimeInterval
import struct Foundation.Date
import Dispatch

/**
Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. It will make sure 
that even if concurrent dispatch queue is passed, it's transformed into a serial one.

It is extremely important that this scheduler is serial, because
certain operator perform optimizations that rely on that property.

Because there is no way of detecting is passed dispatch queue serial or
concurrent, for every queue that is being passed, worst case (concurrent)
will be assumed, and internal serial proxy dispatch queue will be created.

This scheduler can also be used with internal serial queue alone.

In case some customization need to be made on it before usage,
internal serial queue can be customized using `serialQueueConfiguration`
callback.
*/
 class _RXSwift_SerialDispatchQueueScheduler : _RXSwift_SchedulerType {
     typealias TimeInterval = Foundation.TimeInterval
     typealias Time = Date
    
    /// - returns: Current time.
     var now : Date {
        return Date()
    }

    let configuration: _RXSwift_DispatchQueueConfiguration
    
    /**
    Constructs new `SerialDispatchQueueScheduler` that wraps `serialQueue`.

    - parameter serialQueue: Target dispatch queue.
    - parameter leeway: The amount of time, in nanoseconds, that the system will defer the timer.
    */
    init(serialQueue: DispatchQueue, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.configuration = _RXSwift_DispatchQueueConfiguration(queue: serialQueue, leeway: leeway)
    }

    /**
    Constructs new `SerialDispatchQueueScheduler` with internal serial queue named `internalSerialQueueName`.
    
    Additional dispatch queue properties can be set after dispatch queue is created using `serialQueueConfiguration`.
    
    - parameter internalSerialQueueName: Name of internal serial dispatch queue.
    - parameter serialQueueConfiguration: Additional configuration of internal serial dispatch queue.
    - parameter leeway: The amount of time, in nanoseconds, that the system will defer the timer.
    */
     convenience init(internalSerialQueueName: String, serialQueueConfiguration: ((DispatchQueue) -> Void)? = nil, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        let queue = DispatchQueue(label: internalSerialQueueName, attributes: [])
        serialQueueConfiguration?(queue)
        self.init(serialQueue: queue, leeway: leeway)
    }
    
    /**
    Constructs new `SerialDispatchQueueScheduler` named `internalSerialQueueName` that wraps `queue`.
    
    - parameter queue: Possibly concurrent dispatch queue used to perform work.
    - parameter internalSerialQueueName: Name of internal serial dispatch queue proxy.
    - parameter leeway: The amount of time, in nanoseconds, that the system will defer the timer.
    */
     convenience init(queue: DispatchQueue, internalSerialQueueName: String, leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        // Swift 3.0 IUO
        let serialQueue = DispatchQueue(label: internalSerialQueueName,
                                        attributes: [],
                                        target: queue)
        self.init(serialQueue: serialQueue, leeway: leeway)
    }

    /**
     Constructs new `SerialDispatchQueueScheduler` that wraps one of the global concurrent dispatch queues.
     
     - parameter qos: Identifier for global dispatch queue with specified quality of service class.
     - parameter internalSerialQueueName: Custom name for internal serial dispatch queue proxy.
     - parameter leeway: The amount of time, in nanoseconds, that the system will defer the timer.
     */
    @available(iOS 8, OSX 10.10, *)
     convenience init(qos: DispatchQoS, internalSerialQueueName: String = "rx.global_dispatch_queue.serial", leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)) {
        self.init(queue: DispatchQueue.global(qos: qos.qosClass), internalSerialQueueName: internalSerialQueueName, leeway: leeway)
    }
    
    /**
    Schedules an action to be executed immediately.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     final func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        return self.scheduleInternal(state, action: action)
    }

    func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
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
