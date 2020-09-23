//
//  RxCollectionViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension UICollectionView: _RXCocoa_HasDataSource {
    typealias DataSource = UICollectionViewDataSource
}

private let collectionViewDataSourceNotSet = CollectionViewDataSourceNotSet()

private final class CollectionViewDataSourceNotSet
    : NSObject
    , UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        _RXCocoa_rxAbstractMethod(message: _RXCocoa_dataSourceNotSet)
    }
    
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxCollectionViewDataSourceProxy
    : _RXCocoa_DelegateProxy<UICollectionView, UICollectionViewDataSource>
    , _RXCocoa_DelegateProxyType
    , UICollectionViewDataSource {

    /// Typed parent object.
    weak private(set) var collectionView: UICollectionView?

    /// - parameter collectionView: Parent object for delegate proxy.
    init(collectionView: ParentObject) {
        self.collectionView = collectionView
        super.init(parentObject: collectionView, delegateProxy: _RXCocoa_RxCollectionViewDataSourceProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxCollectionViewDataSourceProxy(collectionView: $0) }
    }

    private weak var _requiredMethodsDataSource: UICollectionViewDataSource? = collectionViewDataSourceNotSet

    // MARK: delegate

    /// Required delegate method implementation.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? collectionViewDataSourceNotSet).collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    /// Required delegate method implementation.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (_requiredMethodsDataSource ?? collectionViewDataSourceNotSet).collectionView(collectionView, cellForItemAt: indexPath)
    }

    /// For more information take a look at `DelegateProxyType`.
    override func setForwardToDelegate(_ forwardToDelegate: UICollectionViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? collectionViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}

#endif
