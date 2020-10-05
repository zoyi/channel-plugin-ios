//
//  Store.swift
//  ReSwift
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

/**
 This class is the default implementation of the `StoreType` protocol. You will use this store in most
 of your applications. You shouldn't need to implement your own store.
 You initialize the store with a reducer and an initial application state. If your app has multiple
 reducers you can combine them by initializng a `MainReducer` with all of your reducers as an
 argument.
 */
class ReSwift_Store<State: ReSwift_StateType>: ReSwift_StoreType {

    typealias SubscriptionType = ReSwift_SubscriptionBox<State>

    private(set) var state: State! {
        didSet {
            subscriptions.forEach {
                if $0.subscriber == nil {
                    subscriptions.remove($0)
                } else {
                    $0.newValues(oldState: oldValue, newState: state)
                }
            }
        }
    }

    lazy var dispatchFunction: ReSwift_DispatchFunction! = createDispatchFunction()

    private var reducer: ReSwift_Reducer<State>

    var subscriptions: Set<SubscriptionType> = []

    private var isDispatching = ReSwift_AtomicBool()

    /// Indicates if new subscriptions attempt to apply `skipRepeats` 
    /// by default.
    fileprivate let subscriptionsAutomaticallySkipRepeats: Bool

    var middleware: [ReSwift_Middleware<State>] {
        didSet {
            dispatchFunction = createDispatchFunction()
        }
    }

    /// Initializes the store with a reducer, an initial state and a list of middleware.
    ///
    /// Middleware is applied in the order in which it is passed into this constructor.
    ///
    /// - parameter reducer: Main reducer that processes incoming actions.
    /// - parameter state: Initial state, if any. Can be `nil` and will be 
    ///   provided by the reducer in that case.
    /// - parameter middleware: Ordered list of action pre-processors, acting 
    ///   before the root reducer.
    /// - parameter automaticallySkipsRepeats: If `true`, the store will attempt 
    ///   to skip idempotent state updates when a subscriber's state type 
    ///   implements `Equatable`. Defaults to `true`.
    required init(
        reducer: @escaping ReSwift_Reducer<State>,
        state: State?,
        middleware: [ReSwift_Middleware<State>] = [],
        automaticallySkipsRepeats: Bool = true
    ) {
        self.subscriptionsAutomaticallySkipRepeats = automaticallySkipsRepeats
        self.reducer = reducer
        self.middleware = middleware

        if let state = state {
            self.state = state
        } else {
            dispatch(ReSwift_ReSwiftInit())
        }
    }

    private func createDispatchFunction() -> ReSwift_DispatchFunction! {
        // Wrap the dispatch function with all middlewares
        return middleware
            .reversed()
            .reduce(
                { [unowned self] action in
                    self._defaultDispatch(action: action) },
                { dispatchFunction, middleware in
                    // If the store get's deinitialized before the middleware is complete; drop
                    // the action without dispatching.
                    let dispatch: (ReSwift_Action) -> Void = { [weak self] in self?.dispatch($0) }
                    let getState = { [weak self] in self?.state }
                    return middleware(dispatch, getState)(dispatchFunction)
            })
    }

    fileprivate func _subscribe<SelectedState, S: ReSwift_StoreSubscriber>(
        _ subscriber: S, originalSubscription: ReSwift_Subscription<State>,
        transformedSubscription: ReSwift_Subscription<SelectedState>?)
        where S.StoreSubscriberStateType == SelectedState
    {
        let subscriptionBox = self.subscriptionBox(
            originalSubscription: originalSubscription,
            transformedSubscription: transformedSubscription,
            subscriber: subscriber
        )

        subscriptions.update(with: subscriptionBox)

        if let state = self.state {
            originalSubscription.newValues(oldState: nil, newState: state)
        }
    }

    func subscribe<S: ReSwift_StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
      subscribe(subscriber, transform: nil)
    }

    func subscribe<SelectedState, S: ReSwift_StoreSubscriber>(
        _ subscriber: S, transform: ((ReSwift_Subscription<State>) -> ReSwift_Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    {
        // Create a subscription for the new subscriber.
        let originalSubscription = ReSwift_Subscription<State>()
        // Call the optional transformation closure. This allows callers to modify
        // the subscription, e.g. in order to subselect parts of the store's state.
        let transformedSubscription = transform?(originalSubscription)

        _subscribe(subscriber, originalSubscription: originalSubscription,
                   transformedSubscription: transformedSubscription)
    }

    func subscriptionBox<T>(
        originalSubscription: ReSwift_Subscription<State>,
        transformedSubscription: ReSwift_Subscription<T>?,
        subscriber: ReSwift_AnyStoreSubscriber
        ) -> ReSwift_SubscriptionBox<State> {

        return ReSwift_SubscriptionBox(
            originalSubscription: originalSubscription,
            transformedSubscription: transformedSubscription,
            subscriber: subscriber
        )
    }

    func unsubscribe(_ subscriber: ReSwift_AnyStoreSubscriber) {
        #if swift(>=5.0)
        if let index = subscriptions.firstIndex(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
        #else
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
        #endif
    }

    // swiftlint:disable:next identifier_name
    func _defaultDispatch(action: ReSwift_Action) {
        guard !isDispatching.value else {
            ReSwift_raiseFatalError(
                "ReSwift:ConcurrentMutationError- Action has been dispatched while" +
                " a previous action is action is being processed. A reducer" +
                " is dispatching an action, or ReSwift is used in a concurrent context" +
                " (e.g. from multiple threads)."
            )
        }

        isDispatching.value = true
        let newState = reducer(action, state)
        isDispatching.value = false

        state = newState
    }

    func dispatch(_ action: ReSwift_Action) {
        dispatchFunction(action)
    }

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    func dispatch(_ actionCreatorProvider: @escaping ActionCreator) {
        if let action = actionCreatorProvider(state, self) {
            dispatch(action)
        }
    }

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    func dispatch(_ asyncActionCreatorProvider: @escaping AsyncActionCreator) {
        dispatch(asyncActionCreatorProvider, callback: nil)
    }

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    func dispatch(_ actionCreatorProvider: @escaping AsyncActionCreator,
                       callback: DispatchCallback?) {
        actionCreatorProvider(state, self) { actionProvider in
            let action = actionProvider(self.state, self)

            if let action = action {
                self.dispatch(action)
                callback?(self.state)
            }
        }
    }

    typealias DispatchCallback = (State) -> Void

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    typealias ActionCreator = (_ state: State, _ store: ReSwift_Store) -> ReSwift_Action?

    @available(*, deprecated, message: "Deprecated in favor of https://github.com/ReSwift/ReSwift-Thunk")
    typealias AsyncActionCreator = (
        _ state: State,
        _ store: ReSwift_Store,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
    ) -> Void
}

// MARK: Skip Repeats for Equatable States

extension ReSwift_Store {
    func subscribe<SelectedState: Equatable, S: ReSwift_StoreSubscriber>(
        _ subscriber: S, transform: ((ReSwift_Subscription<State>) -> ReSwift_Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState
    {
        let originalSubscription = ReSwift_Subscription<State>()

        var transformedSubscription = transform?(originalSubscription)
        if subscriptionsAutomaticallySkipRepeats {
            transformedSubscription = transformedSubscription?.skipRepeats()
        }
        _subscribe(subscriber, originalSubscription: originalSubscription,
                   transformedSubscription: transformedSubscription)
    }
}

extension ReSwift_Store where State: Equatable {
    func subscribe<S: ReSwift_StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            guard subscriptionsAutomaticallySkipRepeats else {
              subscribe(subscriber, transform: nil)
                return
            }
      subscribe(subscriber, transform: { $0.skipRepeats() })
    }
}
