//
//  UITabBarController+Rx.swift
//  RxCocoa
//
//  Created by Yusuke Kita on 2016/12/07.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift
    
/**
 iOS only
 */
#if os(iOS)
extension _RXSwift_Reactive where Base: UITabBarController {
    
    /// Reactive wrapper for `delegate` message `tabBarController:willBeginCustomizing:`.
    var willBeginCustomizing: _RXCocoa_ControlEvent<[UIViewController]> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:willBeginCustomizing:)))
            .map { a in
                return try _RXCocoa_castOrThrow([UIViewController].self, a[1])
        }
        
        return _RXCocoa_ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `tabBarController:willEndCustomizing:changed:`.
    var willEndCustomizing: _RXCocoa_ControlEvent<(viewControllers: [UIViewController], changed: Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:willEndCustomizing:changed:)))
            .map { (a: [Any]) -> (viewControllers: [UIViewController], changed: Bool) in
                let viewControllers = try _RXCocoa_castOrThrow([UIViewController].self, a[1])
                let changed = try _RXCocoa_castOrThrow(Bool.self, a[2])
                return (viewControllers, changed)
        }
        
        return _RXCocoa_ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `tabBarController:didEndCustomizing:changed:`.
    var didEndCustomizing: _RXCocoa_ControlEvent<(viewControllers: [UIViewController], changed: Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:didEndCustomizing:changed:)))
            .map { (a: [Any]) -> (viewControllers: [UIViewController], changed: Bool) in
                let viewControllers = try _RXCocoa_castOrThrow([UIViewController].self, a[1])
                let changed = try _RXCocoa_castOrThrow(Bool.self, a[2])
                return (viewControllers, changed)
        }
        
        return _RXCocoa_ControlEvent(events: source)
    }
}
#endif
    
/**
 iOS and tvOS
 */

    extension _RXSwift_Reactive where Base: UITabBarController {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: _RXCocoa_DelegateProxy<UITabBarController, UITabBarControllerDelegate> {
        return _RXCocoa_RxTabBarControllerDelegateProxy.proxy(for: base)
    }
    
    /// Reactive wrapper for `delegate` message `tabBarController:didSelect:`.
    var didSelect: _RXCocoa_ControlEvent<UIViewController> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:didSelect:)))
            .map { a in
                return try _RXCocoa_castOrThrow(UIViewController.self, a[1])
        }
        
        return _RXCocoa_ControlEvent(events: source)
    }
}

#endif
