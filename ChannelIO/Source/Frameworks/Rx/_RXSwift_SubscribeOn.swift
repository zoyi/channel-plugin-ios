//
//  SubscribeOn.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Wraps the source sequence in order to run its subscription and unsubscription logic on the specified
     scheduler.

     This operation is not commonly used.

     This only performs the side-effects of subscription and unsubscription on the specified scheduler.

     In order to invoke observer callbacks on a `scheduler`, use `observeOn`.

     - seealso: [subscribeOn operator on reactivex.io](http://reactivex.io/documentation/operators/subscribeon.html)

     - parameter scheduler: Scheduler to perform subscription and unsubscription actions on.
     - returns: The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
     */
     func subscribeOn(_ scheduler: _RXSwift_ImmediateSchedulerType)
        -> _RXSwift_Observable<Element> {
        return SubscribeOn(source: self, scheduler: scheduler)
    }
}

final private class SubscribeOnSink<Ob: _RXSwift_ObservableType, Observer: _RXSwift_ObserverType>: _RXSwift_Sink<Observer>, _RXSwift_ObserverType where Ob.Element == Observer.Element {
    typealias Element = Observer.Element 
    typealias Parent = SubscribeOn<Ob>
    
    let parent: Parent
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.forwardOn(event)
        
        if event.isStopEvent {
            self.dispose()
        }
    }
    
    func run() -> _RXSwift_Disposable {
        let disposeEverything = _RXSwift_SerialDisposable()
        let cancelSchedule = _RXSwift_SingleAssignmentDisposable()
        
        disposeEverything.disposable = cancelSchedule
        
        let disposeSchedule = self.parent.scheduler.schedule(()) { _ -> _RXSwift_Disposable in
            let subscription = self.parent.source.subscribe(self)
            disposeEverything.disposable = _RXSwift_ScheduledDisposable(scheduler: self.parent.scheduler, disposable: subscription)
            return _RXSwift_Disposables.create()
        }

        cancelSchedule.setDisposable(disposeSchedule)
    
        return disposeEverything
    }
}

final private class SubscribeOn<Ob: _RXSwift_ObservableType>: _RXSwift_Producer<Ob.Element> {
    let source: Ob
    let scheduler: _RXSwift_ImmediateSchedulerType
    
    init(source: Ob, scheduler: _RXSwift_ImmediateSchedulerType) {
        self.source = source
        self.scheduler = scheduler
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Ob.Element {
        let sink = SubscribeOnSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
