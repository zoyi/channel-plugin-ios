//
//  RxTarget.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSObject

//import RxSwift

class _RXCocoa_RxTarget : NSObject
               , _RXSwift_Disposable {
    
    private var retainSelf: _RXCocoa_RxTarget?
    
    override init() {
        super.init()
        self.retainSelf = self

#if TRACE_RESOURCES
        _ = Resources.incrementTotal()
#endif

#if DEBUG
        _RXSwift_MainScheduler.ensureRunningOnMainThread()
#endif
    }
    
    func dispose() {
#if DEBUG
        _RXSwift_MainScheduler.ensureRunningOnMainThread()
#endif
        self.retainSelf = nil
    }

#if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
#endif
}
