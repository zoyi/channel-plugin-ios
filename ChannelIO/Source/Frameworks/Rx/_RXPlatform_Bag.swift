//
//  Bag.swift
//  Platform
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Swift

let _RXPlatform_arrayDictionaryMaxSize = 30

struct _RXPlatform_BagKey {
    /**
    Unique identifier for object added to `Bag`.
     
    It's underlying type is UInt64. If we assume there in an idealized CPU that works at 4GHz,
     it would take ~150 years of continuous running time for it to overflow.
    */
    fileprivate let rawValue: UInt64
}

/**
Data structure that represents a bag of elements typed `T`.

Single element can be stored multiple times.

Time and space complexity of insertion and deletion is O(n). 

It is suitable for storing small number of elements.
*/
struct _RXPlatform_Bag<T> : CustomDebugStringConvertible {
    /// Type of identifier for inserted elements.
    typealias KeyType = _RXPlatform_BagKey
    
    typealias Entry = (key: _RXPlatform_BagKey, value: T)
 
    private var _nextKey: _RXPlatform_BagKey = _RXPlatform_BagKey(rawValue: 0)

    // data

    // first fill inline variables
    var _key0: _RXPlatform_BagKey?
    var _value0: T?

    // then fill "array dictionary"
    var _pairs = ContiguousArray<Entry>()

    // last is sparse dictionary
    var _dictionary: [_RXPlatform_BagKey: T]?

    var _onlyFastPath = true

    /// Creates new empty `Bag`.
    init() {
    }
    
    /**
    Inserts `value` into bag.
    
    - parameter element: Element to insert.
    - returns: Key that can be used to remove element from bag.
    */
    mutating func insert(_ element: T) -> _RXPlatform_BagKey {
        let key = _nextKey

        _nextKey = _RXPlatform_BagKey(rawValue: _nextKey.rawValue &+ 1)

        if _key0 == nil {
            _key0 = key
            _value0 = element
            return key
        }

        _onlyFastPath = false

        if _dictionary != nil {
            _dictionary![key] = element
            return key
        }

        if _pairs.count < _RXPlatform_arrayDictionaryMaxSize {
            _pairs.append((key: key, value: element))
            return key
        }
        
        _dictionary = [key: element]
        
        return key
    }
    
    /// - returns: Number of elements in bag.
    var count: Int {
        let dictionaryCount: Int = _dictionary?.count ?? 0
        return (_value0 != nil ? 1 : 0) + _pairs.count + dictionaryCount
    }
    
    /// Removes all elements from bag and clears capacity.
    mutating func removeAll() {
        _key0 = nil
        _value0 = nil

        _pairs.removeAll(keepingCapacity: false)
        _dictionary?.removeAll(keepingCapacity: false)
    }
    
    /**
    Removes element with a specific `key` from bag.
    
    - parameter key: Key that identifies element to remove from bag.
    - returns: Element that bag contained, or nil in case element was already removed.
    */
    mutating func removeKey(_ key: _RXPlatform_BagKey) -> T? {
        if _key0 == key {
            _key0 = nil
            let value = _value0!
            _value0 = nil
            return value
        }

        if let existingObject = _dictionary?.removeValue(forKey: key) {
            return existingObject
        }

        for i in 0 ..< _pairs.count where _pairs[i].key == key {
            let value = _pairs[i].value
            _pairs.remove(at: i)
            return value
        }

        return nil
    }
}

extension _RXPlatform_Bag {
    /// A textual representation of `self`, suitable for debugging.
    var debugDescription : String {
        return "\(self.count) elements in Bag"
    }
}

extension _RXPlatform_Bag {
    /// Enumerates elements inside the bag.
    ///
    /// - parameter action: Enumeration closure.
    func forEach(_ action: (T) -> Void) {
        if _onlyFastPath {
            if let value0 = _value0 {
                action(value0)
            }
            return
        }

        let value0 = _value0
        let dictionary = _dictionary

        if let value0 = value0 {
            action(value0)
        }

        for i in 0 ..< _pairs.count {
            action(_pairs[i].value)
        }

        if dictionary?.count ?? 0 > 0 {
            for element in dictionary!.values {
                action(element)
            }
        }
    }
}

extension _RXPlatform_BagKey: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

func ==(lhs: _RXPlatform_BagKey, rhs: _RXPlatform_BagKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
