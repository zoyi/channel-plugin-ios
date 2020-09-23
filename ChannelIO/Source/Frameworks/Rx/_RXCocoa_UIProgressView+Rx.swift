//
//  UIProgressView+Rx.swift
//  RxCocoa
//
//  Created by Samuel Bae on 2/27/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UIProgressView {

    /// Bindable sink for `progress` property
    var progress: _RXCocoa_Binder<Float> {
        return _RXCocoa_Binder(self.base) { progressView, progress in
            progressView.progress = progress
        }
    }

}

#endif
