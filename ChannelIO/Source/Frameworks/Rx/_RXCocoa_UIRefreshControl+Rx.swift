//
//  UIRefreshControl+Rx.swift
//  RxCocoa
//
//  Created by Yosuke Ishikawa on 1/31/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UIRefreshControl {
    /// Bindable sink for `beginRefreshing()`, `endRefreshing()` methods.
    var isRefreshing: _RXCocoa_Binder<Bool> {
        return _RXCocoa_Binder(self.base) { refreshControl, refresh in
            if refresh {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }

}

#endif
