//
//  RxTabBarControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Yusuke Kita on 2016/12/07.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension UITabBarController: _RXCocoa_HasDelegate {
    typealias Delegate = UITabBarControllerDelegate
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxTabBarControllerDelegateProxy
    : _RXCocoa_DelegateProxy<UITabBarController, UITabBarControllerDelegate>
    , _RXCocoa_DelegateProxyType
    , UITabBarControllerDelegate {

    /// Typed parent object.
    weak private(set) var tabBar: UITabBarController?

    /// - parameter tabBar: Parent object for delegate proxy.
    init(tabBar: ParentObject) {
        self.tabBar = tabBar
        super.init(parentObject: tabBar, delegateProxy: _RXCocoa_RxTabBarControllerDelegateProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxTabBarControllerDelegateProxy(tabBar: $0) }
    }
}

#endif
