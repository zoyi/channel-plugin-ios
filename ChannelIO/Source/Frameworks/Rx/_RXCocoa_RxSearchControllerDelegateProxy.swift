//
//  RxSearchControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 3/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

//import RxSwift
import UIKit

extension UISearchController: _RXCocoa_HasDelegate {
    typealias Delegate = UISearchControllerDelegate
}

/// For more information take a look at `DelegateProxyType`.
@available(iOS 8.0, *)
class _RXCocoa_RxSearchControllerDelegateProxy
    : _RXCocoa_DelegateProxy<UISearchController, UISearchControllerDelegate>
    , _RXCocoa_DelegateProxyType
    , UISearchControllerDelegate {

    /// Typed parent object.
    weak private(set) var searchController: UISearchController?

    /// - parameter searchController: Parent object for delegate proxy.
    init(searchController: UISearchController) {
        self.searchController = searchController
        super.init(parentObject: searchController, delegateProxy: _RXCocoa_RxSearchControllerDelegateProxy.self)
    }
    
    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxSearchControllerDelegateProxy(searchController: $0) }
    }
}
   
#endif
