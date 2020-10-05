//
//  SchedulerType+SharedSequence.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/27/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

enum _RXCocoa_SharingScheduler {
    /// Default scheduler used in SharedSequence based traits.
    private(set) static var make: () -> _RXSwift_SchedulerType = { _RXSwift_MainScheduler() }

    /**
     This method can be used in unit tests to ensure that built in shared sequences are using mock schedulers instead
     of main schedulers.

     **This shouldn't be used in normal release builds.**
    */
    static func mock(scheduler: _RXSwift_SchedulerType, action: () -> Void) {
        return mock(makeScheduler: { scheduler }, action: action)
    }

    /**
     This method can be used in unit tests to ensure that built in shared sequences are using mock schedulers instead
     of main schedulers.

     **This shouldn't be used in normal release builds.**
     */
    static func mock(makeScheduler: @escaping () -> _RXSwift_SchedulerType, action: () -> Void) {
        let originalMake = make
        make = makeScheduler

        action()

        // If you remove this line , compiler buggy optimizations will change behavior of this code
        _RXCocoa__forceCompilerToStopDoingInsaneOptimizationsThatBreakCode(makeScheduler)
        // Scary, I know

        make = originalMake
    }
}

#if os(Linux)
    import Glibc
#else
    import func Foundation.arc4random
#endif

func _RXCocoa__forceCompilerToStopDoingInsaneOptimizationsThatBreakCode(_ scheduler: () -> _RXSwift_SchedulerType) {
    let a: Int32 = 1
#if os(Linux)
    let b = 314 + Int32(Glibc.random() & 1)
#else
    let b = 314 + Int32(arc4random() & 1)
#endif
    if a == b {
        print(scheduler())
    }
}
