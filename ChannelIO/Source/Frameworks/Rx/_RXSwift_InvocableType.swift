//
//  InvocableType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 11/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_InvocableType {
    func invoke()
}

protocol _RXSwift_InvocableWithValueType {
    associatedtype Value

    func invoke(_ value: Value)
}
