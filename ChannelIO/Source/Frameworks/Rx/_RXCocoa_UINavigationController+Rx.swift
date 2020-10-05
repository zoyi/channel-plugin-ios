//
//  UINavigationController+Rx.swift
//  RxCocoa
//
//  Created by Diogo on 13/04/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UINavigationController {
    typealias ShowEvent = (viewController: UIViewController, animated: Bool)

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: _RXCocoa_DelegateProxy<UINavigationController, UINavigationControllerDelegate> {
        return _RXCocoa_RxNavigationControllerDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for delegate method `navigationController(:willShow:animated:)`.
    var willShow: _RXCocoa_ControlEvent<ShowEvent> {
        let source: _RXSwift_Observable<ShowEvent> = delegate
            .methodInvoked(#selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:)))
            .map { arg in
                let viewController = try _RXCocoa_castOrThrow(UIViewController.self, arg[1])
                let animated = try _RXCocoa_castOrThrow(Bool.self, arg[2])
                return (viewController, animated)
        }
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `navigationController(:didShow:animated:)`.
    var didShow: _RXCocoa_ControlEvent<ShowEvent> {
        let source: _RXSwift_Observable<ShowEvent> = delegate
            .methodInvoked(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
            .map { arg in
                let viewController = try _RXCocoa_castOrThrow(UIViewController.self, arg[1])
                let animated = try _RXCocoa_castOrThrow(Bool.self, arg[2])
                return (viewController, animated)
        }
        return _RXCocoa_ControlEvent(events: source)
    }
}

#endif
