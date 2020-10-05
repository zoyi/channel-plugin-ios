//
//  mergeWith.swift
//  RxSwiftExt
//
//  Created by Joan Disho on 12/05/18.
//  Copyright © 2018 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_Observable {
    /**
     Merges elements from the observable sequence with those of a different observable sequence into a single observable sequence.

     - parameter with: Other observable.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    func merge(with other: _RXSwift_Observable<Element>) -> _RXSwift_Observable<Element> {
        return _RXSwift_Observable.merge(self, other)
    }

    /**
     Merges elements from the observable sequence with those of a different observable sequences into a single observable sequence.

     - parameter with: Other observables.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    func merge(with others: [_RXSwift_Observable<Element>]) -> _RXSwift_Observable<Element> {
        return _RXSwift_Observable.merge([self] + others)
    }
}
