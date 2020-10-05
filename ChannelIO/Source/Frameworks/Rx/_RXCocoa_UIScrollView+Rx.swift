//
//  UIScrollView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//    import RxSwift
    import UIKit

    extension _RXSwift_Reactive where Base: UIScrollView {
        typealias EndZoomEvent = (view: UIView?, scale: CGFloat)
        typealias WillEndDraggingEvent = (velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)

        /// Reactive wrapper for `delegate`.
        ///
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        var delegate: _RXCocoa_DelegateProxy<UIScrollView, UIScrollViewDelegate> {
            return _RXCocoa_RxScrollViewDelegateProxy.proxy(for: base)
        }
        
        /// Reactive wrapper for `contentOffset`.
        var contentOffset: _RXCocoa_ControlProperty<CGPoint> {
            let proxy = _RXCocoa_RxScrollViewDelegateProxy.proxy(for: base)

            let bindingObserver = _RXCocoa_Binder(self.base) { scrollView, contentOffset in
                scrollView.contentOffset = contentOffset
            }

            return _RXCocoa_ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
        }

        /// Bindable sink for `scrollEnabled` property.
        var isScrollEnabled: _RXCocoa_Binder<Bool> {
            return _RXCocoa_Binder(self.base) { scrollView, scrollEnabled in
                scrollView.isScrollEnabled = scrollEnabled
            }
        }

        /// Reactive wrapper for delegate method `scrollViewDidScroll`
        var didScroll: _RXCocoa_ControlEvent<Void> {
            let source = _RXCocoa_RxScrollViewDelegateProxy.proxy(for: base).contentOffsetPublishSubject
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /// Reactive wrapper for delegate method `scrollViewWillBeginDecelerating`
        var willBeginDecelerating: _RXCocoa_ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:))).map { _ in }
            return _RXCocoa_ControlEvent(events: source)
        }
    	
    	/// Reactive wrapper for delegate method `scrollViewDidEndDecelerating`
    	var didEndDecelerating: _RXCocoa_ControlEvent<Void> {
    		let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))).map { _ in }
    		return _RXCocoa_ControlEvent(events: source)
    	}
    	
        /// Reactive wrapper for delegate method `scrollViewWillBeginDragging`
        var willBeginDragging: _RXCocoa_ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:))).map { _ in }
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /// Reactive wrapper for delegate method `scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)`
        var willEndDragging: _RXCocoa_ControlEvent<WillEndDraggingEvent> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)))
                .map { value -> WillEndDraggingEvent in
                    let velocity = try _RXCocoa_castOrThrow(CGPoint.self, value[1])
                    let targetContentOffsetValue = try _RXCocoa_castOrThrow(NSValue.self, value[2])

                    guard let rawPointer = targetContentOffsetValue.pointerValue else { throw _RXCocoa_RxCocoaError.unknown }
                    let typedPointer = rawPointer.bindMemory(to: CGPoint.self, capacity: MemoryLayout<CGPoint>.size)

                    return (velocity, typedPointer)
            }
            return _RXCocoa_ControlEvent(events: source)
        }
        
    	/// Reactive wrapper for delegate method `scrollViewDidEndDragging(_:willDecelerate:)`
        var didEndDragging: _RXCocoa_ControlEvent<Bool> {
    		let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))).map { value -> Bool in
    			return try _RXCocoa_castOrThrow(Bool.self, value[1])
    		}
    		return _RXCocoa_ControlEvent(events: source)
    	}

        /// Reactive wrapper for delegate method `scrollViewDidZoom`
        var didZoom: _RXCocoa_ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidZoom)).map { _ in }
            return _RXCocoa_ControlEvent(events: source)
        }


        /// Reactive wrapper for delegate method `scrollViewDidScrollToTop`
        var didScrollToTop: _RXCocoa_ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:))).map { _ in }
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /// Reactive wrapper for delegate method `scrollViewDidEndScrollingAnimation`
        var didEndScrollingAnimation: _RXCocoa_ControlEvent<Void> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))).map { _ in }
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /// Reactive wrapper for delegate method `scrollViewWillBeginZooming(_:with:)`
        var willBeginZooming: _RXCocoa_ControlEvent<UIView?> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:with:))).map { value -> UIView? in
                return try _RXCocoa_castOptionalOrThrow(UIView.self, value[1] as AnyObject)
            }
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /// Reactive wrapper for delegate method `scrollViewDidEndZooming(_:with:atScale:)`
        var didEndZooming: _RXCocoa_ControlEvent<EndZoomEvent> {
            let source = delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))).map { value -> EndZoomEvent in
                return (try _RXCocoa_castOptionalOrThrow(UIView.self, value[1] as AnyObject), try _RXCocoa_castOrThrow(CGFloat.self, value[2]))
            }
            return _RXCocoa_ControlEvent(events: source)
        }

        /// Installs delegate as forwarding delegate on `delegate`.
        /// Delegate won't be retained.
        ///
        /// It enables using normal delegate mechanism with reactive delegate mechanism.
        ///
        /// - parameter delegate: Delegate object.
        /// - returns: Disposable object that can be used to unbind the delegate.
        func setDelegate(_ delegate: UIScrollViewDelegate)
            -> _RXSwift_Disposable {
            return _RXCocoa_RxScrollViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
        }
    }

#endif
