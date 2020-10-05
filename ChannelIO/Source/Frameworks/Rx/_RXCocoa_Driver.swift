//
//  Driver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

/**
 Trait that represents observable sequence with following properties:

 - it never fails
 - it delivers events on `MainScheduler.instance`
 - `share(replay: 1, scope: .whileConnected)` sharing strategy
 
 Additional explanation:
 - all observers share sequence computation resources
 - it's stateful, upon subscription (calling subscribe) last element is immediately replayed if it was produced
 - computation of elements is reference counted with respect to the number of observers
 - if there are no subscribers, it will release sequence computation resources

 In case trait that models event bus is required, please check `Signal`.

 `Driver<Element>` can be considered a builder pattern for observable sequences that drive the application.

 If observable sequence has produced at least one element, after new subscription is made last produced element will be
 immediately replayed on the same thread on which the subscription was made.

 When using `drive*`, `subscribe*` and `bind*` family of methods, they should always be called from main thread.

 If `drive*`, `subscribe*` and `bind*` are called from background thread, it is possible that initial replay
 will happen on background thread, and subsequent events will arrive on main thread.

 To find out more about traits and how to use them, please visit `Documentation/Traits.md`.
 */
typealias _RXCocoa_Driver<Element> = _RXSwift_SharedSequence<_RXCocoa_DriverSharingStrategy, Element>

struct _RXCocoa_DriverSharingStrategy: _RXSwift_SharingStrategyProtocol {
    static var scheduler: _RXSwift_SchedulerType { return _RXCocoa_SharingScheduler.make() }
    static func share<Element>(_ source: _RXSwift_Observable<Element>) -> _RXSwift_Observable<Element> {
        return source.share(replay: 1, scope: .whileConnected)
    }
}

extension _RXSwift_SharedSequenceConvertibleType where SharingStrategy == _RXCocoa_DriverSharingStrategy {
    /// Adds `asDriver` to `SharingSequence` with `DriverSharingStrategy`.
    func asDriver() -> _RXCocoa_Driver<Element> {
        return self.asSharedSequence()
    }
}

