//
//  Window.swift
//  RxSwift
//
//  Created by Junior B. on 29/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Projects each element of an observable sequence into a window that is completed when either it’s full or a given amount of time has elapsed.

     - seealso: [window operator on reactivex.io](http://reactivex.io/documentation/operators/window.html)

     - parameter timeSpan: Maximum time length of a window.
     - parameter count: Maximum element count of a window.
     - parameter scheduler: Scheduler to run windowing timers on.
     - returns: An observable sequence of windows (instances of `Observable`).
     */
    func window(timeSpan: _RXSwift_RxTimeInterval, count: Int, scheduler: _RXSwift_SchedulerType)
        -> _RXSwift_Observable<_RXSwift_Observable<Element>> {
            return WindowTimeCount(source: self.asObservable(), timeSpan: timeSpan, count: count, scheduler: scheduler)
    }
}

final private class WindowTimeCountSink<Element, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType where Observer.Element == _RXSwift_Observable<Element> {
    typealias Parent = WindowTimeCount<Element>
    
    private let _parent: Parent
    
    let _lock = _RXPlatform_RecursiveLock()
    
    private var _subject = _RXSwift_PublishSubject<Element>()
    private var _count = 0
    private var _windowId = 0
    
    private let _timerD = _RXSwift_SerialDisposable()
    private let _refCountDisposable: _RXSwift_RefCountDisposable
    private let _groupDisposable = _RXSwift_CompositeDisposable()
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        
        _ = self._groupDisposable.insert(self._timerD)
        
        self._refCountDisposable = _RXSwift_RefCountDisposable(disposable: self._groupDisposable)
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        
        self.forwardOn(.next(_RXSwift_AddRef(source: self._subject, refCount: self._refCountDisposable).asObservable()))
        self.createTimer(self._windowId)
        
        _ = self._groupDisposable.insert(self._parent._source.subscribe(self))
        return self._refCountDisposable
    }
    
    func startNewWindowAndCompleteCurrentOne() {
        self._subject.on(.completed)
        self._subject = _RXSwift_PublishSubject<Element>()
        
        self.forwardOn(.next(_RXSwift_AddRef(source: self._subject, refCount: self._refCountDisposable).asObservable()))
    }

    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        var newWindow = false
        var newId = 0
        
        switch event {
        case .next(let element):
            self._subject.on(.next(element))
            
            do {
                _ = try _RXSwift_incrementChecked(&self._count)
            } catch let e {
                self._subject.on(.error(e as Swift.Error))
                self.dispose()
            }
            
            if self._count == self._parent._count {
                newWindow = true
                self._count = 0
                self._windowId += 1
                newId = self._windowId
                self.startNewWindowAndCompleteCurrentOne()
            }
            
        case .error(let error):
            self._subject.on(.error(error))
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self._subject.on(.completed)
            self.forwardOn(.completed)
            self.dispose()
        }

        if newWindow {
            self.createTimer(newId)
        }
    }
    
    func createTimer(_ windowId: Int) {
        if self._timerD.isDisposed {
            return
        }
        
        if self._windowId != windowId {
            return
        }

        let nextTimer = _RXSwift_SingleAssignmentDisposable()

        self._timerD.disposable = nextTimer

        let scheduledRelative = self._parent._scheduler.scheduleRelative(windowId, dueTime: self._parent._timeSpan) { previousWindowId in
            
            var newId = 0
            
            self._lock.performLocked {
                if previousWindowId != self._windowId {
                    return
                }
                
                self._count = 0
                self._windowId = self._windowId &+ 1
                newId = self._windowId
                self.startNewWindowAndCompleteCurrentOne()
            }
            
            self.createTimer(newId)
            
            return _RXSwift_Disposables.create()
        }

        nextTimer.setDisposable(scheduledRelative)
    }
}

final private class WindowTimeCount<Element>: _RXSwift_Producer<_RXSwift_Observable<Element>> {
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
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == _RXSwift_Observable<Element> {
        let sink = WindowTimeCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
