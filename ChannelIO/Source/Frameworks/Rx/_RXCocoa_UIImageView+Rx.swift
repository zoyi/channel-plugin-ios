//
//  UIImageView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UIImageView {
    
    /// Bindable sink for `image` property.
    var image: _RXCocoa_Binder<UIImage?> {
        return _RXCocoa_Binder(base) { imageView, image in
            imageView.image = image
        }
    }
}

#endif
