//
//  Operators.swift
//  ObjectMapper
//
//  Created by Tristan Himmelman on 2014-10-09.
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

/**
* This file defines a new operator which is used to create a mapping between an object and a JSON key value.
* There is an overloaded operator definition for each type of object that is supported in ObjectMapper.
* This provides a way to add custom logic to handle specific types of objects
*/

/// Operator used for defining mappings to and from JSON
infix operator <-

/// Operator used to define mappings to JSON
infix operator >>>>

// MARK:- Objects with Basic types

/// Object of Basic type
func <- <T>(left: inout T, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.basicType(&left, object: right.value())
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T>(left: T, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.basicType(left, map: right)
	}
}


/// Optional object of basic type
func <- <T>(left: inout T?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalBasicType(&left, object: right.value())
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T>(left: T?, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalBasicType(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped optional object of basic type
func <- <T>(left: inout T!, right: Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalBasicType(&left, object: right.value())
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif

// MARK:- Mappable Objects - <T: ObjectMapper_BaseMappable>

/// Object conforming to Mappable
func <- <T: ObjectMapper_BaseMappable>(left: inout T, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON:
		ObjectMapper_FromJSON.object(&left, map: right)
	case .toJSON:
		left >>>> right
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: T, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.object(left, map: right)
	}
}


/// Optional Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout T?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObject(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: T?, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalObject(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped optional Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout T!, right: Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObject(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif

// MARK:- Dictionary of Mappable objects - Dictionary<String, T: ObjectMapper_BaseMappable>

/// Dictionary of Mappable objects <String, T: Mappable>
func <- <T: ObjectMapper_BaseMappable>(left: inout Dictionary<String, T>, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.objectDictionary(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Dictionary<String, T>, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.objectDictionary(left, map: right)
	}
}


/// Optional Dictionary of Mappable object <String, T: Mappable>
func <- <T: ObjectMapper_BaseMappable>(left: inout Dictionary<String, T>?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectDictionary(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Dictionary<String, T>?, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalObjectDictionary(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped Optional Dictionary of Mappable object <String, T: Mappable>
func <- <T: ObjectMapper_BaseMappable>(left: inout Dictionary<String, T>!, right: Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectDictionary(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif

/// Dictionary of Mappable objects <String, T: Mappable>
func <- <T: ObjectMapper_BaseMappable>(left: inout Dictionary<String, [T]>, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.objectDictionaryOfArrays(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Dictionary<String, [T]>, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.objectDictionaryOfArrays(left, map: right)
	}
}

/// Optional Dictionary of Mappable object <String, T: Mappable>
func <- <T: ObjectMapper_BaseMappable>(left: inout Dictionary<String, [T]>?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectDictionaryOfArrays(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Dictionary<String, [T]>?, right:ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalObjectDictionaryOfArrays(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped Optional Dictionary of Mappable object <String, T: Mappable>
func <- <T: ObjectMapper_BaseMappable>(left: inout Dictionary<String, [T]>!, right: Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectDictionaryOfArrays(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif

// MARK:- Array of Mappable objects - Array<T: ObjectMapper_BaseMappable>

/// Array of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Array<T>, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.objectArray(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Array<T>, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.objectArray(left, map: right)
	}
}

/// Optional array of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Array<T>?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectArray(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Array<T>?, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalObjectArray(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped Optional array of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Array<T>!, right: Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectArray(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif

// MARK:- Array of Array of Mappable objects - Array<Array<T: ObjectMapper_BaseMappable>>

/// Array of Array Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Array<Array<T>>, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.twoDimensionalObjectArray(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Array<Array<T>>, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.twoDimensionalObjectArray(left, map: right)
	}
}


/// Optional array of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left:inout Array<Array<T>>?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalTwoDimensionalObjectArray(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Array<Array<T>>?, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalTwoDimensionalObjectArray(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped Optional array of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Array<Array<T>>!, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalTwoDimensionalObjectArray(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif

// MARK:- Set of Mappable objects - Set<T: ObjectMapper_BaseMappable>

/// Set of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Set<T>, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.objectSet(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Set<T>, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.objectSet(left, map: right)
	}
}


/// Optional Set of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Set<T>?, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectSet(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}

func >>>> <T: ObjectMapper_BaseMappable>(left: Set<T>?, right: ObjectMapper_Map) {
	if right.mappingType == .toJSON {
		ObjectMapper_ToJSON.optionalObjectSet(left, map: right)
	}
}


// Code targeting the Swift 4.1 compiler and below.
#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
/// Implicitly unwrapped Optional Set of Mappable objects
func <- <T: ObjectMapper_BaseMappable>(left: inout Set<T>!, right: ObjectMapper_Map) {
	switch right.mappingType {
	case .fromJSON where right.isKeyPresent:
		ObjectMapper_FromJSON.optionalObjectSet(&left, map: right)
	case .toJSON:
		left >>>> right
	default: ()
	}
}
#endif
