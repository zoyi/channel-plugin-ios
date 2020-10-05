//
//  NSLayoutConstraint+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)

#if os(macOS)
    import Cocoa
#else
    import UIKit
#endif

//import RxSwift

#if os(iOS) || os(macOS) || os(tvOS)
extension _RXSwift_Reactive where Base: NSLayoutConstraint {
    /// Bindable sink for `constant` property.
    var constant: _RXCocoa_Binder<CGFloat> {
        return _RXCocoa_Binder(self.base) { constraint, constant in
            constraint.constant = constant
        }
    }
    
    /// Bindable sink for `active` property.
    @available(iOS 8, OSX 10.10, *)
    var active: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { constraint, value in
            constraint.isActive = value
        }
    }
}

#endif

#endif
