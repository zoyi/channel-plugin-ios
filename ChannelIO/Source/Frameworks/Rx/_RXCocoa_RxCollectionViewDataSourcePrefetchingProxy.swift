//
//  RxCollectionViewDataSourcePrefetchingProxy.swift
//  RxCocoa
//
//  Created by Rowan Livingstone on 2/15/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

@available(iOS 10.0, tvOS 10.0, *)
extension UICollectionView: _RXCocoa_HasPrefetchDataSource {
    typealias PrefetchDataSource = UICollectionViewDataSourcePrefetching
}

@available(iOS 10.0, tvOS 10.0, *)
private let collectionViewPrefetchDataSourceNotSet = CollectionViewPrefetchDataSourceNotSet()

@available(iOS 10.0, tvOS 10.0, *)
private final class CollectionViewPrefetchDataSourceNotSet
    : NSObject
    , UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}

}

@available(iOS 10.0, tvOS 10.0, *)
class _RXCocoa_RxCollectionViewDataSourcePrefetchingProxy
    : _RXCocoa_DelegateProxy<UICollectionView, UICollectionViewDataSourcePrefetching>
    , _RXCocoa_DelegateProxyType
    , UICollectionViewDataSourcePrefetching {

    /// Typed parent object.
    weak private(set) var collectionView: UICollectionView?

    /// - parameter collectionView: Parent object for delegate proxy.
    init(collectionView: ParentObject) {
        self.collectionView = collectionView
        super.init(parentObject: collectionView, delegateProxy: _RXCocoa_RxCollectionViewDataSourcePrefetchingProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxCollectionViewDataSourcePrefetchingProxy(collectionView: $0) }
    }

    private var _prefetchItemsPublishSubject: _RXSwift_PublishSubject<[IndexPath]>?

    /// Optimized version used for observing prefetch items callbacks.
    internal var prefetchItemsPublishSubject: _RXSwift_PublishSubject<[IndexPath]> {
        if let subject = _prefetchItemsPublishSubject {
            return subject
        }

        let subject = _RXSwift_PublishSubject<[IndexPath]>()
        _prefetchItemsPublishSubject = subject

        return subject
    }

    private weak var _requiredMethodsPrefetchDataSource: UICollectionViewDataSourcePrefetching? = collectionViewPrefetchDataSourceNotSet

    // MARK: delegate

    /// Required delegate method implementation.
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let subject = _prefetchItemsPublishSubject {
            subject.on(.next(indexPaths))
        }

        (_requiredMethodsPrefetchDataSource ?? collectionViewPrefetchDataSourceNotSet).collectionView(collectionView, prefetchItemsAt: indexPaths)
    }

    /// For more information take a look at `DelegateProxyType`.
    override func setForwardToDelegate(_ forwardToDelegate: UICollectionViewDataSourcePrefetching?, retainDelegate: Bool) {
        _requiredMethodsPrefetchDataSource = forwardToDelegate ?? collectionViewPrefetchDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }

    deinit {
        if let subject = _prefetchItemsPublishSubject {
            subject.on(.completed)
        }
    }

}

#endif
