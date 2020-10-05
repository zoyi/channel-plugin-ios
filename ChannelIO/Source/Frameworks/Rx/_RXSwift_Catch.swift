//
//  Catch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
     */
    func catchError(_ handler: @escaping (Swift.Error) throws -> _RXSwift_Observable<Element>)
        -> _RXSwift_Observable<Element> {
        return Catch(source: self.asObservable(), handler: handler)
    }

    /**
     Continues an observable sequence that is terminated by an error with a single element.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter element: Last element in an observable sequence in case error occurs.
     - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
     */
    func catchErrorJustReturn(_ element: Element)
        -> _RXSwift_Observable<Element> {
        return Catch(source: self.asObservable(), handler: { _ in _RXSwift_Observable.just(element) })
    }
    
}

extension _RXSwift_ObservableType {
    /**
     Continues an observable sequence that is terminated by an error with the next observable sequence.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - returns: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
     */
    static func catchError<Sequence: Swift.Sequence>(_ sequence: Sequence) -> _RXSwift_Observable<Element>
        where Sequence.Element == _RXSwift_Observable<Element> {
        return CatchSequence(sources: sequence)
    }
}

extension _RXSwift_ObservableType {

    /**
     Repeats the source observable sequence until it successfully terminates.

     **This could potentially create an infinite sequence.**

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - returns: Observable sequence to repeat until it successfully terminates.
     */
    func retry() -> _RXSwift_Observable<Element> {
        return CatchSequence(sources: _RXPlatform_InfiniteSequence(repeatedValue: self.asObservable()))
    }

    /**
     Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.

     If you encounter an error and want it to retry once, then you must use `retry(2)`

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter maxAttemptCount: Maximum number of times to repeat the sequence.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
     */
    func retry(_ maxAttemptCount: Int)
        -> _RXSwift_Observable<Element> {
        return CatchSequence(sources: Swift.repeatElement(self.asObservable(), count: maxAttemptCount))
    }
}

// catch with callback

final private class CatchSinkProxy<Observer: _RXSwift_ObserverType>: _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = CatchSink<Observer>
    
    private let _parent: Parent
    
    init(parent: Parent) {
        self._parent = parent
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self._parent.forwardOn(event)
        
        switch event {
        case .next:
            break
        case .error, .completed:
            self._parent.dispose()
        }
    }
}

final private class CatchSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = Catch<Element>
    
    private let _parent: Parent
    private let _subscription = _RXSwift_SerialDisposable()
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        let d1 = _RXSwift_SingleAssignmentDisposable()
        self._subscription.disposable = d1
        d1.setDisposable(self._parent._source.subscribe(self))

        return self._subscription
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .completed:
            self.forwardOn(event)
            self.dispose()
        case .error(let error):
            do {
                let catchSequence = try self._parent._handler(error)

                let observer = CatchSinkProxy(parent: self)
                
                self._subscription.disposable = catchSequence.subscribe(observer)
            }
            catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        }
    }
}

final private class Catch<Element>: _RXSwift_Producer<Element> {
    typealias Handler = (Swift.Error) throws -> _RXSwift_Observable<Element>
    
    fileprivate let _source: _RXSwift_Observable<Element>
    fileprivate let _handler: Handler
    
    init(source: _RXSwift_Observable<Element>, handler: @escaping Handler) {
        self._source = source
        self._handler = handler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = CatchSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

// catch enumerable

final private class CatchSequenceSink<Sequence: Swift.Sequence, Observer: _RXSwift_ObserverType>
    : _RXSwift_TailRecursiveSink<Sequence, Observer>
    , _RXSwift_ObserverType where Sequence.Element: _RXSwift_ObservableConvertibleType, Sequence.Element.Element == Observer.Element {
    typealias Element = Observer.Element
    typealias Parent = CatchSequence<Sequence>

    private var _lastError: Swift.Error?
    
    override init(observer: Observer, cancel: _RXSwift_Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .error(let error):
            self._lastError = error
            self.schedule(.moveNext)
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }

    override func subscribeToNext(_ source: _RXSwift_Observable<Element>) -> _RXSwift_Disposable {
        return source.subscribe(self)
    }
    
    override func done() {
        if let lastError = self._lastError {
            self.forwardOn(.error(lastError))
        }
        else {
            self.forwardOn(.completed)
        }
        
        self.dispose()
    }
    
    override func extract(_ observable: _RXSwift_Observable<Element>) -> SequenceGenerator? {
        if let onError = observable as? CatchSequence<Sequence> {
            return (onError.sources.makeIterator(), nil)
        }
        else {
            return nil
        }
    }
}

final private class CatchSequence<Sequence: Swift.Sequence>: _RXSwift_Producer<Sequence.Element.Element> where Sequence.Element: _RXSwift_ObservableConvertibleType {
    typealias Element = Sequence.Element.Element
    
    let sources: Sequence
    
    init(sources: Sequence) {
        self.sources = sources
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = CatchSequenceSink<Sequence, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run((self.sources.makeIterator(), nil))
        return (sink: sink, subscription: subscription)
    }
}
