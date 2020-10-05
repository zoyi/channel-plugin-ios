//
//  HistoricalSchedulerTimeConverter.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// Converts historical virtual time into real time.
///
/// Since historical virtual time is also measured in `Date`, this converter is identity function.
 struct _RXSwift_HistoricalSchedulerTimeConverter : _RXSwift_VirtualTimeConverterType {
    /// Virtual time unit used that represents ticks of virtual clock.
     typealias VirtualTimeUnit = _RXSwift_RxTime

    /// Virtual time unit used to represent differences of virtual times.
     typealias VirtualTimeIntervalUnit = TimeInterval

    /// Returns identical value of argument passed because historical virtual time is equal to real time, just
    /// decoupled from local machine clock.
     func convertFromVirtualTime(_ virtualTime: VirtualTimeUnit) -> _RXSwift_RxTime {
        return virtualTime
    }

    /// Returns identical value of argument passed because historical virtual time is equal to real time, just
    /// decoupled from local machine clock.
     func convertToVirtualTime(_ time: _RXSwift_RxTime) -> VirtualTimeUnit {
        return time
    }

    /// Returns identical value of argument passed because historical virtual time is equal to real time, just
    /// decoupled from local machine clock.
     func convertFromVirtualTimeInterval(_ virtualTimeInterval: VirtualTimeIntervalUnit) -> TimeInterval {
        return virtualTimeInterval
    }

    /// Returns identical value of argument passed because historical virtual time is equal to real time, just
    /// decoupled from local machine clock.
     func convertToVirtualTimeInterval(_ timeInterval: TimeInterval) -> VirtualTimeIntervalUnit {
        return timeInterval
    }

    /**
     Offsets `Date` by time interval.
     
     - parameter time: Time.
     - parameter timeInterval: Time interval offset.
     - returns: Time offsetted by time interval.
    */
     func offsetVirtualTime(_ time: VirtualTimeUnit, offset: VirtualTimeIntervalUnit) -> VirtualTimeUnit {
        return time.addingTimeInterval(offset)
    }

    /// Compares two `Date`s.
     func compareVirtualTime(_ lhs: VirtualTimeUnit, _ rhs: VirtualTimeUnit) -> _RXSwift_VirtualTimeComparison {
        switch lhs.compare(rhs as Date) {
        case .orderedAscending:
            return .lessThan
        case .orderedSame:
            return .equal
        case .orderedDescending:
            return .greaterThan
        }
    }
}
