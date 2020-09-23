//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift
    
extension UITableView: _RXCocoa_HasDataSource {
    typealias DataSource = UITableViewDataSource
}

private let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

private final class TableViewDataSourceNotSet
    : NSObject
    , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        _RXCocoa_rxAbstractMethod(message: _RXCocoa_dataSourceNotSet)
    }
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxTableViewDataSourceProxy
    : _RXCocoa_DelegateProxy<UITableView, UITableViewDataSource>
    , _RXCocoa_DelegateProxyType
    , UITableViewDataSource {

    /// Typed parent object.
    weak private(set) var tableView: UITableView?

    /// - parameter tableView: Parent object for delegate proxy.
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(parentObject: tableView, delegateProxy: _RXCocoa_RxTableViewDataSourceProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxTableViewDataSourceProxy(tableView: $0) }
    }

    private weak var _requiredMethodsDataSource: UITableViewDataSource? = tableViewDataSourceNotSet

    // MARK: delegate

    /// Required delegate method implementation.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }

    /// Required delegate method implementation.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView(tableView, cellForRowAt: indexPath)
    }

    /// For more information take a look at `DelegateProxyType`.
    override func setForwardToDelegate(_ forwardToDelegate: UITableViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate  ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

}

#endif
