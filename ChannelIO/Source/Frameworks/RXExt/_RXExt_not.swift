//
//  ignore.swift
//  RxSwiftExt
//
//  Created by Thane Gill on 18/04/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//

import Foundation
//import RxSwift

extension _RXSwift_ObservableType where Element == Bool {
    /// Boolean not operator
    func not() -> _RXSwift_Observable<Bool> {
        return self.map(!)
    }
}
