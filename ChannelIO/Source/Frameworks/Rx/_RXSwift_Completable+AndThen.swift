//
//  Completable+AndThen.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/2/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_PrimitiveSequenceType where Trait == _RXSwift_CompletableTrait, Element == Never {
    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
     func andThen<Element>(_ second: _RXSwift_Single<Element>) -> _RXSwift_Single<Element> {
        let completable = self.primitiveSequence.asObservable()
        return _RXSwift_Single(raw: ConcatCompletable(completable: completable, second: second.asObservable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
     func andThen<Element>(_ second: _RXSwift_Maybe<Element>) ->_RXSwift_Maybe<Element> {
        let completable = self.primitiveSequence.asObservable()
        return _RXSwift_Maybe(raw: ConcatCompletable(completable: completable, second: second.asObservable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
     func andThen(_ second: _RXSwift_Completable) -> _RXSwift_Completable {
        let completable = self.primitiveSequence.asObservable()
        return _RXSwift_Completable(raw: ConcatCompletable(completable: completable, second: second.asObservable()))
    }

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
     func andThen<Element>(_ second: _RXSwift_Observable<Element>) -> _RXSwift_Observable<Element> {
        let completable = self.primitiveSequence.asObservable()
        return ConcatCompletable(completable: completable, second: second.asObservable())
    }
}

final private class ConcatCompletable<Element>: _RXSwift_Producer<Element> {
    fileprivate let _completable: _RXSwift_Observable<Never>
    fileprivate let _second: _RXSwift_Observable<Element>

    init(completable: _RXSwift_Observable<Never>, second: _RXSwift_Observable<Element>) {
        self._completable = completable
        self._second = second
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = ConcatCompletableSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class ConcatCompletableSink<Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType {
    typealias Element = Never
    typealias Parent = ConcatCompletable<Observer.Element>

    private let _parent: Parent
    private let _subscription = _RXSwift_SerialDisposable()
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .error(let error):
            self.forwardOn(.error(error))
            self.dispose()
        case .next:
            break
        case .completed:
            let otherSink = ConcatCompletableSinkOther(parent: self)
            self._subscription.disposable = self._parent._second.subscribe(otherSink)
        }
    }

    func run() -> _RXSwift_Disposable {
        let subscription = _RXSwift_SingleAssignmentDisposable()
        self._subscription.disposable = subscription
        subscription.setDisposable(self._parent._completable.subscribe(self))
        return self._subscription
    }
}

final private class ConcatCompletableSinkOther<Observer: _RXSwift_ObserverType>
    : _RXSwift_ObserverType {
    typealias Element = Observer.Element 

    typealias Parent = ConcatCompletableSink<Observer>
    
    private let _parent: Parent

    init(parent: Parent) {
        self._parent = parent
    }

    func on(_ event: _RXSwift_Event<Observer.Element>) {
        self._parent.forwardOn(event)
        if event.isStopEvent {
            self._parent.dispose()
        }
    }
}
