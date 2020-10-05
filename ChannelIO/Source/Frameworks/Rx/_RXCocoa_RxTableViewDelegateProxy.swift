//
//  RxTableViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxTableViewDelegateProxy
    : _RXCocoa_RxScrollViewDelegateProxy
    , UITableViewDelegate {

    /// Typed parent object.
    weak private(set) var tableView: UITableView?

    /// - parameter tableView: Parent object for delegate proxy.
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(scrollView: tableView)
    }

}

#endif
