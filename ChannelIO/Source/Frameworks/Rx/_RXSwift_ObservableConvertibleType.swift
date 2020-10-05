//
//  ObservableConvertibleType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Type that can be converted to observable sequence (`Observable<Element>`).
protocol _RXSwift_ObservableConvertibleType {
    /// Type of elements in sequence.
    associatedtype Element

    @available(*, deprecated, renamed: "Element")
    typealias E = Element

    /// Converts `self` to `Observable` sequence.
    ///
    /// - returns: Observable sequence that represents `self`.
    func asObservable() -> _RXSwift_Observable<Element>
}
