//
//  UITabBar+Rx.swift
//  RxCocoa
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

/**
 iOS only
 */
#if os(iOS)
extension _RXSwift_Reactive where Base: UITabBar {

    /// Reactive wrapper for `delegate` message `tabBar(_:willBeginCustomizing:)`.
    var willBeginCustomizing: _RXCocoa_ControlEvent<[UITabBarItem]> {
        
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:willBeginCustomizing:)))
            .map { a in
                return try _RXCocoa_castOrThrow([UITabBarItem].self, a[1])
            }

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:didBeginCustomizing:)`.
    var didBeginCustomizing: _RXCocoa_ControlEvent<[UITabBarItem]> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didBeginCustomizing:)))
            .map { a in
                return try _RXCocoa_castOrThrow([UITabBarItem].self, a[1])
            }

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:willEndCustomizing:changed:)`.
    var willEndCustomizing: _RXCocoa_ControlEvent<([UITabBarItem], Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:willEndCustomizing:changed:)))
            .map { (a: [Any]) -> (([UITabBarItem], Bool)) in
                let items = try _RXCocoa_castOrThrow([UITabBarItem].self, a[1])
                let changed = try _RXCocoa_castOrThrow(Bool.self, a[2])
                return (items, changed)
            }

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:didEndCustomizing:changed:)`.
    var didEndCustomizing: _RXCocoa_ControlEvent<([UITabBarItem], Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didEndCustomizing:changed:)))
            .map { (a: [Any]) -> (([UITabBarItem], Bool)) in
                let items = try _RXCocoa_castOrThrow([UITabBarItem].self, a[1])
                let changed = try _RXCocoa_castOrThrow(Bool.self, a[2])
                return (items, changed)
            }

        return _RXCocoa_ControlEvent(events: source)
    }

}
#endif

/**
 iOS and tvOS
 */
    
extension _RXSwift_Reactive where Base: UITabBar {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: _RXCocoa_DelegateProxy<UITabBar, UITabBarDelegate> {
        return _RXCocoa_RxTabBarDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:didSelect:)`.
    var didSelectItem: _RXCocoa_ControlEvent<UITabBarItem> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didSelect:)))
            .map { a in
                return try _RXCocoa_castOrThrow(UITabBarItem.self, a[1])
            }

        return _RXCocoa_ControlEvent(events: source)
    }

}

#endif
