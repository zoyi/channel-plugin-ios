//
//  NotificationCenter+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NotificationCenter
import struct Foundation.Notification

//import RxSwift

extension _RXSwift_Reactive where Base: NotificationCenter {
    /**
    Transforms notifications posted to notification center to observable sequence of notifications.
    
    - parameter name: Optional name used to filter notifications.
    - parameter object: Optional object used to filter notifications.
    - returns: Observable sequence of posted notifications.
    */
    func notification(_ name: Notification.Name?, object: AnyObject? = nil) -> _RXSwift_Observable<Notification> {
        return _RXSwift_Observable.create { [weak object] observer in
            let nsObserver = self.base.addObserver(forName: name, object: object, queue: nil) { notification in
                observer.on(.next(notification))
            }
            
            return _RXSwift_Disposables.create {
                self.base.removeObserver(nsObserver)
            }
        }
    }
}
