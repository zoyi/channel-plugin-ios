//
//  PublishRelay+Signal.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift
//import RxRelay

extension _RXRelay_PublishRelay {
    /// Converts `PublishRelay` to `Signal`.
    ///
    /// - returns: Observable sequence.
    func asSignal() -> _RXCocoa_Signal<Element> {
        let source = self.asObservable()
            .observeOn(_RXCocoa_SignalSharingStrategy.scheduler)
        return _RXSwift_SharedSequence(source)
    }
}
