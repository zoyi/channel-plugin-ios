//
//  UISegmentedControl+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UISegmentedControl {
    /// Reactive wrapper for `selectedSegmentIndex` property.
    var selectedSegmentIndex: _RXCocoa_ControlProperty<Int> {
        return value
    }
    
    /// Reactive wrapper for `selectedSegmentIndex` property.
    var value: _RXCocoa_ControlProperty<Int> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { segmentedControl in
                segmentedControl.selectedSegmentIndex
            }, setter: { segmentedControl, value in
                segmentedControl.selectedSegmentIndex = value
            }
        )
    }
    
    /// Reactive wrapper for `setEnabled(_:forSegmentAt:)`
    func enabledForSegment(at index: Int) -> _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { segmentedControl, segmentEnabled -> Void in
            segmentedControl.setEnabled(segmentEnabled, forSegmentAt: index)
        }
    }
    
    /// Reactive wrapper for `setTitle(_:forSegmentAt:)`
    func titleForSegment(at index: Int) -> _RXCocoa_Binder<String?> {
        return _RXCocoa_Binder(self.base) { segmentedControl, title -> Void in
            segmentedControl.setTitle(title, forSegmentAt: index)
        }
    }
    
    /// Reactive wrapper for `setImage(_:forSegmentAt:)`
    func imageForSegment(at index: Int) -> _RXCocoa_Binder<UIImage?> {
        return _RXCocoa_Binder(self.base) { segmentedControl, image -> Void in
            segmentedControl.setImage(image, forSegmentAt: index)
        }
    }

}

#endif
