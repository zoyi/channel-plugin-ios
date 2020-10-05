//
//  RxNavigationControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Diogo on 13/04/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

    import UIKit
//    import RxSwift

    extension UINavigationController: _RXCocoa_HasDelegate {
        typealias Delegate = UINavigationControllerDelegate
    }

    /// For more information take a look at `DelegateProxyType`.
    class _RXCocoa_RxNavigationControllerDelegateProxy
        : _RXCocoa_DelegateProxy<UINavigationController, UINavigationControllerDelegate>
        , _RXCocoa_DelegateProxyType
        , UINavigationControllerDelegate {

        /// Typed parent object.
        weak private(set) var navigationController: UINavigationController?

        /// - parameter navigationController: Parent object for delegate proxy.
        init(navigationController: ParentObject) {
            self.navigationController = navigationController
            super.init(parentObject: navigationController, delegateProxy: _RXCocoa_RxNavigationControllerDelegateProxy.self)
        }

        // Register known implementations
        static func registerKnownImplementations() {
            self.register { _RXCocoa_RxNavigationControllerDelegateProxy(navigationController: $0) }
        }
    }
#endif
