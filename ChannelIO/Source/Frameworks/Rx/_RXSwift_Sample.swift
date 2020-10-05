//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Samples the source observable sequence using a sampler observable sequence producing sampling ticks.

     Upon each sampling tick, the latest element (if any) in the source sequence during the last sampling interval is sent to the resulting sequence.

     **In case there were no new elements between sampler ticks, no element is sent to the resulting sequence.**

     - seealso: [sample operator on reactivex.io](http://reactivex.io/documentation/operators/sample.html)

     - parameter sampler: Sampling tick sequence.
     - returns: Sampled observable sequence.
     */
    func sample<Source: _RXSwift_ObservableType>(_ sampler: Source)
        -> _RXSwift_Observable<Element> {
            return Sample(source: self.asObservable(), sampler: sampler.asObservable())
    }
}

final private class SamplerSink<Observer: _RXSwift_ObserverType, SampleType>
    : _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias Element = SampleType
    
    typealias Parent = SampleSequenceSink<Observer, SampleType>
    
    private let _parent: Parent

    var _lock: _RXPlatform_RecursiveLock {
        return self._parent._lock
    }
    
    init(parent: Parent) {
        self._parent = parent
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next, .completed:
            if let element = _parent._element {
                self._parent._element = nil
                self._parent.forwardOn(.next(element))
            }

            if self._parent._atEnd {
                self._parent.forwardOn(.completed)
                self._parent.dispose()
            }
        case .error(let e):
            self._parent.forwardOn(.error(e))
            self._parent.dispose()
        }
    }
}

final private class SampleSequenceSink<Observer: _RXSwift_ObserverType, SampleType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias Element = Observer.Element 
    typealias Parent = Sample<Element, SampleType>
    
    private let _parent: Parent

    let _lock = _RXPlatform_RecursiveLock()
    
    // state
    fileprivate var _element = nil as Element?
    fileprivate var _atEnd = false
    
    private let _sourceSubscription = _RXSwift_SingleAssignmentDisposable()
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        self._sourceSubscription.setDisposable(self._parent._source.subscribe(self))
        let samplerSubscription = self._parent._sampler.subscribe(SamplerSink(parent: self))
        
        return _RXSwift_Disposables.create(_sourceSubscription, samplerSubscription)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let element):
            self._element = element
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self._atEnd = true
            self._sourceSubscription.dispose()
        }
    }
    
}

final private class Sample<Element, SampleType>: _RXSwift_Producer<Element> {
    fileprivate let _source: _RXSwift_Observable<Element>
    fileprivate let _sampler: _RXSwift_Observable<SampleType>

    init(source: _RXSwift_Observable<Element>, sampler: _RXSwift_Observable<SampleType>) {
        self._source = source
        self._sampler = sampler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = SampleSequenceSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
