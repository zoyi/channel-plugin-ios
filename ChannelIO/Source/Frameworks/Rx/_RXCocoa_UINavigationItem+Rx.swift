//
//  UINavigationItem+Rx.swift
//  RxCocoa
//
//  Created by kumapo on 2016/05/09.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
import UIKit
//import RxSwift
    
extension _RXSwift_Reactive where Base: UINavigationItem {
    
    /// Bindable sink for `title` property.
    var title: _RXCocoa_Binder<String?> {
        return _RXCocoa_Binder(self.base) { navigationItem, text in
            navigationItem.title = text
        }
    }
        
}
    
#endif
