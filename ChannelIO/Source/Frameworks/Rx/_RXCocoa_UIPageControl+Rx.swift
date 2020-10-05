//
//  UIPageControl+Rx.swift
//  RxCocoa
//
//  Created by Francesco Puntillo on 14/04/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit
    
extension _RXSwift_Reactive where Base: UIPageControl {
    
    /// Bindable sink for `currentPage` property.
    var currentPage: _RXCocoa_Binder<Int> {
        return _RXCocoa_Binder(self.base) { controller, page in
            controller.currentPage = page
        }
    }
    
    /// Bindable sink for `numberOfPages` property.
    var numberOfPages: _RXCocoa_Binder<Int> {
        return _RXCocoa_Binder(self.base) { controller, page in
            controller.numberOfPages = page
        }
    }
    
}
    
#endif
