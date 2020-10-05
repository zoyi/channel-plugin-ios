//
//  apply.swift
//  RxSwiftExt
//
//  Created by Andy Chou on 2/22/17.
//  Copyright © 2017 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_ObservableType {
    /// Apply a transformation function to the Observable.
    func apply<Result>(_ transform: (_RXSwift_Observable<Element>) -> _RXSwift_Observable<Result>) -> _RXSwift_Observable<Result> {
        return transform(self.asObservable())
    }
}

extension _RXSwift_PrimitiveSequenceType {
    /// Apply a transformation function to the primitive sequence.
    func apply<Result>(_ transform: (_RXSwift_PrimitiveSequence<Trait, Element>) -> _RXSwift_PrimitiveSequence<Trait, Result>)
        -> _RXSwift_PrimitiveSequence<Trait, Result> {
        return transform(self.primitiveSequence)
    }
}
