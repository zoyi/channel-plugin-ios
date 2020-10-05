//
//  Amb.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Propagates the observable sequence that reacts first.

     - seealso: [amb operator on reactivex.io](http://reactivex.io/documentation/operators/amb.html)

     - returns: An observable sequence that surfaces any of the given sequences, whichever reacted first.
     */
    static func amb<Sequence: Swift.Sequence>(_ sequence: Sequence) -> _RXSwift_Observable<Element>
        where Sequence.Element == _RXSwift_Observable<Element> {
            return sequence.reduce(_RXSwift_Observable<Sequence.Element.Element>.never()) { a, o in
                return a.amb(o.asObservable())
            }
    }
}

extension _RXSwift_ObservableType {

    /**
     Propagates the observable sequence that reacts first.

     - seealso: [amb operator on reactivex.io](http://reactivex.io/documentation/operators/amb.html)

     - parameter right: Second observable sequence.
     - returns: An observable sequence that surfaces either of the given sequences, whichever reacted first.
     */
    func amb<O2: _RXSwift_ObservableType>
        (_ right: O2)
        -> _RXSwift_Observable<Element> where O2.Element == Element {
        return Amb(left: self.asObservable(), right: right.asObservable())
    }
}

private enum AmbState {
    case neither
    case left
    case right
}

final private class AmbObserver<Observer: _RXSwift_ObserverType>: _RXSwift_ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = AmbSink<Observer>
    typealias This = AmbObserver<Observer>
    typealias Sink = (This, _RXSwift_Event<Element>) -> Void
    
    private let _parent: Parent
    fileprivate var _sink: Sink
    fileprivate var _cancel: _RXSwift_Disposable
    
    init(parent: Parent, cancel: _RXSwift_Disposable, sink: @escaping Sink) {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
        
        self._parent = parent
        self._sink = sink
        self._cancel = cancel
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self._sink(self, event)
        if event.isStopEvent {
            self._cancel.dispose()
        }
    }
    
    deinit {
#if TRACE_RESOURCES
        _ = Resources.decrementTotal()
#endif
    }
}

final private class AmbSink<Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer> {
    typealias Element = Observer.Element
    typealias Parent = Amb<Element>
    typealias AmbObserverType = AmbObserver<Observer>

    private let _parent: Parent
    
    private let _lock = _RXPlatform_RecursiveLock()
    // state
    private var _choice = AmbState.neither
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        let subscription1 = _RXSwift_SingleAssignmentDisposable()
        let subscription2 = _RXSwift_SingleAssignmentDisposable()
        let disposeAll = _RXSwift_Disposables.create(subscription1, subscription2)
        
        let forwardEvent = { (o: AmbObserverType, event: _RXSwift_Event<Element>) -> Void in
            self.forwardOn(event)
            if event.isStopEvent {
                self.dispose()
            }
        }

        let decide = { (o: AmbObserverType, event: _RXSwift_Event<Element>, me: AmbState, otherSubscription: _RXSwift_Disposable) in
            self._lock.performLocked {
                if self._choice == .neither {
                    self._choice = me
                    o._sink = forwardEvent
                    o._cancel = disposeAll
                    otherSubscription.dispose()
                }
                
                if self._choice == me {
                    self.forwardOn(event)
                    if event.isStopEvent {
                        self.dispose()
                    }
                }
            }
        }
        
        let sink1 = AmbObserver(parent: self, cancel: subscription1) { o, e in
            decide(o, e, .left, subscription2)
        }
        
        let sink2 = AmbObserver(parent: self, cancel: subscription1) { o, e in
            decide(o, e, .right, subscription1)
        }
        
        subscription1.setDisposable(self._parent._left.subscribe(sink1))
        subscription2.setDisposable(self._parent._right.subscribe(sink2))
        
        return disposeAll
    }
}

final private class Amb<Element>: _RXSwift_Producer<Element> {
    fileprivate let _left: _RXSwift_Observable<Element>
    fileprivate let _right: _RXSwift_Observable<Element>
    
    init(left: _RXSwift_Observable<Element>, right: _RXSwift_Observable<Element>) {
        self._left = left
        self._right = right
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = AmbSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
