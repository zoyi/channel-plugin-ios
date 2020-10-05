//
//  Mappable.swift
//  ObjectMapper
//
//  Created by Scott Hoyt on 10/25/15.
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

/// BaseMappable should not be implemented directly. Mappable or StaticMappable should be used instead
protocol ObjectMapper_BaseMappable {
	/// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
	mutating func mapping(map: ObjectMapper_Map)
}

protocol ObjectMapper_Mappable: ObjectMapper_BaseMappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: ObjectMapper_Map)
}

protocol ObjectMapper_StaticMappable: ObjectMapper_BaseMappable {
	/// This is function that can be used to:
	///		1) provide an existing cached object to be used for mapping
	///		2) return an object of another class (which conforms to BaseMappable) to be used for mapping. For instance, you may inspect the JSON to infer the type of object that should be used for any given mapping
	static func objectForMapping(map: ObjectMapper_Map) -> ObjectMapper_BaseMappable?
}

extension ObjectMapper_Mappable {
	
	/// Initializes object from a JSON String
	init?(JSONString: String, context: ObjectMapper_MapContext? = nil) {
		if let obj: Self = ObjectMapper_Mapper(context: context).map(JSONString: JSONString) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Initializes object from a JSON Dictionary
	init?(JSON: [String: Any], context: ObjectMapper_MapContext? = nil) {
		if let obj: Self = ObjectMapper_Mapper(context: context).map(JSON: JSON) {
			self = obj
		} else {
			return nil
		}
	}
}

extension ObjectMapper_BaseMappable {

	/// Returns the JSON Dictionary for the object
	func toJSON() -> [String: Any] {
		return ObjectMapper_Mapper().toJSON(self)
	}

	/// Returns the JSON String for the object
	func toJSONString(prettyPrint: Bool = false) -> String? {
		return ObjectMapper_Mapper().toJSONString(self, prettyPrint: prettyPrint)
	}
}

extension Array where Element: ObjectMapper_BaseMappable {
	
	/// Initialize Array from a JSON String
	init?(JSONString: String, context: ObjectMapper_MapContext? = nil) {
		if let obj: [Element] = ObjectMapper_Mapper(context: context).mapArray(JSONString: JSONString) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Initialize Array from a JSON Array
	init(JSONArray: [[String: Any]], context: ObjectMapper_MapContext? = nil) {
		let obj: [Element] = ObjectMapper_Mapper(context: context).mapArray(JSONArray: JSONArray)
		self = obj
	}
	
	/// Returns the JSON Array
	func toJSON() -> [[String: Any]] {
		return ObjectMapper_Mapper().toJSONArray(self)
	}
	
	/// Returns the JSON String for the object
	func toJSONString(prettyPrint: Bool = false) -> String? {
		return ObjectMapper_Mapper().toJSONString(self, prettyPrint: prettyPrint)
	}
}

extension Set where Element: ObjectMapper_BaseMappable {
	
	/// Initializes a set from a JSON String
	init?(JSONString: String, context: ObjectMapper_MapContext? = nil) {
		if let obj: Set<Element> = ObjectMapper_Mapper(context: context).mapSet(JSONString: JSONString) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Initializes a set from JSON
	init?(JSONArray: [[String: Any]], context: ObjectMapper_MapContext? = nil) {
		guard let obj = ObjectMapper_Mapper(context: context).mapSet(JSONArray: JSONArray) as Set<Element>? else {
            return nil
        }
		self = obj
	}
	
	/// Returns the JSON Set
	func toJSON() -> [[String: Any]] {
		return ObjectMapper_Mapper().toJSONSet(self)
	}
	
	/// Returns the JSON String for the object
	func toJSONString(prettyPrint: Bool = false) -> String? {
		return ObjectMapper_Mapper().toJSONString(self, prettyPrint: prettyPrint)
	}
}
