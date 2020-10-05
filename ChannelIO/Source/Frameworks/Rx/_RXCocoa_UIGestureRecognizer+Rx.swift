//
//  UIGestureRecognizer+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 10/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

// This should be only used from `MainScheduler`
final class _RXCocoa_GestureTarget<Recognizer: UIGestureRecognizer>: _RXCocoa_RxTarget {
    typealias Callback = (Recognizer) -> Void
    
    let selector = #selector(_RXCocoa_ControlTarget.eventHandler(_:))
    
    weak var gestureRecognizer: Recognizer?
    var callback: Callback?
    
    init(_ gestureRecognizer: Recognizer, callback: @escaping Callback) {
        self.gestureRecognizer = gestureRecognizer
        self.callback = callback
        
        super.init()
        
        gestureRecognizer.addTarget(self, action: selector)

        let method = self.method(for: selector)
        if method == nil {
            fatalError("Can't find method")
        }
    }
    
    @objc func eventHandler(_ sender: UIGestureRecognizer) {
        if let callback = self.callback, let gestureRecognizer = self.gestureRecognizer {
            callback(gestureRecognizer)
        }
    }
    
    override func dispose() {
        super.dispose()
        
        self.gestureRecognizer?.removeTarget(self, action: self.selector)
        self.callback = nil
    }
}

extension _RXSwift_Reactive where Base: UIGestureRecognizer {
    
    /// Reactive wrapper for gesture recognizer events.
    var event: _RXCocoa_ControlEvent<Base> {
        let source: _RXSwift_Observable<Base> = _RXSwift_Observable.create { [weak control = self.base] observer in
            _RXSwift_MainScheduler.ensureRunningOnMainThread()

            guard let control = control else {
                observer.on(.completed)
                return _RXSwift_Disposables.create()
            }
            
            let observer = _RXCocoa_GestureTarget(control) { control in
                observer.on(.next(control))
            }
            
            return observer
        }.takeUntil(deallocated)
        
        return _RXCocoa_ControlEvent(events: source)
    }
    
}

#endif
