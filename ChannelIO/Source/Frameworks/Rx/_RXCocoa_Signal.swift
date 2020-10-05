//
//  Signal.swift
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
 - `share(scope: .whileConnected)` sharing strategy

 Additional explanation:
 - all observers share sequence computation resources
 - there is no replaying of sequence elements on new observer subscription
 - computation of elements is reference counted with respect to the number of observers
 - if there are no subscribers, it will release sequence computation resources

 In case trait that models state propagation is required, please check `Driver`.

 `Signal<Element>` can be considered a builder pattern for observable sequences that model imperative events part of the application.
 
 To find out more about units and how to use them, please visit `Documentation/Traits.md`.
 */
typealias _RXCocoa_Signal<Element> = _RXSwift_SharedSequence<_RXCocoa_SignalSharingStrategy, Element>

struct _RXCocoa_SignalSharingStrategy: _RXSwift_SharingStrategyProtocol {
    static var scheduler: _RXSwift_SchedulerType { return _RXCocoa_SharingScheduler.make() }
    
    static func share<Element>(_ source: _RXSwift_Observable<Element>) -> _RXSwift_Observable<Element> {
        return source.share(scope: .whileConnected)
    }
}

extension _RXSwift_SharedSequenceConvertibleType where SharingStrategy == _RXCocoa_SignalSharingStrategy {
    /// Adds `asPublisher` to `SharingSequence` with `PublishSharingStrategy`.
    func asSignal() -> _RXCocoa_Signal<Element> {
        return self.asSharedSequence()
    }
}
