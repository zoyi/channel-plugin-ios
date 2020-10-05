//
//  BehaviorRelay+Driver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 10/7/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift
//import RxRelay

extension _RXRelay_BehaviorRelay {
    /// Converts `BehaviorRelay` to `Driver`.
    ///
    /// - returns: Observable sequence.
    func asDriver() -> _RXCocoa_Driver<Element> {
        let source = self.asObservable()
            .observeOn(_RXCocoa_DriverSharingStrategy.scheduler)
        return _RXSwift_SharedSequence(source)
    }
}
