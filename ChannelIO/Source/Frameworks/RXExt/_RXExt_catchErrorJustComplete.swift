//
//  catchErrorJustComplete.swift
//  RxSwiftExt
//
//  Created by Florent Pillet on 21/05/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

//import RxSwift

extension _RXSwift_ObservableType {
    /**
     Dismiss errors and complete the sequence instead
     
     - returns: An observable sequence that never errors and completes when an error occurs in the underlying sequence
     */
    func catchErrorJustComplete() -> _RXSwift_Observable<Element> {
        return catchError { _ in
            return _RXSwift_Observable.empty()
        }
    }
}
