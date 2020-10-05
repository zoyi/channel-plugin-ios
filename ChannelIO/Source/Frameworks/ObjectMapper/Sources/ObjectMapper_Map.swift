//
//  Map.swift
//  ObjectMapper
//
//  Created by Tristan Himmelman on 2015-10-09.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014-2018 Tristan Himmelman
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation

/// MapContext is available for developers who wish to pass information around during the mapping process.
protocol ObjectMapper_MapContext {
	
}

/// A class used for holding mapping data
final class ObjectMapper_Map {
	let mappingType: ObjectMapper_MappingType
	
  var JSON: [String: Any] = [:]
  var isKeyPresent = false
  var currentValue: Any?
  var currentKey: String?
	var keyIsNested = false
  var nestedKeyDelimiter: String = "."
	var context: ObjectMapper_MapContext?
	var shouldIncludeNilValues = false  /// If this is set to true, toJSON output will include null values for any variables that are not set.
	
	let toObject: Bool // indicates whether the mapping is being applied to an existing object
	
	init(mappingType: ObjectMapper_MappingType, JSON: [String: Any], toObject: Bool = false, context: ObjectMapper_MapContext? = nil, shouldIncludeNilValues: Bool = false) {
		
		self.mappingType = mappingType
		self.JSON = JSON
		self.toObject = toObject
		self.context = context
		self.shouldIncludeNilValues = shouldIncludeNilValues
	}
	
	/// Sets the current mapper value and key.
	/// The Key paramater can be a period separated string (ex. "distance.value") to access sub objects.
	subscript(key: String) -> ObjectMapper_Map {
		// save key and value associated to it
		return self.subscript(key: key)
	}
	
	subscript(key: String, delimiter delimiter: String) -> ObjectMapper_Map {
		return self.subscript(key: key, delimiter: delimiter)
	}
	
	subscript(key: String, nested nested: Bool) -> ObjectMapper_Map {
		return self.subscript(key: key, nested: nested)
	}
	
	subscript(key: String, nested nested: Bool, delimiter delimiter: String) -> ObjectMapper_Map {
		return self.subscript(key: key, nested: nested, delimiter: delimiter)
	}
	
	subscript(key: String, ignoreNil ignoreNil: Bool) -> ObjectMapper_Map {
		return self.subscript(key: key, ignoreNil: ignoreNil)
	}
	
	subscript(key: String, delimiter delimiter: String, ignoreNil ignoreNil: Bool) -> ObjectMapper_Map {
		return self.subscript(key: key, delimiter: delimiter, ignoreNil: ignoreNil)
	}
	
	subscript(key: String, nested nested: Bool, ignoreNil ignoreNil: Bool) -> ObjectMapper_Map {
		return self.subscript(key: key, nested: nested, ignoreNil: ignoreNil)
	}
	
	subscript(key: String, nested nested: Bool?, delimiter delimiter: String, ignoreNil ignoreNil: Bool) -> ObjectMapper_Map {
		return self.subscript(key: key, nested: nested, delimiter: delimiter, ignoreNil: ignoreNil)
	}
	
	private func `subscript`(key: String, nested: Bool? = nil, delimiter: String = ".", ignoreNil: Bool = false) -> ObjectMapper_Map {
		// save key and value associated to it
		currentKey = key
		keyIsNested = nested ?? key.contains(delimiter)
		nestedKeyDelimiter = delimiter
		
		if mappingType == .fromJSON {
			// check if a value exists for the current key
			// do this pre-check for performance reasons
			if keyIsNested {
				// break down the components of the key that are separated by delimiter
				(isKeyPresent, currentValue) = ObjectMapper_valueFor(ArraySlice(key.components(separatedBy: delimiter)), dictionary: JSON)
			} else {
				let object = JSON[key]
				let isNSNull = object is NSNull
				isKeyPresent = isNSNull ? true : object != nil
				currentValue = isNSNull ? nil : object
			}
			
			// update isKeyPresent if ignoreNil is true
			if ignoreNil && currentValue == nil {
				isKeyPresent = false
			}
		}
		
		return self
	}
	
	func value<T>() -> T? {
		let value = currentValue as? T
		
		// Swift 4.1 breaks Float casting from `NSNumber`. So Added extra checks for `Float` `[Float]` and `[String:Float]`
		if value == nil && T.self == Float.self {
			if let v = currentValue as? NSNumber {
				return v.floatValue as? T
			}
		} else if value == nil && T.self == [Float].self {
			if let v = currentValue as? [Double] {
				#if swift(>=4.1)
				return v.compactMap{ Float($0) } as? T
				#else
				return v.flatMap{ Float($0) } as? T
				#endif
			}
		} else if value == nil && T.self == [String:Float].self {
			if let v = currentValue as? [String:Double] {
				return v.mapValues{ Float($0) } as? T
			}
		}
		return value
	}
}

/// Fetch value from JSON dictionary, loop through keyPathComponents until we reach the desired object
private func ObjectMapper_valueFor(_ keyPathComponents: ArraySlice<String>, dictionary: [String: Any]) -> (Bool, Any?) {
	// Implement it as a tail recursive function.
	if keyPathComponents.isEmpty {
		return (false, nil)
	}
	
	if let keyPath = keyPathComponents.first {
		let isTail = keyPathComponents.count == 1
		let object = dictionary[keyPath]
		if object is NSNull {
			return (isTail, nil)
		} else if keyPathComponents.count > 1, let dict = object as? [String: Any] {
			let tail = keyPathComponents.dropFirst()
			return ObjectMapper_valueFor(tail, dictionary: dict)
		} else if keyPathComponents.count > 1, let array = object as? [Any] {
			let tail = keyPathComponents.dropFirst()
			return ObjectMapper_valueFor(tail, array: array)
		} else {
			return (isTail && object != nil, object)
		}
	}
	
	return (false, nil)
}

/// Fetch value from JSON Array, loop through keyPathComponents them until we reach the desired object
private func ObjectMapper_valueFor(_ keyPathComponents: ArraySlice<String>, array: [Any]) -> (Bool, Any?) {
	// Implement it as a tail recursive function.
	
	if keyPathComponents.isEmpty {
		return (false, nil)
	}
	
	//Try to convert keypath to Int as index
	if let keyPath = keyPathComponents.first,
		let index = Int(keyPath) , index >= 0 && index < array.count {
		
		let isTail = keyPathComponents.count == 1
		let object = array[index]
		
		if object is NSNull {
			return (isTail, nil)
		} else if keyPathComponents.count > 1, let array = object as? [Any]  {
			let tail = keyPathComponents.dropFirst()
			return ObjectMapper_valueFor(tail, array: array)
		} else if  keyPathComponents.count > 1, let dict = object as? [String: Any] {
			let tail = keyPathComponents.dropFirst()
			return ObjectMapper_valueFor(tail, dictionary: dict)
		} else {
			return (isTail, object)
		}
	}
	
	return (false, nil)
}

// MARK: - Default Value

extension ObjectMapper_Map {

	/// Returns `default` value if there is nothing to parse.
  func value<T>(_ key: String, default: T.Object, using transform: T) throws -> T.Object where T: ObjectMapper_TransformType {
    if let value: T.Object = try? self.value(key, using: transform) {
      return value
    } else {
      return `default`
    }
  }

	/// Returns `default` value if there is nothing to parse.
  func value<T>(_ key: String, default: T) throws -> T {
    if let value: T = try? self.value(key) {
      return value
    } else {
      return `default`
    }
  }

	/// Returns `default` value if there is nothing to parse.
  func value<T: ObjectMapper_BaseMappable>(_ key: String, default: [T]) -> [T] {
    do {
      let value: [T] = try self.value(key)
      return value
    } catch {
      return `default`
    }
  }

	/// Returns `default` value if there is nothing to parse.
  func value<T>(_ key: String, default: T) throws -> T where T: ObjectMapper_BaseMappable {
    if let value: T = try? self.value(key) as T {
      return value
    } else {
      return `default`
    }
  }
}
