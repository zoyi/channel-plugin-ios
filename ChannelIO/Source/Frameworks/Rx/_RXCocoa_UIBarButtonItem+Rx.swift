//
//  UIBarButtonItem+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

private var rx_tap_key: UInt8 = 0

extension _RXSwift_Reactive where Base: UIBarButtonItem {
    
    /// Bindable sink for `enabled` property.
    var isEnabled: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { element, value in
            element.isEnabled = value
        }
    }
    
    /// Bindable sink for `title` property.
    var title: _RXCocoa_Binder<String> {
        return _RXCocoa_Binder(self.base) { element, value in
            element.title = value
        }
    }

    /// Reactive wrapper for target action pattern on `self`.
    var tap: _RXCocoa_ControlEvent<()> {
        let source = lazyInstanceObservable(&rx_tap_key) { () -> _RXSwift_Observable<()> in
            _RXSwift_Observable.create { [weak control = self.base] observer in
                guard let control = control else {
                    observer.on(.completed)
                    return _RXSwift_Disposables.create()
                }
                let target = _RXCocoa_BarButtonItemTarget(barButtonItem: control) {
                    observer.on(.next(()))
                }
                return target
            }
            .takeUntil(self.deallocated)
            .share()
        }
        
        return _RXCocoa_ControlEvent(events: source)
    }
}


@objc
final class _RXCocoa_BarButtonItemTarget: _RXCocoa_RxTarget {
    typealias Callback = () -> Void
    
    weak var barButtonItem: UIBarButtonItem?
    var callback: Callback!
    
    init(barButtonItem: UIBarButtonItem, callback: @escaping () -> Void) {
        self.barButtonItem = barButtonItem
        self.callback = callback
        super.init()
        barButtonItem.target = self
        barButtonItem.action = #selector(_RXCocoa_BarButtonItemTarget.action(_:))
    }
    
    override func dispose() {
        super.dispose()
#if DEBUG
        _RXSwift_MainScheduler.ensureRunningOnMainThread()
#endif
        
        barButtonItem?.target = nil
        barButtonItem?.action = nil
        
        callback = nil
    }
    
    @objc func action(_ sender: AnyObject) {
        callback()
    }
    
}

#endif
