//
//  SwiftSupport.swift
//  RxSwift
//
//  Created by Volodymyr  Gorbenko on 3/6/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

typealias _RXSwift_IntMax = Int64
typealias _RXSwift_RxAbstractInteger = FixedWidthInteger

extension SignedInteger {
    func _RXSwift_toIntMax() -> _RXSwift_IntMax {
        return _RXSwift_IntMax(self)
    }
}
