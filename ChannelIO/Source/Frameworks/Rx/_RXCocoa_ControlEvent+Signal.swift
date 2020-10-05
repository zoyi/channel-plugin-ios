//
//  ControlEvent+Signal.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 11/1/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

extension _RXCocoa_ControlEvent {
    /// Converts `ControlEvent` to `Signal` trait.
    ///
    /// `ControlEvent` already can't fail, so no special case needs to be handled.
    func asSignal() -> _RXCocoa_Signal<Element> {
        return self.asSignal { _ -> _RXCocoa_Signal<Element> in
            #if DEBUG
                _RXCocoa_rxFatalError("Somehow signal received error from a source that shouldn't fail.")
            #else
                return _RXCocoa_Signal.empty()
            #endif
        }
    }
}

