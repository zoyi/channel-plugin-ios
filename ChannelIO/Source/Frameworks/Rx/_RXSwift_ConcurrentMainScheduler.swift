//
//  ConcurrentMainScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.TimeInterval
import Dispatch

/**
Abstracts work that needs to be performed on `MainThread`. In case `schedule` methods are called from main thread, it will perform action immediately without scheduling.

This scheduler is optimized for `subscribeOn` operator. If you want to observe observable sequence elements on main thread using `observeOn` operator,
`MainScheduler` is more suitable for that purpose.
*/
 final class _RXSwift_ConcurrentMainScheduler : _RXSwift_SchedulerType {
     typealias TimeInterval = Foundation.TimeInterval
     typealias Time = Date

    private let _mainScheduler: _RXSwift_MainScheduler
    private let _mainQueue: DispatchQueue

    /// - returns: Current time.
     var now: Date {
        return self._mainScheduler.now as Date
    }

    private init(mainScheduler: _RXSwift_MainScheduler) {
        self._mainQueue = DispatchQueue.main
        self._mainScheduler = mainScheduler
    }

    /// Singleton instance of `ConcurrentMainScheduler`
     static let instance = _RXSwift_ConcurrentMainScheduler(mainScheduler: _RXSwift_MainScheduler.instance)

    /**
    Schedules an action to be executed immediately.

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        if DispatchQueue._RXPlatform_isMain {
            return action(state)
        }

        let cancel = _RXSwift_SingleAssignmentDisposable()

        self._mainQueue.async {
            if cancel.isDisposed {
                return
            }

            cancel.setDisposable(action(state))
        }

        return cancel
    }

    /**
    Schedules an action to be executed.

    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     final func scheduleRelative<StateType>(_ state: StateType, dueTime: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        return self._mainScheduler.scheduleRelative(state, dueTime: dueTime, action: action)
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
        return self._mainScheduler.schedulePeriodic(state, startAfter: startAfter, period: period, action: action)
    }
}
