//
//  NSObject+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)

import Foundation.NSObject
//import RxSwift
#if SWIFT_PACKAGE && !DISABLE_SWIZZLING && !os(Linux)
    import RxCocoaRuntime
#endif

#if !DISABLE_SWIZZLING && !os(Linux)
private var deallocatingSubjectTriggerContext: UInt8 = 0
private var deallocatingSubjectContext: UInt8 = 0
#endif
private var deallocatedSubjectTriggerContext: UInt8 = 0
private var deallocatedSubjectContext: UInt8 = 0

#if !os(Linux)

/**
KVO is a tricky mechanism.

When observing child in a ownership hierarchy, usually retaining observing target is wanted behavior.
When observing parent in a ownership hierarchy, usually retaining target isn't wanter behavior.

KVO with weak references is especially tricky. For it to work, some kind of swizzling is required.
That can be done by
    * replacing object class dynamically (like KVO does)
    * by swizzling `dealloc` method on all instances for a class.
    * some third method ...

Both approaches can fail in certain scenarios:
    * problems arise when swizzlers return original object class (like KVO does when nobody is observing)
    * Problems can arise because replacing dealloc method isn't atomic operation (get implementation,
    set implementation).

Second approach is chosen. It can fail in case there are multiple libraries dynamically trying
to replace dealloc method. In case that isn't the case, it should be ok.
*/
extension _RXSwift_Reactive where Base: NSObject {


    /**
     Observes values on `keyPath` starting from `self` with `options` and retains `self` if `retainSelf` is set.

     `observe` is just a simple and performant wrapper around KVO mechanism.

     * it can be used to observe paths starting from `self` or from ancestors in ownership graph (`retainSelf = false`)
     * it can be used to observe paths starting from descendants in ownership graph (`retainSelf = true`)
     * the paths have to consist only of `strong` properties, otherwise you are risking crashing the system by not unregistering KVO observer before dealloc.

     If support for weak properties is needed or observing arbitrary or unknown relationships in the
     ownership tree, `observeWeakly` is the preferred option.

     - parameter keyPath: Key path of property names to observe.
     - parameter options: KVO mechanism notification options.
     - parameter retainSelf: Retains self during observation if set `true`.
     - returns: Observable sequence of objects on `keyPath`.
     */
    func observe<Element>(_ type: Element.Type, _ keyPath: String, options: _RXCocoa_KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> _RXSwift_Observable<Element?> {
        return KVOObservable(object: self.base, keyPath: keyPath, options: options, retainTarget: retainSelf).asObservable()
    }
}

#endif

#if !DISABLE_SWIZZLING && !os(Linux)
// KVO
extension _RXSwift_Reactive where Base: NSObject {
    /**
     Observes values on `keyPath` starting from `self` with `options` and doesn't retain `self`.

     It can be used in all cases where `observe` can be used and additionally

     * because it won't retain observed target, it can be used to observe arbitrary object graph whose ownership relation is unknown
     * it can be used to observe `weak` properties

     **Since it needs to intercept object deallocation process it needs to perform swizzling of `dealloc` method on observed object.**

     - parameter keyPath: Key path of property names to observe.
     - parameter options: KVO mechanism notification options.
     - returns: Observable sequence of objects on `keyPath`.
     */
    func observeWeakly<Element>(_ type: Element.Type, _ keyPath: String, options: _RXCocoa_KeyValueObservingOptions = [.new, .initial]) -> _RXSwift_Observable<Element?> {
        return observeWeaklyKeyPathFor(self.base, keyPath: keyPath, options: options)
            .map { n in
                return n as? Element
            }
    }
}
#endif

// Dealloc
extension _RXSwift_Reactive where Base: AnyObject {
    
    /**
    Observable sequence of object deallocated events.
    
    After object is deallocated one `()` element will be produced and sequence will immediately complete.
    
    - returns: Observable sequence of object deallocated events.
    */
    var deallocated: _RXSwift_Observable<Void> {
        return self.synchronized {
            if let deallocObservable = objc_getAssociatedObject(self.base, &deallocatedSubjectContext) as? DeallocObservable {
                return deallocObservable._subject
            }

            let deallocObservable = DeallocObservable()

            objc_setAssociatedObject(self.base, &deallocatedSubjectContext, deallocObservable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return deallocObservable._subject
        }
    }

#if !DISABLE_SWIZZLING && !os(Linux)

    /**
     Observable sequence of message arguments that completes when object is deallocated.
     
     Each element is produced before message is invoked on target object. `methodInvoked`
     exists in case observing of invoked messages is needed.

     In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.
     
     In case some argument is `nil`, instance of `NSNull()` will be sent.

     - returns: Observable sequence of arguments passed to `selector` method.
     */
    func sentMessage(_ selector: Selector) -> _RXSwift_Observable<[Any]> {
        return self.synchronized {
            // in case of dealloc selector replay subject behavior needs to be used
            if selector == deallocSelector {
                return self.deallocating.map { _ in [] }
            }

            do {
                let proxy: MessageSentProxy = try self.registerMessageInterceptor(selector)
                return proxy.messageSent.asObservable()
            }
            catch let e {
                return _RXSwift_Observable.error(e)
            }
        }
    }

    /**
     Observable sequence of message arguments that completes when object is deallocated.

     Each element is produced after message is invoked on target object. `sentMessage`
     exists in case interception of sent messages before they were invoked is needed.

     In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.

     In case some argument is `nil`, instance of `NSNull()` will be sent.

     - returns: Observable sequence of arguments passed to `selector` method.
     */
    func methodInvoked(_ selector: Selector) -> _RXSwift_Observable<[Any]> {
        return self.synchronized {
            // in case of dealloc selector replay subject behavior needs to be used
            if selector == deallocSelector {
                return self.deallocated.map { _ in [] }
            }


            do {
                let proxy: MessageSentProxy = try self.registerMessageInterceptor(selector)
                return proxy.methodInvoked.asObservable()
            }
            catch let e {
                return _RXSwift_Observable.error(e)
            }
        }
    }

    /**
    Observable sequence of object deallocating events.
    
    When `dealloc` message is sent to `self` one `()` element will be produced and after object is deallocated sequence
    will immediately complete.
     
    In case an error occurs sequence will fail with `RxCocoaObjCRuntimeError`.
    
    - returns: Observable sequence of object deallocating events.
    */
    var deallocating: _RXSwift_Observable<()> {
        return self.synchronized {
            do {
                let proxy: DeallocatingProxy = try self.registerMessageInterceptor(deallocSelector)
                return proxy.messageSent.asObservable()
            }
            catch let e {
                return _RXSwift_Observable.error(e)
            }
        }
    }

    private func registerMessageInterceptor<T: MessageInterceptorSubject>(_ selector: Selector) throws -> T {
        let rxSelector = _RXCocoa_RX_selector(selector)
        let selectorReference = _RXCocoa_RX_reference_from_selector(rxSelector)

        let subject: T
        if let existingSubject = objc_getAssociatedObject(self.base, selectorReference) as? T {
            subject = existingSubject
        }
        else {
            subject = T()
            objc_setAssociatedObject(
                self.base,
                selectorReference,
                subject,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        if subject.isActive {
            return subject
        }

        var error: NSError?
        let targetImplementation = _RXCocoa_RX_ensure_observing(self.base, selector, &error)
        if targetImplementation == nil {
            throw error?._RXCocoa_rxCocoaErrorForTarget(self.base) ?? _RXCocoa_RxCocoaError.unknown
        }

        subject.targetImplementation = targetImplementation!

        return subject
    }
#endif
}

// MARK: Message interceptors

#if !DISABLE_SWIZZLING && !os(Linux)

    private protocol MessageInterceptorSubject: class {
        init()

        var isActive: Bool {
            get
        }

        var targetImplementation: IMP { get set }
    }

    private final class DeallocatingProxy
        : MessageInterceptorSubject
        , _RXCocoa_RXDeallocatingObserver {
        typealias Element = ()

        let messageSent = _RXSwift_ReplaySubject<()>.create(bufferSize: 1)

        @objc var targetImplementation: IMP = _RXCocoa_RX_default_target_implementation()

        var isActive: Bool {
            return self.targetImplementation != _RXCocoa_RX_default_target_implementation()
        }

        init() {
        }

        @objc func deallocating() {
            self.messageSent.on(.next(()))
        }

        deinit {
            self.messageSent.on(.completed)
        }
    }

    private final class MessageSentProxy
        : MessageInterceptorSubject
        , _RXCocoa_RXMessageSentObserver {
        typealias Element = [AnyObject]

        let messageSent = _RXSwift_PublishSubject<[Any]>()
        let methodInvoked = _RXSwift_PublishSubject<[Any]>()

        @objc var targetImplementation: IMP = _RXCocoa_RX_default_target_implementation()

        var isActive: Bool {
            return self.targetImplementation != _RXCocoa_RX_default_target_implementation()
        }

        init() {
        }

        @objc func messageSent(withArguments arguments: [Any]) {
            self.messageSent.on(.next(arguments))
        }

        @objc func methodInvoked(withArguments arguments: [Any]) {
            self.methodInvoked.on(.next(arguments))
        }

        deinit {
            self.messageSent.on(.completed)
            self.methodInvoked.on(.completed)
        }
    }

#endif


private final class DeallocObservable {
    let _subject = _RXSwift_ReplaySubject<Void>.create(bufferSize:1)

    init() {
    }

    deinit {
        self._subject.on(.next(()))
        self._subject.on(.completed)
    }
}

// MARK: KVO

#if !os(Linux)

private protocol KVOObservableProtocol {
    var target: AnyObject { get }
    var keyPath: String { get }
    var retainTarget: Bool { get }
    var options: _RXCocoa_KeyValueObservingOptions { get }
}

private final class KVOObserver
    : _RXCocoa__RXKVOObserver
    , _RXSwift_Disposable {
    typealias Callback = (Any?) -> Void

    var retainSelf: KVOObserver?

    init(parent: KVOObservableProtocol, callback: @escaping Callback) {
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif

        super.init(target: parent.target, retainTarget: parent.retainTarget, keyPath: parent.keyPath, options: parent.options.nsOptions, callback: callback)
        self.retainSelf = self
    }

    override func dispose() {
        super.dispose()
        self.retainSelf = nil
    }

    deinit {
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
    }
}

private final class KVOObservable<Element>
    : _RXSwift_ObservableType
    , KVOObservableProtocol {
    typealias Element = Element?

    unowned var target: AnyObject
    var strongTarget: AnyObject?

    var keyPath: String
    var options: _RXCocoa_KeyValueObservingOptions
    var retainTarget: Bool

    init(object: AnyObject, keyPath: String, options: _RXCocoa_KeyValueObservingOptions, retainTarget: Bool) {
        self.target = object
        self.keyPath = keyPath
        self.options = options
        self.retainTarget = retainTarget
        if retainTarget {
            self.strongTarget = object
        }
    }

    func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element? {
        let observer = KVOObserver(parent: self) { value in
            if value as? NSNull != nil {
                observer.on(.next(nil))
                return
            }
            observer.on(.next(value as? Element))
        }

        return _RXSwift_Disposables.create(with: observer.dispose)
    }

}

private extension _RXCocoa_KeyValueObservingOptions {
    var nsOptions: NSKeyValueObservingOptions {
        var result: UInt = 0
        if self.contains(.new) {
            result |= NSKeyValueObservingOptions.new.rawValue
        }
        if self.contains(.initial) {
            result |= NSKeyValueObservingOptions.initial.rawValue
        }
        
        return NSKeyValueObservingOptions(rawValue: result)
    }
}

#endif

#if !DISABLE_SWIZZLING && !os(Linux)

    private func observeWeaklyKeyPathFor(_ target: NSObject, keyPath: String, options: _RXCocoa_KeyValueObservingOptions) -> _RXSwift_Observable<AnyObject?> {
        let components = keyPath.components(separatedBy: ".").filter { $0 != "self" }

        let observable = observeWeaklyKeyPathFor(target, keyPathSections: components, options: options)
            .finishWithNilWhenDealloc(target)

        if !options.isDisjoint(with: .initial) {
            return observable
        }
        else {
            return observable
                .skip(1)
        }
    }

    // This should work correctly
    // Identifiers can't contain `,`, so the only place where `,` can appear
    // is as a delimiter.
    // This means there is `W` as element in an array of property attributes.
    private func isWeakProperty(_ properyRuntimeInfo: String) -> Bool {
        return properyRuntimeInfo.range(of: ",W,") != nil
    }

    private extension _RXSwift_ObservableType where Element == AnyObject? {
        func finishWithNilWhenDealloc(_ target: NSObject)
            -> _RXSwift_Observable<AnyObject?> {
                let deallocating = target.rx.deallocating

                return deallocating
                    .map { _ in
                        return _RXSwift_Observable.just(nil)
                    }
                    .startWith(self.asObservable())
                    .switchLatest()
        }
    }

    private func observeWeaklyKeyPathFor(
        _ target: NSObject,
        keyPathSections: [String],
        options: _RXCocoa_KeyValueObservingOptions
        ) -> _RXSwift_Observable<AnyObject?> {

        weak var weakTarget: AnyObject? = target

        let propertyName = keyPathSections[0]
        let remainingPaths = Array(keyPathSections[1..<keyPathSections.count])

        let property = class_getProperty(object_getClass(target), propertyName)
        if property == nil {
            return _RXSwift_Observable.error(_RXCocoa_RxCocoaError.invalidPropertyName(object: target, propertyName: propertyName))
        }
        let propertyAttributes = property_getAttributes(property!)

        // should dealloc hook be in place if week property, or just create strong reference because it doesn't matter
        let isWeak = isWeakProperty(propertyAttributes.map(String.init) ?? "")
        let propertyObservable = KVOObservable(object: target, keyPath: propertyName, options: options.union(.initial), retainTarget: false) as KVOObservable<AnyObject>

        // KVO recursion for value changes
        return propertyObservable
            .flatMapLatest { (nextTarget: AnyObject?) -> _RXSwift_Observable<AnyObject?> in
                if nextTarget == nil {
                    return _RXSwift_Observable.just(nil)
                }
                let nextObject = nextTarget! as? NSObject

                let strongTarget: AnyObject? = weakTarget

                if nextObject == nil {
                    return _RXSwift_Observable.error(_RXCocoa_RxCocoaError.invalidObjectOnKeyPath(object: nextTarget!, sourceObject: strongTarget ?? NSNull(), propertyName: propertyName))
                }

                // if target is alive, then send change
                // if it's deallocated, don't send anything
                if strongTarget == nil {
                    return _RXSwift_Observable.empty()
                }

                let nextElementsObservable = keyPathSections.count == 1
                    ? _RXSwift_Observable.just(nextTarget)
                    : observeWeaklyKeyPathFor(nextObject!, keyPathSections: remainingPaths, options: options)
                
                if isWeak {
                    return nextElementsObservable
                        .finishWithNilWhenDealloc(nextObject!)
                }
                else {
                    return nextElementsObservable
                }
        }
    }
#endif

// MARK: Constants

private let deallocSelector = NSSelectorFromString("dealloc")

// MARK: AnyObject + Reactive

extension _RXSwift_Reactive where Base: AnyObject {
    func synchronized<T>( _ action: () -> T) -> T {
        objc_sync_enter(self.base)
        let result = action()
        objc_sync_exit(self.base)
        return result
    }
}

extension _RXSwift_Reactive where Base: AnyObject {
    /**
     Helper to make sure that `Observable` returned from `createCachedObservable` is only created once.
     This is important because there is only one `target` and `action` properties on `NSControl` or `UIBarButtonItem`.
     */
    func lazyInstanceObservable<T: AnyObject>(_ key: UnsafeRawPointer, createCachedObservable: () -> T) -> T {
        if let value = objc_getAssociatedObject(self.base, key) {
            return value as! T
        }
        
        let observable = createCachedObservable()
        
        objc_setAssociatedObject(self.base, key, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return observable
    }
}

#endif
