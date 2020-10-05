//
//  Buffer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Projects each element of an observable sequence into a buffer that's sent out when either it's full or a given amount of time has elapsed, using the specified scheduler to run timers.

     A useful real-world analogy of this overload is the behavior of a ferry leaving the dock when all seats are taken, or at the scheduled time of departure, whichever event occurs first.

     - seealso: [buffer operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)

     - parameter timeSpan: Maximum time length of a buffer.
     - parameter count: Maximum element count of a buffer.
     - parameter scheduler: Scheduler to run buffering timers on.
     - returns: An observable sequence of buffers.
     */
    func buffer(timeSpan: _RXSwift_RxTimeInterval, count: Int, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<[Element]> {
        return BufferTimeCount(source: self.asObservable(), timeSpan: timeSpan, count: count, scheduler: scheduler)
    }
}

final private class BufferTimeCount<Element>: _RXSwift_Producer<[Element]> {
    
    fileprivate let _timeSpan: _RXSwift_RxTimeInterval
    fileprivate let _count: Int
    fileprivate let _scheduler: _RXSwift_SchedulerType
    fileprivate let _source: _RXSwift_Observable<Element>
    
    init(source: _RXSwift_Observable<Element>, timeSpan: _RXSwift_RxTimeInterval, count: Int, scheduler: _RXSwift_SchedulerType) {
        self._source = source
        self._timeSpan = timeSpan
        self._count = count
        self._scheduler = scheduler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == [Element] {
        let sink = BufferTimeCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class BufferTimeCountSink<Element, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_LockOwnerType
    , _RXSwift_ObserverType
    , _RXSwift_SynchronizedOnType where Observer.Element == [Element] {
    typealias Parent = BufferTimeCount<Element>
    
    private let _parent: Parent
    
    let _lock = _RXPlatform_RecursiveLock()
    
    // state
    private let _timerD = _RXSwift_SerialDisposable()
    private var _buffer = [Element]()
    private var _windowID = 0
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
 
    func run() -> _RXSwift_Disposable {
        self.createTimer(self._windowID)
        return _RXSwift_Disposables.create(_timerD, _parent._source.subscribe(self))
    }
    
    func startNewWindowAndSendCurrentOne() {
        self._windowID = self._windowID &+ 1
        let windowID = self._windowID
        
        let buffer = self._buffer
        self._buffer = []
        self.forwardOn(.next(buffer))
        
        self.createTimer(windowID)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case .next(let element):
            self._buffer.append(element)
            
            if self._buffer.count == self._parent._count {
                self.startNewWindowAndSendCurrentOne()
            }
            
        case .error(let error):
            self._buffer = []
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self.forwardOn(.next(self._buffer))
            self.forwardOn(.completed)
            self.dispose()
        }
    }
    
    func createTimer(_ windowID: Int) {
        if self._timerD.isDisposed {
            return
        }
        
        if self._windowID != windowID {
            return
        }

        let nextTimer = _RXSwift_SingleAssignmentDisposable()
        
        self._timerD.disposable = nextTimer

        let disposable = self._parent._scheduler.scheduleRelative(windowID, dueTime: self._parent._timeSpan) { previousWindowID in
            self._lock.performLocked {
                if previousWindowID != self._windowID {
                    return
                }
             
                self.startNewWindowAndSendCurrentOne()
            }
            
            return _RXSwift_Disposables.create()
        }

        nextTimer.setDisposable(disposable)
    }
}
