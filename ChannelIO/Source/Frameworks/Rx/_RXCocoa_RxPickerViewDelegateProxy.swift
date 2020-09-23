//
//  RxPickerViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

//    import RxSwift
    import UIKit

    extension UIPickerView: _RXCocoa_HasDelegate {
        typealias Delegate = UIPickerViewDelegate
    }

    class _RXCocoa_RxPickerViewDelegateProxy
        : _RXCocoa_DelegateProxy<UIPickerView, UIPickerViewDelegate>
        , _RXCocoa_DelegateProxyType
        , UIPickerViewDelegate {

        /// Typed parent object.
        weak private(set) var pickerView: UIPickerView?

        /// - parameter pickerView: Parent object for delegate proxy.
        init(pickerView: ParentObject) {
            self.pickerView = pickerView
            super.init(parentObject: pickerView, delegateProxy: _RXCocoa_RxPickerViewDelegateProxy.self)
        }

        // Register known implementationss
        static func registerKnownImplementations() {
            self.register { _RXCocoa_RxPickerViewDelegateProxy(pickerView: $0) }
        }
    }
#endif
