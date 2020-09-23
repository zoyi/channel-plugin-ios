//
//  toSortedArray.swift
//  RxSwiftExt
//
//  Created by Joan Disho on 17/02/18.
//  Copyright © 2018 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_ObservableType {
    /**
     Converts an Observable into another Observable that emits the whole sequence as a single array sorted using the provided closure and then terminates.

     - parameter by: A comparator closure to sort emitted elements.
     - returns: An observable sequence containing all the sorted emitted elements as an array.
    */
    func toSortedArray(by: @escaping (Element, Element) -> Bool) -> _RXSwift_Single<[Element]> {
        return toArray().map { $0.sorted(by: by) }
    }
}

extension _RXSwift_ObservableType where Element: Comparable {
    /**
     Converts an Observable into another Observable that emits the whole sequence as a single sorted array and then terminates.

     - parameter ascending: Should the emitted items be ascending or descending.
     - returns: An observable sequence containing all the sorted emitted elements as an array.
    */
    func toSortedArray(ascending: Bool = true) -> _RXSwift_Single<[Element]> {
        return toSortedArray(by: { ascending ? $0 < $1 : $0 > $1 })
    }
}
