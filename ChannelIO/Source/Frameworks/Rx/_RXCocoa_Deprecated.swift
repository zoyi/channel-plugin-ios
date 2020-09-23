//
//  Deprecated.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift
import Dispatch
import Foundation

extension _RXSwift_ObservableType {

    /**
     Creates new subscription and sends elements to observer.

     In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
     writing more consistent binding code.

     - parameter observer: Observer that receives events.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    func bindTo<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        return self.subscribe(observer)
    }

    /**
     Creates new subscription and sends elements to observer.

     In this form it's equivalent to `subscribe` method, but it communicates intent better, and enables
     writing more consistent binding code.

     - parameter observer: Observer that receives events.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    func bindTo<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element? {
        return self.map { $0 }.subscribe(observer)
    }

    /**
     Creates new subscription and sends elements to variable.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter variable: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    func bindTo(_ variable: _RXCocoa_Variable<Element>) -> _RXSwift_Disposable {
        return self.subscribe { e in
            switch e {
            case let .next(element):
                variable.value = element
            case let .error(error):
                let error = "Binding error to variable: \(error)"
                #if DEBUG
                    _RXCocoa_rxFatalError(error)
                #else
                    print(error)
                #endif
            case .completed:
                break
            }
        }
    }

    /**
     Creates new subscription and sends elements to variable.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter variable: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    func bindTo(_ variable: _RXCocoa_Variable<Element?>) -> _RXSwift_Disposable {
        return self.map { $0 as Element? }.bindTo(variable)
    }

    /**
     Subscribes to observable sequence using custom binder function.

     - parameter binder: Function used to bind elements from `self`.
     - returns: Object representing subscription.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    func bindTo<Result>(_ binder: (Self) -> Result) -> Result {
        return binder(self)
    }

    /**
     Subscribes to observable sequence using custom binder function and final parameter passed to binder function
     after `self` is passed.

     func bindTo<R1, R2>(binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
     return binder(self)(curriedArgument)
     }

     - parameter binder: Function used to bind elements from `self`.
     - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
     - returns: Object representing subscription.
     */
    @available(*, deprecated, renamed: "bind(to:)")
    func bindTo<R1, R2>(_ binder: (Self) -> (R1) -> R2, curriedArgument: R1) -> R2 {
        return binder(self)(curriedArgument)
    }


    /**
     Subscribes an element handler to an observable sequence.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    @available(*, deprecated, renamed: "bind(onNext:)")
    func bindNext(_ onNext: @escaping (Element) -> Void) -> _RXSwift_Disposable {
        return self.subscribe(onNext: onNext, onError: { error in
            let error = "Binding error: \(error)"
            #if DEBUG
                _RXCocoa_rxFatalError(error)
            #else
                print(error)
            #endif
        })
    }
}

#if os(iOS) || os(tvOS)
    import UIKit

    extension NSTextStorage {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxTextStorageDelegateProxy {
            fatalError()
        }
    }

    extension UIScrollView {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxScrollViewDelegateProxy {
            fatalError()
        }
    }

    extension UICollectionView {
        @available(*, unavailable, message: "createRxDataSourceProxy is now unavailable, check DelegateProxyFactory")
        func createRxDataSourceProxy() -> _RXCocoa_RxCollectionViewDataSourceProxy {
            fatalError()
        }
    }

    extension UITableView {
        @available(*, unavailable, message: "createRxDataSourceProxy is now unavailable, check DelegateProxyFactory")
        func createRxDataSourceProxy() -> _RXCocoa_RxTableViewDataSourceProxy {
            fatalError()
        }
    }

    extension UINavigationBar {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxNavigationControllerDelegateProxy {
            fatalError()
        }
    }

    extension UINavigationController {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxNavigationControllerDelegateProxy {
            fatalError()
        }
    }

    extension UITabBar {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxTabBarDelegateProxy {
            fatalError()
        }
    }

    extension UITabBarController {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxTabBarControllerDelegateProxy {
            fatalError()
        }
    }

    extension UISearchBar {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxSearchBarDelegateProxy {
            fatalError()
        }
    }

#endif

#if os(iOS)
    extension UISearchController {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxSearchControllerDelegateProxy {
            fatalError()
        }
    }

    extension UIPickerView {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> _RXCocoa_RxPickerViewDelegateProxy {
            fatalError()
        }

        @available(*, unavailable, message: "createRxDataSourceProxy is now unavailable, check DelegateProxyFactory")
        func createRxDataSourceProxy() -> _RXCocoa_RxPickerViewDataSourceProxy {
            fatalError()
        }
    }
#endif

#if os(macOS)
    import Cocoa

    extension NSTextField {
        @available(*, unavailable, message: "createRxDelegateProxy is now unavailable, check DelegateProxyFactory")
        func createRxDelegateProxy() -> RxTextFieldDelegateProxy {
            fatalError()
        }
    }
#endif

/**
 This method can be used in unit tests to ensure that driver is using mock schedulers instead of
 main schedulers.

 **This shouldn't be used in normal release builds.**
 */
@available(*, deprecated, renamed: "SharingScheduler.mock(scheduler:action:)")
func _RXCocoa_driveOnScheduler(_ scheduler: _RXSwift_SchedulerType, action: () -> Void) {
    _RXCocoa_SharingScheduler.mock(scheduler: scheduler, action: action)
}

@available(*, deprecated, message: "Variable is deprecated. Please use `BehaviorRelay` as a replacement.")
extension _RXCocoa_Variable {
    /// Converts `Variable` to `SharedSequence` unit.
    ///
    /// - returns: Observable sequence.
    @available(*, deprecated, renamed: "asDriver()")
    func asSharedSequence<SharingStrategy: _RXSwift_SharingStrategyProtocol>(strategy: SharingStrategy.Type = SharingStrategy.self) -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        let source = self.asObservable()
            .observeOn(SharingStrategy.scheduler)
        return _RXSwift_SharedSequence(source)
    }
}

#if !os(Linux)

extension _RXCocoa_DelegateProxy {
    @available(*, unavailable, renamed: "assignedProxy(for:)")
    static func assignedProxyFor(_ object: ParentObject) -> Delegate? {
        fatalError()
    }
    
    @available(*, unavailable, renamed: "currentDelegate(for:)")
    static func currentDelegateFor(_ object: ParentObject) -> Delegate? {
        fatalError()
    }
}

#endif

/**
Observer that enforces interface binding rules:
 * can't bind errors (in debug builds binding of errors causes `fatalError` in release builds errors are being logged)
 * ensures binding is performed on main thread
 
`UIBindingObserver` doesn't retain target interface and in case owned interface element is released, element isn't bound.
 
 In case event binding is attempted from non main dispatch queue, event binding will be dispatched async to main dispatch
 queue.
*/
@available(*, deprecated, renamed: "Binder")
final class _RXCocoa_UIBindingObserver<UIElement, Value> : _RXSwift_ObserverType where UIElement: AnyObject {
    typealias Element = Value

    weak var UIElement: UIElement?

    let binding: (UIElement, Value) -> Void

    /// Initializes `ViewBindingObserver` using
    @available(*, deprecated, renamed: "UIBinder.init(_:scheduler:binding:)")
    init(UIElement: UIElement, binding: @escaping (UIElement, Value) -> Void) {
        self.UIElement = UIElement
        self.binding = binding
    }

    /// Binds next element to owner view as described in `binding`.
    func on(_ event: _RXSwift_Event<Value>) {
        if !DispatchQueue._RXPlatform_isMain {
            DispatchQueue.main.async {
                self.on(event)
            }
            return
        }

        switch event {
        case .next(let element):
            if let view = self.UIElement {
                self.binding(view, element)
            }
        case .error(let error):
            _RXCocoa_bindingError(error)
        case .completed:
            break
        }
    }

    /// Erases type of observer.
    ///
    /// - returns: type erased observer.
    func asObserver() -> _RXSwift_AnyObserver<Value> {
        return _RXSwift_AnyObserver(eventHandler: self.on)
    }
}


#if os(iOS)
    extension _RXSwift_Reactive where Base: UIRefreshControl {

        /// Bindable sink for `beginRefreshing()`, `endRefreshing()` methods.
        @available(*, deprecated, renamed: "isRefreshing")
        var refreshing: _RXCocoa_Binder<Bool> {
            return self.isRefreshing
        }
    }
#endif

#if os(iOS) || os(tvOS)
extension _RXSwift_Reactive where Base: UIImageView {

    /// Bindable sink for `image` property.
    /// - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    @available(*, deprecated, renamed: "image")
    func image(transitionType: String? = nil) -> _RXCocoa_Binder<UIImage?> {
        return _RXCocoa_Binder(base) { imageView, image in
            if let transitionType = transitionType {
                if image != nil {
                    let transition = CATransition()
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    transition.type = CATransitionType(rawValue: transitionType)

                    imageView.layer.add(transition, forKey: kCATransition)
                }
            }
            else {
                imageView.layer.removeAllAnimations()
            }
            imageView.image = image
        }
    }
}
    
extension _RXSwift_Reactive where Base: UISegmentedControl {
    @available(*, deprecated, renamed: "enabledForSegment(at:)")
    func enabled(forSegmentAt segmentAt: Int) -> _RXCocoa_Binder<Bool> {
        return enabledForSegment(at: segmentAt)
    }
}
#endif

#if os(macOS)

    extension _RXSwift_Reactive where Base: NSImageView {

        /// Bindable sink for `image` property.
        ///
        /// - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
        @available(*, deprecated, renamed: "image")
        func image(transitionType: String? = nil) -> Binder<NSImage?> {
            return Binder(self.base) { control, value in
                if let transitionType = transitionType {
                    if value != nil {
                        let transition = CATransition()
                        transition.duration = 0.25
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType(rawValue: transitionType)
                        control.layer?.add(transition, forKey: kCATransition)
                    }
                }
                else {
                    control.layer?.removeAllAnimations()
                }
                control.image = value
            }
        }
    }
#endif

@available(*, deprecated, message: "Variable is deprecated. Please use `BehaviorRelay` as a replacement.")
extension _RXCocoa_Variable {
    /// Converts `Variable` to `Driver` trait.
    ///
    /// - returns: Driving observable sequence.
    func asDriver() -> _RXCocoa_Driver<Element> {
        let source = self.asObservable()
            .observeOn(_RXCocoa_DriverSharingStrategy.scheduler)
        return _RXCocoa_Driver(source)
    }
}


private let errorMessage = "`drive*` family of methods can be only called from `MainThread`.\n" +
"This is required to ensure that the last replayed `Driver` element is delivered on `MainThread`.\n"

extension _RXSwift_SharedSequenceConvertibleType where SharingStrategy == _RXCocoa_DriverSharingStrategy {
    /**
     Creates new subscription and sends elements to variable.
     This method can be only called from `MainThread`.

     - parameter variable: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer from the variable.
     */
    @available(*, deprecated, message: "Variable is deprecated. Please use `BehaviorRelay` as a replacement.")
    func drive(_ variable: _RXCocoa_Variable<Element>) -> _RXSwift_Disposable {
        _RXSwift_MainScheduler.ensureRunningOnMainThread(errorMessage: errorMessage)
        return self.drive(onNext: { e in
            variable.value = e
        })
    }

    /**
     Creates new subscription and sends elements to variable.
     This method can be only called from `MainThread`.

     - parameter variable: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer from the variable.
     */
    @available(*, deprecated, message: "Variable is deprecated. Please use `BehaviorRelay` as a replacement.")
    func drive(_ variable: _RXCocoa_Variable<Element?>) -> _RXSwift_Disposable {
        _RXSwift_MainScheduler.ensureRunningOnMainThread(errorMessage: errorMessage)
        return self.drive(onNext: { e in
            variable.value = e
        })
    }
}

@available(*, deprecated, message: "Variable is deprecated. Please use `BehaviorRelay` as a replacement.")
extension _RXSwift_ObservableType {
    /**
     Creates new subscription and sends elements to variable.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter to: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    func bind(to variable: _RXCocoa_Variable<Element>) -> _RXSwift_Disposable {
        return self.subscribe { e in
            switch e {
            case let .next(element):
                variable.value = element
            case let .error(error):
                let error = "Binding error to variable: \(error)"
                #if DEBUG
                    _RXCocoa_rxFatalError(error)
                #else
                    print(error)
                #endif
            case .completed:
                break
            }
        }
    }

    /**
     Creates new subscription and sends elements to variable.

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter to: Target variable for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    func bind(to variable: _RXCocoa_Variable<Element?>) -> _RXSwift_Disposable {
        return self.map { $0 as Element? }.bind(to: variable)
    }
}

// MARK: throttle
extension _RXSwift_SharedSequenceConvertibleType {
    /**
     Returns an Observable that emits the first and the latest item emitted by the source Observable during sequential time windows of a specified duration.

     This operator makes sure that no two elements are emitted in less then dueTime.

     - seealso: [debounce operator on reactivex.io](http://reactivex.io/documentation/operators/debounce.html)

     - parameter dueTime: Throttling duration for each element.
     - parameter latest: Should latest element received in a dueTime wide time window since last element emission be emitted.
     - returns: The throttled sequence.
     */
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timeout(_:latest:)")
    func throttle(_ dueTime: Foundation.TimeInterval, latest: Bool = true)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return throttle(.milliseconds(Int(dueTime * 1000.0)), latest: latest)
    }

    /**
     Ignores elements from an observable sequence which are followed by another element within a specified relative time duration, using the specified scheduler to run throttling timers.

     - parameter dueTime: Throttling duration for each element.
     - returns: The throttled sequence.
     */
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "debounce(_:)")
    func debounce(_ dueTime: Foundation.TimeInterval)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return debounce(.milliseconds(Int(dueTime * 1000.0)))
    }
}

// MARK: delay
extension _RXSwift_SharedSequenceConvertibleType {
    
    /**
     Returns an observable sequence by the source observable sequence shifted forward in time by a specified delay. Error events from the source observable sequence are not delayed.
     
     - seealso: [delay operator on reactivex.io](http://reactivex.io/documentation/operators/delay.html)
     
     - parameter dueTime: Relative time shift of the source by.
     - parameter scheduler: Scheduler to run the subscription delay timer on.
     - returns: the source Observable shifted in time by the specified delay.
     */
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "delay(_:)")
    func delay(_ dueTime: Foundation.TimeInterval)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return delay(.milliseconds(Int(dueTime * 1000.0)))
    }
}

extension _RXSwift_SharedSequence where Element : _RXSwift_RxAbstractInteger {
    /**
     Returns an observable sequence that produces a value after each period, using the specified scheduler to run timers and to send out observer messages.
     
     - seealso: [interval operator on reactivex.io](http://reactivex.io/documentation/operators/interval.html)
     
     - parameter period: Period for producing the values in the resulting sequence.
     - returns: An observable sequence that produces a value after each period.
     */
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "interval(_:)")
    static func interval(_ period: Foundation.TimeInterval)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return interval(.milliseconds(Int(period * 1000.0)))
    }
}

// MARK: timer

extension _RXSwift_SharedSequence where Element: _RXSwift_RxAbstractInteger {
    /**
     Returns an observable sequence that periodically produces a value after the specified initial relative due time has elapsed, using the specified scheduler to run timers.
     
     - seealso: [timer operator on reactivex.io](http://reactivex.io/documentation/operators/timer.html)
     
     - parameter dueTime: Relative time at which to produce the first value.
     - parameter period: Period to produce subsequent values.
     - returns: An observable sequence that produces a value after due time has elapsed and then each period.
     */
    @available(*, deprecated, message: "Use DispatchTimeInterval overload instead.", renamed: "timer(_:)")
    static func timer(_ dueTime: Foundation.TimeInterval, period: Foundation.TimeInterval)
        -> _RXSwift_SharedSequence<SharingStrategy, Element> {
        return timer(.milliseconds(Int(dueTime * 1000.0)), period: .milliseconds(Int(period * 1000.0)))
    }
}

