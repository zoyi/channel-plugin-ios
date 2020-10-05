//
//  UIViewController+Rx.swift
//  RxCocoa
//
//  Created by Kyle Fuller on 27/05/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

    import UIKit
//    import RxSwift

    extension _RXSwift_Reactive where Base: UIViewController {

        /// Bindable sink for `title`.
        var title: _RXCocoa_Binder<String> {
            return _RXCocoa_Binder(self.base) { viewController, title in
                viewController.title = title
            }
        }
    
    }
#endif
