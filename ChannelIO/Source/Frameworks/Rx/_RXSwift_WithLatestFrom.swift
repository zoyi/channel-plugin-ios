//
//  WithLatestFrom.swift
//  RxSwift
//
//  Created by Yury Korolev on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.

     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - parameter second: Second observable source.
     - parameter resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
     - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
     */
    func withLatestFrom<Source: _RXSwift_ObservableConvertibleType, ResultType>(_ second: Source, resultSelector: @escaping (Element, Source.Element) throws -> ResultType) -> _RXSwift_Observable<ResultType> {
        return WithLatestFrom(first: self.asObservable(), second: second.asObservable(), resultSelector: resultSelector)
    }

    /**
     Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emits an element.

     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - parameter second: Second observable source.
     - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
     */
    func withLatestFrom<Source: _RXSwift_ObservableConvertibleType>(_ second: Source) -> _RXSwift_Observable<Source.Element> {
        return WithLatestFrom(first: self.asObservable(), second: second.asObservable(), resultSelector: { $1 })
    }
}

final private class WithLatestFromSink<FirstType, SecondType, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias ResultType = Observer.Element
    typealias Parent = WithLatestFrom<FirstType, SecondType, ResultType>
    typealias Element = FirstType
    
    private let _parent: Parent
    
    fileprivate var _lock = _RXPlatform_RecursiveLock()
    fileprivate var _latest: SecondType?

    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        let sndSubscription = _RXSwift_SingleAssignmentDisposable()
        let sndO = WithLatestFromSecond(parent: self, disposable: sndSubscription)
        
        sndSubscription.setDisposable(self._parent._second.subscribe(sndO))
        let fstSubscription = self._parent._first.subscribe(self)

        return _RXSwift_Disposables.create(fstSubscription, sndSubscription)
    }

    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case let .next(value):
            guard let latest = self._latest else { return }
            do {
                let res = try self._parent._resultSelector(value, latest)
                
                self.forwardOn(.next(res))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case .completed:
            self.forwardOn(.completed)
            self.dispose()
        case let .error(error):
            self.forwardOn(.error(error))
            self.dispose()
        }
    }
}

final private class WithLatestFromSecond<FirstType, SecondType, Observer: _RXSwift_ObserverType>
    : _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    
    typealias ResultType = Observer.Element
    typealias Parent = WithLatestFromSink<FirstType, SecondType, Observer>
    typealias Element = SecondType
    
    private let _parent: Parent
    private let _disposable: _RXSwift_Disposable

    var _lock: _RXPlatform_RecursiveLock {
        return self._parent._lock
    }

    init(parent: Parent, disposable: _RXSwift_Disposable) {
        self._parent = parent
        self._disposable = disposable
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case let .next(value):
            self._parent._latest = value
        case .completed:
            self._disposable.dispose()
        case let .error(error):
            self._parent.forwardOn(.error(error))
            self._parent.dispose()
        }
    }
}

final private class WithLatestFrom<FirstType, SecondType, ResultType>: _RXSwift_Producer<ResultType> {
    typealias ResultSelector = (FirstType, SecondType) throws -> ResultType
    
    fileprivate let _first: _RXSwift_Observable<FirstType>
    fileprivate let _second: _RXSwift_Observable<SecondType>
    fileprivate let _resultSelector: ResultSelector

    init(first: _RXSwift_Observable<FirstType>, second: _RXSwift_Observable<SecondType>, resultSelector: @escaping ResultSelector) {
        self._first = first
        self._second = second
        self._resultSelector = resultSelector
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == ResultType {
        let sink = WithLatestFromSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
