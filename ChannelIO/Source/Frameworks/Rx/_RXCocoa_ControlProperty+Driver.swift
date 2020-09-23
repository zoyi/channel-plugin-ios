//
//  ControlProperty+Driver.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

extension _RXCocoa_ControlProperty {
    /// Converts `ControlProperty` to `Driver` trait.
    ///
    /// `ControlProperty` already can't fail, so no special case needs to be handled.
    public func asDriver() -> _RXCocoa_Driver<Element> {
        return self.asDriver { _ -> _RXCocoa_Driver<Element> in
            #if DEBUG
                _RXCocoa_rxFatalError("Somehow driver received error from a source that shouldn't fail.")
            #else
                return Driver.empty()
            #endif
        }
    }
}
