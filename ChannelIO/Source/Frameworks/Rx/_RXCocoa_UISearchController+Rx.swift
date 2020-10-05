//
//  UISearchController+Rx.swift
//  RxCocoa
//
//  Created by Segii Shulga on 3/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
//    import RxSwift
    import UIKit
    
    @available(iOS 8.0, *)
    extension _RXSwift_Reactive where Base: UISearchController {
        /// Reactive wrapper for `delegate`.
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        var delegate: _RXCocoa_DelegateProxy<UISearchController, UISearchControllerDelegate> {
            return _RXCocoa_RxSearchControllerDelegateProxy.proxy(for: base)
        }

        /// Reactive wrapper for `delegate` message.
        var didDismiss: _RXSwift_Observable<Void> {
            return delegate
                .methodInvoked( #selector(UISearchControllerDelegate.didDismissSearchController(_:)))
                .map { _ in }
        }

        /// Reactive wrapper for `delegate` message.
        var didPresent: _RXSwift_Observable<Void> {
            return delegate
                .methodInvoked(#selector(UISearchControllerDelegate.didPresentSearchController(_:)))
                .map { _ in }
        }

        /// Reactive wrapper for `delegate` message.
        var present: _RXSwift_Observable<Void> {
            return delegate
                .methodInvoked( #selector(UISearchControllerDelegate.presentSearchController(_:)))
                .map { _ in }
        }

        /// Reactive wrapper for `delegate` message.
        var willDismiss: _RXSwift_Observable<Void> {
            return delegate
                .methodInvoked(#selector(UISearchControllerDelegate.willDismissSearchController(_:)))
                .map { _ in }
        }
        
        /// Reactive wrapper for `delegate` message.
        var willPresent: _RXSwift_Observable<Void> {
            return delegate
                .methodInvoked( #selector(UISearchControllerDelegate.willPresentSearchController(_:)))
                .map { _ in }
        }
        
    }
    
#endif
