//
//  SchedulerType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import enum Dispatch.DispatchTimeInterval
import struct Foundation.Date

// Type that represents time interval in the context of RxSwift.
 typealias _RXSwift_RxTimeInterval = DispatchTimeInterval

/// Type that represents absolute time in the context of RxSwift.
 typealias _RXSwift_RxTime = Date

/// Represents an object that schedules units of work.
 protocol _RXSwift_SchedulerType: _RXSwift_ImmediateSchedulerType {

    /// - returns: Current time.
    var now : _RXSwift_RxTime {
        get
    }

    /**
    Schedules an action to be executed.
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func scheduleRelative<StateType>(_ state: StateType, dueTime: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable
 
    /**
    Schedules a periodic piece of work.
    
    - parameter state: State passed to the action to be executed.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func schedulePeriodic<StateType>(_ state: StateType, startAfter: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> StateType) -> _RXSwift_Disposable
}

extension _RXSwift_SchedulerType {

    /**
    Periodic task will be emulated using recursive scheduling.

    - parameter state: Initial state passed to the action upon the first iteration.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - returns: The disposable object used to cancel the scheduled recurring action (best effort).
    */
     func schedulePeriodic<StateType>(_ state: StateType, startAfter: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> StateType) -> _RXSwift_Disposable {
        let schedule = _RXSwift_SchedulePeriodicRecursive(scheduler: self, startAfter: startAfter, period: period, action: action, state: state)
            
        return schedule.start()
    }

    func scheduleRecursive<State>(_ state: State, dueTime: _RXSwift_RxTimeInterval, action: @escaping (State, _RXSwift_AnyRecursiveScheduler<State>) -> Void) -> _RXSwift_Disposable {
        let scheduler = _RXSwift_AnyRecursiveScheduler(scheduler: self, action: action)
         
        scheduler.schedule(state, dueTime: dueTime)
            
        return _RXSwift_Disposables.create(with: scheduler.dispose)
    }
}
