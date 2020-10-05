//
//  VirtualTimeScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Base class for virtual time schedulers using a priority queue for scheduled items.
 class _RXSwift_VirtualTimeScheduler<Converter: _RXSwift_VirtualTimeConverterType>
    : _RXSwift_SchedulerType {

     typealias VirtualTime = Converter.VirtualTimeUnit
     typealias VirtualTimeInterval = Converter.VirtualTimeIntervalUnit

    private var _running : Bool

    private var _clock: VirtualTime

    private var _schedulerQueue : _RXPlatform_PriorityQueue<_RXSwift_VirtualSchedulerItem<VirtualTime>>
    private var _converter: Converter

    private var _nextId = 0

    /// - returns: Current time.
     var now: _RXSwift_RxTime {
        return self._converter.convertFromVirtualTime(self.clock)
    }

    /// - returns: Scheduler's absolute time clock value.
     var clock: VirtualTime {
        return self._clock
    }

    /// Creates a new virtual time scheduler.
    ///
    /// - parameter initialClock: Initial value for the clock.
     init(initialClock: VirtualTime, converter: Converter) {
        self._clock = initialClock
        self._running = false
        self._converter = converter
        self._schedulerQueue = _RXPlatform_PriorityQueue(hasHigherPriority: {
            switch converter.compareVirtualTime($0.time, $1.time) {
            case .lessThan:
                return true
            case .equal:
                return $0.id < $1.id
            case .greaterThan:
                return false
            }
        }, isEqual: { $0 === $1 })
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif
    }

    /**
    Schedules an action to be executed immediately.

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        return self.scheduleRelative(state, dueTime: .microseconds(0)) { a in
            return action(a)
        }
    }

    /**
     Schedules an action to be executed.

     - parameter state: State passed to the action to be executed.
     - parameter dueTime: Relative time after which to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
     func scheduleRelative<StateType>(_ state: StateType, dueTime: _RXSwift_RxTimeInterval, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        let time = self.now._RXSwift_addingDispatchInterval(dueTime)
        let absoluteTime = self._converter.convertToVirtualTime(time)
        let adjustedTime = self.adjustScheduledTime(absoluteTime)
        return self.scheduleAbsoluteVirtual(state, time: adjustedTime, action: action)
    }

    /**
     Schedules an action to be executed after relative time has passed.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
     func scheduleRelativeVirtual<StateType>(_ state: StateType, dueTime: VirtualTimeInterval, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        let time = self._converter.offsetVirtualTime(self.clock, offset: dueTime)
        return self.scheduleAbsoluteVirtual(state, time: time, action: action)
    }

    /**
     Schedules an action to be executed at absolute virtual time.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
     func scheduleAbsoluteVirtual<StateType>(_ state: StateType, time: VirtualTime, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        _RXSwift_MainScheduler.ensureExecutingOnScheduler()

        let compositeDisposable = _RXSwift_CompositeDisposable()

        let item = _RXSwift_VirtualSchedulerItem(action: {
            return action(state)
        }, time: time, id: self._nextId)

        self._nextId += 1

        self._schedulerQueue.enqueue(item)
        
        _ = compositeDisposable.insert(item)
        
        return compositeDisposable
    }

    /// Adjusts time of scheduling before adding item to schedule queue.
     func adjustScheduledTime(_ time: VirtualTime) -> VirtualTime {
        return time
    }

    /// Starts the virtual time scheduler.
     func start() {
        _RXSwift_MainScheduler.ensureExecutingOnScheduler()

        if self._running {
            return
        }

        self._running = true
        repeat {
            guard let next = self.findNext() else {
                break
            }

            if self._converter.compareVirtualTime(next.time, self.clock).greaterThan {
                self._clock = next.time
            }

            next.invoke()
            self._schedulerQueue.remove(next)
        } while self._running

        self._running = false
    }

    func findNext() -> _RXSwift_VirtualSchedulerItem<VirtualTime>? {
        while let front = self._schedulerQueue.peek() {
            if front.isDisposed {
                self._schedulerQueue.remove(front)
                continue
            }

            return front
        }

        return nil
    }

    /// Advances the scheduler's clock to the specified time, running all work till that point.
    ///
    /// - parameter virtualTime: Absolute time to advance the scheduler's clock to.
     func advanceTo(_ virtualTime: VirtualTime) {
        _RXSwift_MainScheduler.ensureExecutingOnScheduler()

        if self._running {
            fatalError("Scheduler is already running")
        }

        self._running = true
        repeat {
            guard let next = self.findNext() else {
                break
            }

            if self._converter.compareVirtualTime(next.time, virtualTime).greaterThan {
                break
            }

            if self._converter.compareVirtualTime(next.time, self.clock).greaterThan {
                self._clock = next.time
            }
            next.invoke()
            self._schedulerQueue.remove(next)
        } while self._running

        self._clock = virtualTime
        self._running = false
    }

    /// Advances the scheduler's clock by the specified relative time.
     func sleep(_ virtualInterval: VirtualTimeInterval) {
        _RXSwift_MainScheduler.ensureExecutingOnScheduler()

        let sleepTo = self._converter.offsetVirtualTime(self.clock, offset: virtualInterval)
        if self._converter.compareVirtualTime(sleepTo, self.clock).lessThen {
            fatalError("Can't sleep to past.")
        }

        self._clock = sleepTo
    }

    /// Stops the virtual time scheduler.
     func stop() {
        _RXSwift_MainScheduler.ensureExecutingOnScheduler()

        self._running = false
    }

    #if TRACE_RESOURCES
        deinit {
            _ = Resources.decrementTotal()
        }
    #endif
}

// MARK: description

extension _RXSwift_VirtualTimeScheduler: CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
     var debugDescription: String {
        return self._schedulerQueue.debugDescription
    }
}

final class _RXSwift_VirtualSchedulerItem<Time>
    : _RXSwift_Disposable {
    typealias Action = () -> _RXSwift_Disposable
    
    let action: Action
    let time: Time
    let id: Int

    var isDisposed: Bool {
        return self.disposable.isDisposed
    }
    
    var disposable = _RXSwift_SingleAssignmentDisposable()
    
    init(action: @escaping Action, time: Time, id: Int) {
        self.action = action
        self.time = time
        self.id = id
    }

    func invoke() {
         self.disposable.setDisposable(self.action())
    }
    
    func dispose() {
        self.disposable.dispose()
    }
}

extension _RXSwift_VirtualSchedulerItem
    : CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(self.time)"
    }
}
