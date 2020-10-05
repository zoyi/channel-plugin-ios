//
//  RxTabBarDelegateProxy.swift
//  RxCocoa
//
//  Created by Jesse Farless on 5/14/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension UITabBar: _RXCocoa_HasDelegate {
    typealias Delegate = UITabBarDelegate
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxTabBarDelegateProxy
    : _RXCocoa_DelegateProxy<UITabBar, UITabBarDelegate>
    , _RXCocoa_DelegateProxyType
    , UITabBarDelegate {

    /// Typed parent object.
    weak private(set) var tabBar: UITabBar?

    /// - parameter tabBar: Parent object for delegate proxy.
    init(tabBar: ParentObject) {
        self.tabBar = tabBar
        super.init(parentObject: tabBar, delegateProxy: _RXCocoa_RxTabBarDelegateProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxTabBarDelegateProxy(tabBar: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    class func currentDelegate(for object: ParentObject) -> UITabBarDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    class func setCurrentDelegate(_ delegate: UITabBarDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }
}

#endif
