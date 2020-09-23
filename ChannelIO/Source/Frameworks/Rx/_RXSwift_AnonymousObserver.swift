//
//  AnonymousObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

final class _RXSwift_AnonymousObserver<Element>: _RXSwift_ObserverBase<Element> {
    typealias EventHandler = (_RXSwift_Event<Element>) -> Void
    
    private let _eventHandler : EventHandler
    
    init(_ eventHandler: @escaping EventHandler) {
#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif
        self._eventHandler = eventHandler
    }

    override func onCore(_ event: _RXSwift_Event<Element>) {
        return self._eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
#endif
}
