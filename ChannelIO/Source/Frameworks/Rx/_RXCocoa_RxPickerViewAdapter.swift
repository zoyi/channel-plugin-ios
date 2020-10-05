//
//  RxPickerViewAdapter.swift
//  RxCocoa
//
//  Created by Sergey Shulga on 12/07/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
//import RxSwift

class _RXCocoa_RxPickerViewArrayDataSource<T>: NSObject, UIPickerViewDataSource, _RXCocoa_SectionedViewDataSourceType {
    fileprivate var items: [T] = []
    
    func model(at indexPath: IndexPath) throws -> Any {
        guard items.indices ~= indexPath.row else {
            throw _RXCocoa_RxCocoaError.itemsNotYetBound(object: self)
        }
        return items[indexPath.row]
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}

class _RXCocoa_RxPickerViewSequenceDataSource<Sequence: Swift.Sequence>
    : _RXCocoa_RxPickerViewArrayDataSource<Sequence.Element>
    , _RXCocoa_RxPickerViewDataSourceType {
    typealias Element = Sequence

    func pickerView(_ pickerView: UIPickerView, observedEvent: _RXSwift_Event<Sequence>) {
        _RXCocoa_Binder(self) { dataSource, items in
            dataSource.items = items
            pickerView.reloadAllComponents()
        }
        .on(observedEvent.map(Array.init))
    }
}

final class _RXCocoa_RxStringPickerViewAdapter<Sequence: Swift.Sequence>
    : _RXCocoa_RxPickerViewSequenceDataSource<Sequence>
    , UIPickerViewDelegate {
    
    typealias TitleForRow = (Int, Sequence.Element) -> String?
    private let titleForRow: TitleForRow
    
    init(titleForRow: @escaping TitleForRow) {
        self.titleForRow = titleForRow
        super.init()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRow(row, items[row])
    }
}

final class _RXCocoa_RxAttributedStringPickerViewAdapter<Sequence: Swift.Sequence>: _RXCocoa_RxPickerViewSequenceDataSource<Sequence>, UIPickerViewDelegate {
    typealias AttributedTitleForRow = (Int, Sequence.Element) -> NSAttributedString?
    private let attributedTitleForRow: AttributedTitleForRow
    
    init(attributedTitleForRow: @escaping AttributedTitleForRow) {
        self.attributedTitleForRow = attributedTitleForRow
        super.init()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return attributedTitleForRow(row, items[row])
    }
}

final class _RXCocoa_RxPickerViewAdapter<Sequence: Swift.Sequence>: _RXCocoa_RxPickerViewSequenceDataSource<Sequence>, UIPickerViewDelegate {
    typealias ViewForRow = (Int, Sequence.Element, UIView?) -> UIView
    private let viewForRow: ViewForRow
    
    init(viewForRow: @escaping ViewForRow) {
        self.viewForRow = viewForRow
        super.init()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return viewForRow(row, items[row], view)
    }
}

#endif
