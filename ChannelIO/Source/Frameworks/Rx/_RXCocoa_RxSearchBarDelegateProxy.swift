//
//  RxSearchBarDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension UISearchBar: _RXCocoa_HasDelegate {
    typealias Delegate = UISearchBarDelegate
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxSearchBarDelegateProxy
    : _RXCocoa_DelegateProxy<UISearchBar, UISearchBarDelegate>
    , _RXCocoa_DelegateProxyType
    , UISearchBarDelegate {

    /// Typed parent object.
    weak private(set) var searchBar: UISearchBar?

    /// - parameter searchBar: Parent object for delegate proxy.
    init(searchBar: ParentObject) {
        self.searchBar = searchBar
        super.init(parentObject: searchBar, delegateProxy: _RXCocoa_RxSearchBarDelegateProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxSearchBarDelegateProxy(searchBar: $0) }
    }
}

#endif
