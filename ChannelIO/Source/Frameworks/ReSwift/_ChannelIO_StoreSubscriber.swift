//
//  StoreSubscriber.swift
//  ReSwift
//
//  Created by Benjamin Encz on 12/14/15.
//  Copyright © 2015 ReSwift Community. All rights reserved.
//

protocol ReSwift_AnyStoreSubscriber: AnyObject {
    // swiftlint:disable:next identifier_name
    func _newState(state: Any)
}

protocol ReSwift_StoreSubscriber: ReSwift_AnyStoreSubscriber {
    associatedtype StoreSubscriberStateType

    func newState(state: StoreSubscriberStateType)
}

extension ReSwift_StoreSubscriber {
    // swiftlint:disable:next identifier_name
    func _newState(state: Any) {
        if let typedState = state as? StoreSubscriberStateType {
            newState(state: typedState)
        }
    }
}
