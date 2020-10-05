//
//  repeatWithBehavior.swift
//  RxSwiftExt
//
//  Created by Marin Todorov on 05/08/2017.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

typealias _RXEXt_RepeatPredicate = () -> Bool

/*
 Uses RepeatBehavior defined in retryWithBehavior
*/

/** Dummy error to use with catchError to restart the observable */
private enum RepeatError: Error {
    case catchable
}

extension _RXSwift_ObservableType {

    /**
	Repeats the source observable sequence using given behavior when it completes
	- parameter behavior: Behavior that will be used when the observable completes
	- parameter scheduler: Schedular that will be used for delaying subscription after error
	- parameter shouldRepeat: Custom optional closure for decided whether the observable should repeat another round
	- returns: Observable sequence that will be automatically repeat when it completes
	*/
	func repeatWithBehavior(_ behavior: _RXEXt_RepeatBehavior, scheduler: _RXSwift_SchedulerType = _RXSwift_MainScheduler.instance, shouldRepeat: _RXEXt_RepeatPredicate? = nil) -> _RXSwift_Observable<Element> {
		return repeatWithBehavior(1, behavior: behavior, scheduler: scheduler, shouldRepeat: shouldRepeat)
	}

	/**
	Repeats the source observable sequence using given behavior when it completes
	- parameter currentRepeat: Number of the current repetition
	- parameter behavior: Behavior that will be used in case of completion
	- parameter scheduler: Schedular that will be used for delaying subscription after error
	- parameter shouldRepeat: Custom optional closure for decided whether the observable should repeat another round
	- returns: Observable sequence that will be automatically repeat when it completes
	*/
	internal func repeatWithBehavior(_ currentRepeat: UInt, behavior: _RXEXt_RepeatBehavior, scheduler: _RXSwift_SchedulerType = _RXSwift_MainScheduler.instance, shouldRepeat: _RXEXt_RepeatPredicate? = nil)
		-> _RXSwift_Observable<Element> {
			guard currentRepeat > 0 else { return _RXSwift_Observable.empty() }

			// calculate conditions for bahavior
			let conditions = behavior.calculateConditions(currentRepeat)

            return concat(_RXSwift_Observable.error(RepeatError.catchable))
                .catchError {error in
                    //if observable errors, forward the error
                    guard error is RepeatError else {
                        return _RXSwift_Observable.error(error)
                    }

                    //repeat
                    guard conditions.maxCount > currentRepeat else { return _RXSwift_Observable.empty() }

                    if let shouldRepeat = shouldRepeat, !shouldRepeat() {
                        // also return error if predicate says so
                        return _RXSwift_Observable.empty()
                    }

                    guard conditions.delay != .never else {
                        // if there is no delay, simply retry
                        return self.repeatWithBehavior(currentRepeat + 1, behavior: behavior, scheduler: scheduler, shouldRepeat: shouldRepeat)
                    }

                    // otherwise retry after specified delay
                    return _RXSwift_Observable<Void>.just(()).delaySubscription(conditions.delay, scheduler: scheduler).flatMapLatest {
                        self.repeatWithBehavior(currentRepeat + 1, behavior: behavior, scheduler: scheduler, shouldRepeat: shouldRepeat)
                    }
                }
	}
}
