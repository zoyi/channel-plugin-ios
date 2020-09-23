//
//  UILabel+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UILabel {
    
    /// Bindable sink for `text` property.
    var text: _RXCocoa_Binder<String?> {
        return _RXCocoa_Binder(self.base) { label, text in
            label.text = text
        }
    }

    /// Bindable sink for `attributedText` property.
    var attributedText: _RXCocoa_Binder<NSAttributedString?> {
        return _RXCocoa_Binder(self.base) { label, text in
            label.attributedText = text
        }
    }
    
}

#endif
