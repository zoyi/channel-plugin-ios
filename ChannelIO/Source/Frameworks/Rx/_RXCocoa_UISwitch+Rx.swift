//
//  UISwitch+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UISwitch {

    /// Reactive wrapper for `isOn` property.
    var isOn: _RXCocoa_ControlProperty<Bool> {
        return value
    }

    /// Reactive wrapper for `isOn` property.
    ///
    /// ⚠️ Versions prior to iOS 10.2 were leaking `UISwitch`'s, so on those versions
    /// underlying observable sequence won't complete when nothing holds a strong reference
    /// to `UISwitch`.
    var value: _RXCocoa_ControlProperty<Bool> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { uiSwitch in
                uiSwitch.isOn
            }, setter: { uiSwitch, value in
                uiSwitch.isOn = value
            }
        )
    }
    
}

#endif