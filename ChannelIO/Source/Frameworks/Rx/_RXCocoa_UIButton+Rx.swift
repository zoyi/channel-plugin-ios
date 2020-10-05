//
//  UIButton+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UIButton {
    
    /// Reactive wrapper for `TouchUpInside` control event.
    var tap: _RXCocoa_ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}

#endif

#if os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UIButton {

    /// Reactive wrapper for `PrimaryActionTriggered` control event.
    var primaryAction: _RXCocoa_ControlEvent<Void> {
        return controlEvent(.primaryActionTriggered)
    }

}

#endif

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UIButton {
    
    /// Reactive wrapper for `setTitle(_:for:)`
    func title(for controlState: UIControl.State = []) -> _RXCocoa_Binder<String?> {
        return _RXCocoa_Binder(self.base) { button, title -> Void in
            button.setTitle(title, for: controlState)
        }
    }

    /// Reactive wrapper for `setImage(_:for:)`
    func image(for controlState: UIControl.State = []) -> _RXCocoa_Binder<UIImage?> {
        return _RXCocoa_Binder(self.base) { button, image -> Void in
            button.setImage(image, for: controlState)
        }
    }

    /// Reactive wrapper for `setBackgroundImage(_:for:)`
    func backgroundImage(for controlState: UIControl.State = []) -> _RXCocoa_Binder<UIImage?> {
        return _RXCocoa_Binder(self.base) { button, image -> Void in
            button.setBackgroundImage(image, for: controlState)
        }
    }
    
}
#endif

#if os(iOS) || os(tvOS)

//    import RxSwift
    import UIKit
    
    extension _RXSwift_Reactive where Base: UIButton {
        
        /// Reactive wrapper for `setAttributedTitle(_:controlState:)`
        func attributedTitle(for controlState: UIControl.State = []) -> _RXCocoa_Binder<NSAttributedString?> {
            return _RXCocoa_Binder(self.base) { button, attributedTitle -> Void in
                button.setAttributedTitle(attributedTitle, for: controlState)
            }
        }
        
    }
#endif
