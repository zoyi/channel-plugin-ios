//
//  ToJSON.swift
//  ObjectMapper
//
//  Created by Tristan Himmelman on 2014-10-13.
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

private func ObjectMapper_setValue(_ value: Any, map: ObjectMapper_Map) {
	ObjectMapper_setValue(value, key: map.currentKey!, checkForNestedKeys: map.keyIsNested, delimiter: map.nestedKeyDelimiter, dictionary: &map.JSON)
}

private func ObjectMapper_setValue(_ value: Any, key: String, checkForNestedKeys: Bool, delimiter: String, dictionary: inout [String : Any]) {
	if checkForNestedKeys {
		let keyComponents = ArraySlice(key.components(separatedBy: delimiter).filter { !$0.isEmpty }.map { $0 })
		ObjectMapper_setValue(value, forKeyPathComponents: keyComponents, dictionary: &dictionary)
	} else {
		dictionary[key] = value
	}
}

private func ObjectMapper_setValue(_ value: Any, forKeyPathComponents components: ArraySlice<String>, dictionary: inout [String : Any]) {
	guard let head = components.first else {
		return
	}

	let headAsString = String(head)
	if components.count == 1 {
		dictionary[headAsString] = value
	} else {
		var child = dictionary[headAsString] as? [String : Any] ?? [:]
		
		let tail = components.dropFirst()
		ObjectMapper_setValue(value, forKeyPathComponents: tail, dictionary: &child)

		dictionary[headAsString] = child
	}
}

internal final class ObjectMapper_ToJSON {
	
	class func basicType<N>(_ field: N, map: ObjectMapper_Map) {
		if let x = field as Any? , false
			|| x is NSNumber // Basic types
			|| x is Bool
			|| x is Int
			|| x is Double
			|| x is Float
			|| x is String
			|| x is NSNull
			|| x is Array<NSNumber> // Arrays
			|| x is Array<Bool>
			|| x is Array<Int>
			|| x is Array<Double>
			|| x is Array<Float>
			|| x is Array<String>
			|| x is Array<Any>
			|| x is Array<Dictionary<String, Any>>
			|| x is Dictionary<String, NSNumber> // Dictionaries
			|| x is Dictionary<String, Bool>
			|| x is Dictionary<String, Int>
			|| x is Dictionary<String, Double>
			|| x is Dictionary<String, Float>
			|| x is Dictionary<String, String>
			|| x is Dictionary<String, Any>
		{
			ObjectMapper_setValue(x, map: map)
		}
	}
	
	class func optionalBasicType<N>(_ field: N?, map: ObjectMapper_Map) {
		if let field = field {
			basicType(field, map: map)
		} else if map.shouldIncludeNilValues {
			basicType(NSNull(), map: map)  //If BasicType is nil, emit NSNull into the JSON output
		}
	}

	class func object<N: ObjectMapper_BaseMappable>(_ field: N, map: ObjectMapper_Map) {
		if let result = ObjectMapper_Mapper(context: map.context, shouldIncludeNilValues: map.shouldIncludeNilValues).toJSON(field) as Any? {
			ObjectMapper_setValue(result, map: map)
		}
	}
	
	class func optionalObject<N: ObjectMapper_BaseMappable>(_ field: N?, map: ObjectMapper_Map) {
		if let field = field {
			object(field, map: map)
		} else if map.shouldIncludeNilValues {
			basicType(NSNull(), map: map)  //If field is nil, emit NSNull into the JSON output
		}
	}

	class func objectArray<N: ObjectMapper_BaseMappable>(_ field: Array<N>, map: ObjectMapper_Map) {
		let JSONObjects = ObjectMapper_Mapper(context: map.context, shouldIncludeNilValues: map.shouldIncludeNilValues).toJSONArray(field)
		
		ObjectMapper_setValue(JSONObjects, map: map)
	}
	
	class func optionalObjectArray<N: ObjectMapper_BaseMappable>(_ field: Array<N>?, map: ObjectMapper_Map) {
		if let field = field {
			objectArray(field, map: map)
		}
	}
	
	class func twoDimensionalObjectArray<N: ObjectMapper_BaseMappable>(_ field: Array<Array<N>>, map: ObjectMapper_Map) {
		var array = [[[String: Any]]]()
		for innerArray in field {
			let JSONObjects = ObjectMapper_Mapper(context: map.context, shouldIncludeNilValues: map.shouldIncludeNilValues).toJSONArray(innerArray)
			array.append(JSONObjects)
		}
		ObjectMapper_setValue(array, map: map)
	}
	
	class func optionalTwoDimensionalObjectArray<N: ObjectMapper_BaseMappable>(_ field: Array<Array<N>>?, map: ObjectMapper_Map) {
		if let field = field {
			twoDimensionalObjectArray(field, map: map)
		}
	}
	
	class func objectSet<N: ObjectMapper_BaseMappable>(_ field: Set<N>, map: ObjectMapper_Map) {
		let JSONObjects = ObjectMapper_Mapper(context: map.context, shouldIncludeNilValues: map.shouldIncludeNilValues).toJSONSet(field)
		
		ObjectMapper_setValue(JSONObjects, map: map)
	}
	
	class func optionalObjectSet<N: ObjectMapper_BaseMappable>(_ field: Set<N>?, map: ObjectMapper_Map) {
		if let field = field {
			objectSet(field, map: map)
		}
	}
	
	class func objectDictionary<N: ObjectMapper_BaseMappable>(_ field: Dictionary<String, N>, map: ObjectMapper_Map) {
		let JSONObjects = ObjectMapper_Mapper(context: map.context, shouldIncludeNilValues: map.shouldIncludeNilValues).toJSONDictionary(field)
		
		ObjectMapper_setValue(JSONObjects, map: map)
	}

	class func optionalObjectDictionary<N: ObjectMapper_BaseMappable>(_ field: Dictionary<String, N>?, map: ObjectMapper_Map) {
		if let field = field {
			objectDictionary(field, map: map)
		}
	}

	class func objectDictionaryOfArrays<N: ObjectMapper_BaseMappable>(_ field: Dictionary<String, [N]>, map: ObjectMapper_Map) {
		let JSONObjects = ObjectMapper_Mapper(context: map.context, shouldIncludeNilValues: map.shouldIncludeNilValues).toJSONDictionaryOfArrays(field)

		ObjectMapper_setValue(JSONObjects, map: map)
	}
	
	class func optionalObjectDictionaryOfArrays<N: ObjectMapper_BaseMappable>(_ field: Dictionary<String, [N]>?, map: ObjectMapper_Map) {
		if let field = field {
			objectDictionaryOfArrays(field, map: map)
		}
	}
}
