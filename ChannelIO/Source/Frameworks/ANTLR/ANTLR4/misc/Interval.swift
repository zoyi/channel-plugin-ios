/// 
/// Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
/// Use of this file is governed by the BSD 3-clause license that
/// can be found in the LICENSE.txt file in the project root.
/// 


/// 
/// An immutable inclusive interval a..b
/// 

class Interval: Hashable {
    static let INTERVAL_POOL_MAX_VALUE: Int = 1000

    static let INVALID: Interval = Interval(-1, -2)

    //static var cache: Dictionary<Int, Interval> = Dictionary<Int, Interval>()
    static var cache: Array<Interval?> = Array<Interval?>(repeating: nil, count: INTERVAL_POOL_MAX_VALUE + 1)
    // new; Interval[INTERVAL_POOL_MAX_VALUE+1];

    var a: Int
    var b: Int

    static var creates: Int = 0
    static var misses: Int = 0
    static var hits: Int = 0
    static var outOfRange: Int = 0

    init(_ a: Int, _ b: Int) {
        self.a = a
        self.b = b
    }

    /// 
    /// Interval objects are used readonly so share all with the
    /// same single value a==b up to some max size.  Use an array as a perfect hash.
    /// Return shared object for 0..INTERVAL_POOL_MAX_VALUE or a new
    /// Interval object with a..a in it.  On Java.g4, 218623 IntervalSets
    /// have a..a (set with 1 element).
    /// 
    static func of(_ a: Int, _ b: Int) -> Interval {
        // cache just a..a
        if a != b || a < 0 || a > INTERVAL_POOL_MAX_VALUE {
            return Interval(a, b)
        }
        if cache[a] == nil {
            cache[a] = Interval(a, a)
        }

        return cache[a]!
    }

    /// 
    /// return number of elements between a and b inclusively. x..x is length 1.
    /// if b &lt; a, then length is 0.  9..10 has length 2.
    /// 
    func length() -> Int {
        if b < a {
            return 0
        }
        return b - a + 1
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(b)
    }

    ///
    /// Does this start completely before other? Disjoint
    /// 
    func startsBeforeDisjoint(_ other: Interval) -> Bool {
        return self.a < other.a && self.b < other.a
    }

    /// 
    /// Does this start at or before other? Nondisjoint
    /// 
    func startsBeforeNonDisjoint(_ other: Interval) -> Bool {
        return self.a <= other.a && self.b >= other.a
    }

    /// 
    /// Does this.a start after other.b? May or may not be disjoint
    /// 
    func startsAfter(_ other: Interval) -> Bool {
        return self.a > other.a
    }

    /// 
    /// Does this start completely after other? Disjoint
    /// 
    func startsAfterDisjoint(_ other: Interval) -> Bool {
        return self.a > other.b
    }

    /// 
    /// Does this start after other? NonDisjoint
    /// 
    func startsAfterNonDisjoint(_ other: Interval) -> Bool {
        return self.a > other.a && self.a <= other.b // this.b>=other.b implied
    }

    /// 
    /// Are both ranges disjoint? I.e., no overlap?
    /// 
    func disjoint(_ other: Interval) -> Bool {
        return startsBeforeDisjoint(other) || startsAfterDisjoint(other)
    }

    /// 
    /// Are two intervals adjacent such as 0..41 and 42..42?
    /// 
    func adjacent(_ other: Interval) -> Bool {
        return self.a == other.b + 1 || self.b == other.a - 1
    }

    func properlyContains(_ other: Interval) -> Bool {
        return other.a >= self.a && other.b <= self.b
    }

    /// 
    /// Return the interval computed from combining this and other
    /// 
    func union(_ other: Interval) -> Interval {
        return Interval.of(min(a, other.a), max(b, other.b))
    }

    /// 
    /// Return the interval in common between this and o
    /// 
    func intersection(_ other: Interval) -> Interval {
        return Interval.of(max(a, other.a), min(b, other.b))
    }

    /// 
    /// Return the interval with elements from this not in other;
    /// other must not be totally enclosed (properly contained)
    /// within this, which would result in two disjoint intervals
    /// instead of the single one returned by this method.
    /// 
    func differenceNotProperlyContained(_ other: Interval) -> Interval? {
        var diff: Interval? = nil
        // other.a to left of this.a (or same)
        if other.startsBeforeNonDisjoint(self) {
            diff = Interval.of(max(self.a, other.b + 1),
                    self.b)
        }

                // other.a to right of this.a
        else {
            if other.startsAfterNonDisjoint(self) {
                diff = Interval.of(self.a, other.a - 1)
            }
        }
        return diff
    }


   var description: String {
        return "\(a)..\(b)"
    }
}

func ==(lhs: Interval, rhs: Interval) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b
}
