//
//  SchedulerServices+Emulation.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

enum _RXSwift_SchedulePeriodicRecursiveCommand {
    case tick
    case dispatchStart
}

final class _RXSwift_SchedulePeriodicRecursive<State> {
    typealias RecursiveAction = (State) -> State
    typealias RecursiveScheduler = _RXSwift_AnyRecursiveScheduler<_RXSwift_SchedulePeriodicRecursiveCommand>

    private let _scheduler: _RXSwift_SchedulerType
    private let _startAfter: _RXSwift_RxTimeInterval
    private let _period: _RXSwift_RxTimeInterval
    private let _action: RecursiveAction

    private var _state: State
    private let _pendingTickCount = _RXPlatform_AtomicInt(0)

    init(scheduler: _RXSwift_SchedulerType, startAfter: _RXSwift_RxTimeInterval, period: _RXSwift_RxTimeInterval, action: @escaping RecursiveAction, state: State) {
        self._scheduler = scheduler
        self._startAfter = startAfter
        self._period = period
        self._action = action
        self._state = state
    }

    func start() -> _RXSwift_Disposable {
        return self._scheduler.scheduleRecursive(_RXSwift_SchedulePeriodicRecursiveCommand.tick, dueTime: self._startAfter, action: self.tick)
    }

    func tick(_ command: _RXSwift_SchedulePeriodicRecursiveCommand, scheduler: RecursiveScheduler) {
        // Tries to emulate periodic scheduling as best as possible.
        // The problem that could arise is if handling periodic ticks take too long, or
        // tick interval is short.
        switch command {
        case .tick:
            scheduler.schedule(.tick, dueTime: self._period)

            // The idea is that if on tick there wasn't any item enqueued, schedule to perform work immediately.
            // Else work will be scheduled after previous enqueued work completes.
            if increment(self._pendingTickCount) == 0 {
                self.tick(.dispatchStart, scheduler: scheduler)
            }

        case .dispatchStart:
            self._state = self._action(self._state)
            // Start work and schedule check is this last batch of work
            if decrement(self._pendingTickCount) > 1 {
                // This gives priority to scheduler emulation, it's not perfect, but helps
                scheduler.schedule(_RXSwift_SchedulePeriodicRecursiveCommand.dispatchStart)
            }
        }
    }
}
