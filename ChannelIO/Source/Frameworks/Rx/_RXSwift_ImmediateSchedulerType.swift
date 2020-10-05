//
//  ImmediateSchedulerType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents an object that immediately schedules units of work.
 protocol _RXSwift_ImmediateSchedulerType {
    /**
    Schedules an action to be executed immediately.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable
}

extension _RXSwift_ImmediateSchedulerType {
    /**
    Schedules an action to be executed recursively.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     func scheduleRecursive<State>(_ state: State, action: @escaping (_ state: State, _ recurse: (State) -> Void) -> Void) -> _RXSwift_Disposable {
        let recursiveScheduler = _RXSwift_RecursiveImmediateScheduler(action: action, scheduler: self)
        
        recursiveScheduler.schedule(state)
        
        return _RXSwift_Disposables.create(with: recursiveScheduler.dispose)
    }
}
