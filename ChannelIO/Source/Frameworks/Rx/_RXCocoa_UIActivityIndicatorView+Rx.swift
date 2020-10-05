//
//  UIActivityIndicatorView+Rx.swift
//  RxCocoa
//
//  Created by Ivan Persidskiy on 02/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UIActivityIndicatorView {

    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    var isAnimating: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { activityIndicator, active in
            if active {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

}

#endif
