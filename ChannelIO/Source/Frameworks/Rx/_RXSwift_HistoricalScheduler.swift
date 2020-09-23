//
//  HistoricalScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date

/// Provides a virtual time scheduler that uses `Date` for absolute time and `NSTimeInterval` for relative time.
 class _RXSwift_HistoricalScheduler : _RXSwift_VirtualTimeScheduler<_RXSwift_HistoricalSchedulerTimeConverter> {

    /**
      Creates a new historical scheduler with initial clock value.
     
     - parameter initialClock: Initial value for virtual clock.
    */
     init(initialClock: _RXSwift_RxTime = Date(timeIntervalSince1970: 0)) {
        super.init(initialClock: initialClock, converter: _RXSwift_HistoricalSchedulerTimeConverter())
    }
}
