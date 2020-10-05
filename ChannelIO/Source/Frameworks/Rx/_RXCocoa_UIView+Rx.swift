//
//  UIView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UIView {
    /// Bindable sink for `hidden` property.
    var isHidden: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { view, hidden in
            view.isHidden = hidden
        }
    }

    /// Bindable sink for `alpha` property.
    var alpha: _RXCocoa_Binder<CGFloat> {
        return _RXCocoa_Binder(self.base) { view, alpha in
            view.alpha = alpha
        }
    }

    /// Bindable sink for `backgroundColor` property.
    var backgroundColor: _RXCocoa_Binder<UIColor?> {
        return _RXCocoa_Binder(self.base) { view, color in
            view.backgroundColor = color
        }
    }

    /// Bindable sink for `isUserInteractionEnabled` property.
    var isUserInteractionEnabled: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { view, userInteractionEnabled in
            view.isUserInteractionEnabled = userInteractionEnabled
        }
    }
    
}

#endif
