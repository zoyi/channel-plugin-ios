//
//  SynchronizedDisposeType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_SynchronizedDisposeType : class, _RXSwift_Disposable, _RXSwift_Lock {
    func _synchronized_dispose()
}

extension _RXSwift_SynchronizedDisposeType {
    func synchronizedDispose() {
        self.lock(); defer { self.unlock() }
        self._synchronized_dispose()
    }
}
