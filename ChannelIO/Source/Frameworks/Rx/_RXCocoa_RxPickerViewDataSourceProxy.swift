//
//  RxPickerViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Sergey Shulga on 05/07/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
//import RxSwift

extension UIPickerView: _RXCocoa_HasDataSource {
    typealias DataSource = UIPickerViewDataSource
}

private let pickerViewDataSourceNotSet = PickerViewDataSourceNotSet()

final private class PickerViewDataSourceNotSet: NSObject, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxPickerViewDataSourceProxy
    : _RXCocoa_DelegateProxy<UIPickerView, UIPickerViewDataSource>
    , _RXCocoa_DelegateProxyType
    , UIPickerViewDataSource {

    /// Typed parent object.
    weak private(set) var pickerView: UIPickerView?

    /// - parameter pickerView: Parent object for delegate proxy.
    init(pickerView: ParentObject) {
        self.pickerView = pickerView
        super.init(parentObject: pickerView, delegateProxy: _RXCocoa_RxPickerViewDataSourceProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxPickerViewDataSourceProxy(pickerView: $0) }
    }

    private weak var _requiredMethodsDataSource: UIPickerViewDataSource? = pickerViewDataSourceNotSet

    // MARK: UIPickerViewDataSource

    /// Required delegate method implementation.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (_requiredMethodsDataSource ?? pickerViewDataSourceNotSet).numberOfComponents(in: pickerView)
    }

    /// Required delegate method implementation.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (_requiredMethodsDataSource ?? pickerViewDataSourceNotSet).pickerView(pickerView, numberOfRowsInComponent: component)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    override func setForwardToDelegate(_ forwardToDelegate: UIPickerViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? pickerViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
