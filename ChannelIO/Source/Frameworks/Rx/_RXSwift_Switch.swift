//
//  Switch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    func flatMapLatest<Source: _RXSwift_ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
        -> _RXSwift_Observable<Source.Element> {
            return FlatMapLatest(source: self.asObservable(), selector: selector)
    }
}

extension _RXSwift_ObservableType where Element : _RXSwift_ObservableConvertibleType {

    /**
     Transforms an observable sequence of observable sequences into an observable sequence
     producing values only from the most recent observable sequence.

     Each time a new inner observable sequence is received, unsubscribe from the
     previous inner observable sequence.

     - seealso: [switch operator on reactivex.io](http://reactivex.io/documentation/operators/switch.html)

     - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    func switchLatest() -> _RXSwift_Observable<Element.Element> {
        return Switch(source: self.asObservable())
    }
}

private class SwitchSink<SourceType, Source: _RXSwift_ObservableConvertibleType, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType where Source.Element == Observer.Element {
    typealias Element = SourceType

    private let _subscriptions: _RXSwift_SingleAssignmentDisposable = _RXSwift_SingleAssignmentDisposable()
    private let _innerSubscription: _RXSwift_SerialDisposable = _RXSwift_SerialDisposable()

    let _lock = _RXPlatform_RecursiveLock()
    
    // state
    fileprivate var _stopped = false
    fileprivate var _latest = 0
    fileprivate var _hasLatest = false
    
    override init(observer: Observer, cancel: _RXSwift_Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ source: _RXSwift_Observable<SourceType>) -> _RXSwift_Disposable {
        let subscription = source.subscribe(self)
        self._subscriptions.setDisposable(subscription)
        return _RXSwift_Disposables.create(_subscriptions, _innerSubscription)
    }

    func performMap(_ element: SourceType) throws -> Source {
        _RXSwift_rxAbstractMethod()
    }

    @inline(__always)
    final private func nextElementArrived(element: Element) -> (Int, _RXSwift_Observable<Source.Element>)? {
        self._lock.lock(); defer { self._lock.unlock() } // {
            do {
                let observable = try self.performMap(element).asObservable()
                self._hasLatest = true
                self._latest = self._latest &+ 1
                return (self._latest, observable)
            }
            catch let error {
                self.forwardOn(.error(error))
                self.dispose()
            }

            return nil
        // }
    }

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let element):
            if let (latest, observable) = self.nextElementArrived(element: element) {
                let d = _RXSwift_SingleAssignmentDisposable()
                self._innerSubscription.disposable = d
                   
                let observer = SwitchSinkIter(parent: self, id: latest, _self: d)
                let disposable = observable.subscribe(observer)
                d.setDisposable(disposable)
            }
        case .error(let error):
            self._lock.lock(); defer { self._lock.unlock() }
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self._lock.lock(); defer { self._lock.unlock() }
            self._stopped = true
            
            self._subscriptions.dispose()
            
            if !self._hasLatest {
                self.forwardOn(.completed)
                self.dispose()
            }
        }
    }
}

final private class SwitchSinkIter<SourceType, Source: _RXSwift_ObservableConvertibleType, Observer: _RXSwift_ObserverType>
    : _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType where Source.Element == Observer.Element {
    typealias Element = Source.Element
    typealias Parent = SwitchSink<SourceType, Source, Observer>
    
    private let _parent: Parent
    private let _id: Int
    private let _self: _RXSwift_Disposable

    var _lock: _RXPlatform_RecursiveLock {
        return self._parent._lock
    }

    init(parent: Parent, id: Int, _self: _RXSwift_Disposable) {
        self._parent = parent
        self._id = id
        self._self = _self
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next: break
        case .error, .completed:
            self._self.dispose()
        }
        
        if self._parent._latest != self._id {
            return
        }
       
        switch event {
        case .next:
            self._parent.forwardOn(event)
        case .error:
            self._parent.forwardOn(event)
            self._parent.dispose()
        case .completed:
            self._parent._hasLatest = false
            if self._parent._stopped {
                self._parent.forwardOn(event)
                self._parent.dispose()
            }
        }
    }
}

// MARK: Specializations

final private class SwitchIdentitySink<Source: _RXSwift_ObservableConvertibleType, Observer: _RXSwift_ObserverType>: SwitchSink<Source, Source, Observer>
    where Observer.Element == Source.Element {
    override init(observer: Observer, cancel: _RXSwift_Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: Source) throws -> Source {
        return element
    }
}

final private class MapSwitchSink<SourceType, Source: _RXSwift_ObservableConvertibleType, Observer: _RXSwift_ObserverType>: SwitchSink<SourceType, Source, Observer> where Observer.Element == Source.Element {
    typealias Selector = (SourceType) throws -> Source

    private let _selector: Selector

    init(selector: @escaping Selector, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceType) throws -> Source {
        return try self._selector(element)
    }
}

// MARK: Producers

final private class Switch<Source: _RXSwift_ObservableConvertibleType>: _RXSwift_Producer<Source.Element> {
    private let _source: _RXSwift_Observable<Source>
    
    init(source: _RXSwift_Observable<Source>) {
        self._source = source
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Source.Element {
        let sink = SwitchIdentitySink<Source, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(self._source)
        return (sink: sink, subscription: subscription)
    }
}

final private class FlatMapLatest<SourceType, Source: _RXSwift_ObservableConvertibleType>: _RXSwift_Producer<Source.Element> {
    typealias Selector = (SourceType) throws -> Source

    private let _source: _RXSwift_Observable<SourceType>
    private let _selector: Selector

    init(source: _RXSwift_Observable<SourceType>, selector: @escaping Selector) {
        self._source = source
        self._selector = selector
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Source.Element {
        let sink = MapSwitchSink<SourceType, Source, Observer>(selector: self._selector, observer: observer, cancel: cancel)
        let subscription = sink.run(self._source)
        return (sink: sink, subscription: subscription)
    }
}
