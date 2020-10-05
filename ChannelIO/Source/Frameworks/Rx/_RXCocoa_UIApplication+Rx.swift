//
//  UIApplication+Rx.swift
//  RxCocoa
//
//  Created by Mads Bøgeskov on 18/01/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

    import UIKit
//    import RxSwift

    extension _RXSwift_Reactive where Base: UIApplication {
        
        /// Bindable sink for `networkActivityIndicatorVisible`.
        var isNetworkActivityIndicatorVisible: _RXCocoa_Binder<Bool> {
            return _RXCocoa_Binder(self.base) { application, active in
                application.isNetworkActivityIndicatorVisible = active
            }
        }
    }
#endif

