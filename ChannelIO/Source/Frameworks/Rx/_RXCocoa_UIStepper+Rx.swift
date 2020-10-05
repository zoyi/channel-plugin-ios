//
//  UIStepper+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 9/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UIStepper {
    
    /// Reactive wrapper for `value` property.
    var value: _RXCocoa_ControlProperty<Double> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { stepper in
                stepper.value
            }, setter: { stepper, value in
                stepper.value = value
            }
        )
    }

    /// Reactive wrapper for `stepValue` property.
    var stepValue: _RXCocoa_Binder<Double> {
        return _RXCocoa_Binder(self.base) { stepper, value in
            stepper.stepValue = value
        }
    }
    
}

#endif

