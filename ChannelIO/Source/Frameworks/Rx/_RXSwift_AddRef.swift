//
//  AddRef.swift
//  RxSwift
//
//  Created by Junior B. on 30/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

final class _RXSwift_AddRefSink<Observer: _RXSwift_ObserverType> : _RXSwift_Sink<Observer>, _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    
    override init(observer: Observer, cancel: _RXSwift_Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next:
            self.forwardOn(event)
        case .completed, .error:
            self.forwardOn(event)
            self.dispose()
        }
    }
}

final class _RXSwift_AddRef<Element> : _RXSwift_Producer<Element> {
    
    private let _source: _RXSwift_Observable<Element>
    private let _refCount: _RXSwift_RefCountDisposable
    
    init(source: _RXSwift_Observable<Element>, refCount: _RXSwift_RefCountDisposable) {
        self._source = source
        self._refCount = refCount
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let releaseDisposable = self._refCount.retain()
        let sink = _RXSwift_AddRefSink(observer: observer, cancel: cancel)
        let subscription = _RXSwift_Disposables.create(releaseDisposable, self._source.subscribe(sink))

        return (sink: sink, subscription: subscription)
    }
}
