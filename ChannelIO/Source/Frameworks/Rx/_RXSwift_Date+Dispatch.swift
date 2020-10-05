//
//  Date+Dispatch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/14/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.TimeInterval
import enum Dispatch.DispatchTimeInterval

extension DispatchTimeInterval {
    var _RXSwift_convertToSecondsFactor: Double {
        switch self {
        case .nanoseconds: return 1_000_000_000.0
        case .microseconds: return 1_000_000.0
        case .milliseconds: return 1_000.0
        case .seconds: return 1.0
        case .never: fatalError()
        @unknown default: fatalError()
        }
    }
 
    func _RXSwift_map(_ transform: (Int, Double) -> Int) -> DispatchTimeInterval {
        switch self {
        case .nanoseconds(let value): return .nanoseconds(transform(value, 1_000_000_000.0))
        case .microseconds(let value): return .microseconds(transform(value, 1_000_000.0))
        case .milliseconds(let value): return .milliseconds(transform(value, 1_000.0))
        case .seconds(let value): return .seconds(transform(value, 1.0))
        case .never: return .never
        @unknown default: fatalError()
        }
    }
    
    var _RXSwift_isNow: Bool {
        switch self {
        case .nanoseconds(let value), .microseconds(let value), .milliseconds(let value), .seconds(let value): return value == 0
        case .never: return false
        @unknown default: fatalError()
        }
    }
    
    internal func _RXSwift_reduceWithSpanBetween(earlierDate: Date, laterDate: Date) -> DispatchTimeInterval {
        return self._RXSwift_map { value, factor in
            let interval = laterDate.timeIntervalSince(earlierDate)
            let remainder = Double(value) - interval * factor
            guard remainder > 0 else { return 0 }
            return Int(remainder.rounded(.toNearestOrAwayFromZero))
        }
    }
}

extension Date {

    internal func _RXSwift_addingDispatchInterval(_ dispatchInterval: DispatchTimeInterval) -> Date {
        switch dispatchInterval {
        case .nanoseconds(let value), .microseconds(let value), .milliseconds(let value), .seconds(let value):
            return self.addingTimeInterval(TimeInterval(value) / dispatchInterval._RXSwift_convertToSecondsFactor)
        case .never: return Date.distantFuture
        @unknown default: fatalError()
        }
    }
    
}
