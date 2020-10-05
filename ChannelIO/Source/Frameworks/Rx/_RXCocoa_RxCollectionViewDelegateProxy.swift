//
//  RxCollectionViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxCollectionViewDelegateProxy
    : _RXCocoa_RxScrollViewDelegateProxy
    , UICollectionViewDelegate
    , UICollectionViewDelegateFlowLayout {

    /// Typed parent object.
    weak private(set) var collectionView: UICollectionView?

    /// Initializes `RxCollectionViewDelegateProxy`
    ///
    /// - parameter collectionView: Parent object for delegate proxy.
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init(scrollView: collectionView)
    }
}

#endif
