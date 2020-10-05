
//  RxScrollViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit
    
extension UIScrollView: _RXCocoa_HasDelegate {
    typealias Delegate = UIScrollViewDelegate
}

/// For more information take a look at `DelegateProxyType`.
class _RXCocoa_RxScrollViewDelegateProxy
    : _RXCocoa_DelegateProxy<UIScrollView, UIScrollViewDelegate>
    , _RXCocoa_DelegateProxyType
    , UIScrollViewDelegate {

    /// Typed parent object.
    weak private(set) var scrollView: UIScrollView?

    /// - parameter scrollView: Parent object for delegate proxy.
    init(scrollView: ParentObject) {
        self.scrollView = scrollView
        super.init(parentObject: scrollView, delegateProxy: _RXCocoa_RxScrollViewDelegateProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxScrollViewDelegateProxy(scrollView: $0) }
        self.register { _RXCocoa_RxTableViewDelegateProxy(tableView: $0) }
        self.register { _RXCocoa_RxCollectionViewDelegateProxy(collectionView: $0) }
        self.register { _RXCocoa_RxTextViewDelegateProxy(textView: $0) }
    }

    private var _contentOffsetBehaviorSubject: _RXSwift_BehaviorSubject<CGPoint>?
    private var _contentOffsetPublishSubject: _RXSwift_PublishSubject<()>?

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetBehaviorSubject: _RXSwift_BehaviorSubject<CGPoint> {
        if let subject = _contentOffsetBehaviorSubject {
            return subject
        }

        let subject = _RXSwift_BehaviorSubject<CGPoint>(value: self.scrollView?.contentOffset ?? CGPoint.zero)
        _contentOffsetBehaviorSubject = subject

        return subject
    }

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetPublishSubject: _RXSwift_PublishSubject<()> {
        if let subject = _contentOffsetPublishSubject {
            return subject
        }

        let subject = _RXSwift_PublishSubject<()>()
        _contentOffsetPublishSubject = subject

        return subject
    }
    
    // MARK: delegate methods

    /// For more information take a look at `DelegateProxyType`.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.next(scrollView.contentOffset))
        }
        if let subject = _contentOffsetPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    deinit {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.completed)
        }

        if let subject = _contentOffsetPublishSubject {
            subject.on(.completed)
        }
    }
}

#endif
