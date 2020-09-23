//
//  Observable+Bind.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

extension _RXSwift_ObservableType {
    /**
     Creates new subscription and sends elements to observer(s).
     In this form, it's equivalent to the `subscribe` method, but it better conveys intent, and enables
     writing more consistent binding code.
     - parameter to: Observers to receives events.
     - returns: Disposable object that can be used to unsubscribe the observers.
     */
    func bind<Observer: _RXSwift_ObserverType>(to observers: Observer...) -> _RXSwift_Disposable where Observer.Element == Element {
        return self.bind(to: observers)
    }

    /**
     Creates new subscription and sends elements to observer(s).
     In this form, it's equivalent to the `subscribe` method, but it better conveys intent, and enables
     writing more consistent binding code.
     - parameter to: Observers to receives events.
     - returns: Disposable object that can be used to unsubscribe the observers.
     */
    func bind<Observer: _RXSwift_ObserverType>(to observers: Observer...) -> _RXSwift_Disposable where Observer.Element == Element? {
        return self.map { $0 as Element? }.bind(to: observers)
    }

    /**
     Creates new subscription and sends elements to observer(s).
     In this form, it's equivalent to the `subscribe` method, but it better conveys intent, and enables
     writing more consistent binding code.
     - parameter to: Observers to receives events.
     - returns: Disposable object that can be used to unsubscribe the observers.
     */
    private func bind<Observer: _RXSwift_ObserverType>(to observers: [Observer]) -> _RXSwift_Disposable where Observer.Element == Element {
        return self.subscribe { event in
            observers.forEach { $0.on(event) }
        }
    }

    /**
    Subscribes to observable sequence using custom binder function.

    - parameter to: Function used to bind elements from `self`.
    - returns: Object representing subscription.
    */
    func bind<Result>(to binder: (Self) -> Result) -> Result {
        return binder(self)
    }

    /**
    Subscribes to observable sequence using custom binder function and final parameter passed to binder function
    after `self` is passed.

        func bind<R1, R2>(to binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
            return binder(self)(curriedArgument)
        }

    - parameter to: Function used to bind elements from `self`.
    - parameter curriedArgument: Final argument passed to `binder` to finish binding process.
    - returns: Object representing subscription.
    */
    func bind<R1, R2>(to binder: (Self) -> (R1) -> R2, curriedArgument: R1) -> R2 {
         return binder(self)(curriedArgument)
    }


    /**
    Subscribes an element handler to an observable sequence.
    In case error occurs in debug mode, `fatalError` will be raised.
    In case error occurs in release mode, `error` will be logged.

    - parameter onNext: Action to invoke for each element in the observable sequence.
    - returns: Subscription object used to unsubscribe from the observable sequence.
    */
    func bind(onNext: @escaping (Element) -> Void) -> _RXSwift_Disposable {
        return self.subscribe(onNext: onNext, onError: { error in
            _RXCocoa_rxFatalErrorInDebug("Binding error: \(error)")
        })
    }
}
