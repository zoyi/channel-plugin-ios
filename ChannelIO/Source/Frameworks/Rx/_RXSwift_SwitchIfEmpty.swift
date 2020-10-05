//
//  SwitchIfEmpty.swift
//  RxSwift
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Returns the elements of the specified sequence or `switchTo` sequence if the sequence is empty.

     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)

     - parameter switchTo: Observable sequence being returned when source sequence is empty.
     - returns: Observable sequence that contains elements from switchTo sequence if source is empty, otherwise returns source sequence elements.
     */
    func ifEmpty(switchTo other: _RXSwift_Observable<Element>) -> _RXSwift_Observable<Element> {
        return SwitchIfEmpty(source: self.asObservable(), ifEmpty: other)
    }
}

final private class SwitchIfEmpty<Element>: _RXSwift_Producer<Element> {
    
    private let _source: _RXSwift_Observable<Element>
    private let _ifEmpty: _RXSwift_Observable<Element>
    
    init(source: _RXSwift_Observable<Element>, ifEmpty: _RXSwift_Observable<Element>) {
        self._source = source
        self._ifEmpty = ifEmpty
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = SwitchIfEmptySink(ifEmpty: self._ifEmpty,
                                     observer: observer,
                                     cancel: cancel)
        let subscription = sink.run(self._source.asObservable())
        
        return (sink: sink, subscription: subscription)
    }
}

final private class SwitchIfEmptySink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType {
    typealias Element = Observer.Element
    
    private let _ifEmpty: _RXSwift_Observable<Element>
    private var _isEmpty = true
    private let _ifEmptySubscription = _RXSwift_SingleAssignmentDisposable()
    
    init(ifEmpty: _RXSwift_Observable<Element>, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._ifEmpty = ifEmpty
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ source: _RXSwift_Observable<Observer.Element>) -> _RXSwift_Disposable {
        let subscription = source.subscribe(self)
        return _RXSwift_Disposables.create(subscription, _ifEmptySubscription)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._isEmpty = false
            self.forwardOn(event)
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            guard self._isEmpty else {
                self.forwardOn(.completed)
                self.dispose()
                return
            }
            let ifEmptySink = SwitchIfEmptySinkIter(parent: self)
            self._ifEmptySubscription.setDisposable(self._ifEmpty.subscribe(ifEmptySink))
        }
    }
}

final private class SwitchIfEmptySinkIter<Observer: _RXSwift_ObserverType>
    : _RXSwift_ObserverType {
    typealias Element = Observer.Element
    typealias Parent = SwitchIfEmptySink<Observer>
    
    private let _parent: Parent

    init(parent: Parent) {
        self._parent = parent
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self._parent.forwardOn(event)
        case .error:
            self._parent.forwardOn(event)
            self._parent.dispose()
        case .completed:
            self._parent.forwardOn(event)
            self._parent.dispose()
        }
    }
}
