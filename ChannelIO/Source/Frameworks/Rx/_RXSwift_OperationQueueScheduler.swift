//
//  OperationQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.Operation
import class Foundation.OperationQueue
import class Foundation.BlockOperation
import Dispatch

/// Abstracts the work that needs to be performed on a specific `NSOperationQueue`.
///
/// This scheduler is suitable for cases when there is some bigger chunk of work that needs to be performed in background and you want to fine tune concurrent processing using `maxConcurrentOperationCount`.
 class _RXSwift_OperationQueueScheduler: _RXSwift_ImmediateSchedulerType {
     let operationQueue: OperationQueue
     let queuePriority: Operation.QueuePriority
    
    /// Constructs new instance of `OperationQueueScheduler` that performs work on `operationQueue`.
    ///
    /// - parameter operationQueue: Operation queue targeted to perform work on.
    /// - parameter queuePriority: Queue priority which will be assigned to new operations.
     init(operationQueue: OperationQueue, queuePriority: Operation.QueuePriority = .normal) {
        self.operationQueue = operationQueue
        self.queuePriority = queuePriority
    }
    
    /**
    Schedules an action to be executed recursively.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to execute recursively. The last parameter passed to the action is used to trigger recursive scheduling of the action, passing in recursive invocation state.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
     func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> _RXSwift_Disposable) -> _RXSwift_Disposable {
        let cancel = _RXSwift_SingleAssignmentDisposable()

        let operation = BlockOperation {
            if cancel.isDisposed {
                return
            }


            cancel.setDisposable(action(state))
        }

        operation.queuePriority = self.queuePriority

        self.operationQueue.addOperation(operation)
        
        return cancel
    }

}
