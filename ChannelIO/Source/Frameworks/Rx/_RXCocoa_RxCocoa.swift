//
//  RxCocoa.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import class Foundation.NSNull

// Importing RxCocoa also imports RxRelay
//@_exported import RxRelay

//import RxSwift
#if os(iOS)
    import UIKit
#endif

/// RxCocoa errors.
enum _RXCocoa_RxCocoaError
    : Swift.Error
    , CustomDebugStringConvertible {
    /// Unknown error has occurred.
    case unknown
    /// Invalid operation was attempted.
    case invalidOperation(object: Any)
    /// Items are not yet bound to user interface but have been requested.
    case itemsNotYetBound(object: Any)
    /// Invalid KVO Path.
    case invalidPropertyName(object: Any, propertyName: String)
    /// Invalid object on key path.
    case invalidObjectOnKeyPath(object: Any, sourceObject: AnyObject, propertyName: String)
    /// Error during swizzling.
    case errorDuringSwizzling
    /// Casting error.
    case castingError(object: Any, targetType: Any.Type)
}


// MARK: Debug descriptions

extension _RXCocoa_RxCocoaError {
    /// A textual representation of `self`, suitable for debugging.
    var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error occurred."
        case let .invalidOperation(object):
            return "Invalid operation was attempted on `\(object)`."
        case let .itemsNotYetBound(object):
            return "Data source is set, but items are not yet bound to user interface for `\(object)`."
        case let .invalidPropertyName(object, propertyName):
            return "Object `\(object)` doesn't have a property named `\(propertyName)`."
        case let .invalidObjectOnKeyPath(object, sourceObject, propertyName):
            return "Unobservable object `\(object)` was observed as `\(propertyName)` of `\(sourceObject)`."
        case .errorDuringSwizzling:
            return "Error during swizzling."
        case let .castingError(object, targetType):
            return "Error casting `\(object)` to `\(targetType)`"
        }
    }
}



// MARK: Error binding policies

func _RXCocoa_bindingError(_ error: Swift.Error) {
    let error = "Binding error: \(error)"
#if DEBUG
    _RXCocoa_rxFatalError(error)
#else
    print(error)
#endif
}

/// Swift does not implement abstract methods. This method is used as a runtime check to ensure that methods which intended to be abstract (i.e., they should be implemented in subclasses) are not called directly on the superclass.
func _RXCocoa_rxAbstractMethod(message: String = "Abstract method", file: StaticString = #file, line: UInt = #line) -> Swift.Never {
    _RXCocoa_rxFatalError(message, file: file, line: line)
}

func _RXCocoa_rxFatalError(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Swift.Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage(), file: file, line: line)
}

func _RXCocoa_rxFatalErrorInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
        fatalError(lastMessage(), file: file, line: line)
    #else
        print("\(file):\(line): \(lastMessage())")
    #endif
}

// MARK: casts or fatal error

// workaround for Swift compiler bug, cheers compiler team :)
func _RXCocoa_castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = _RXCocoa_castOrFatalError(value)
    return v
}

func _RXCocoa_castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw _RXCocoa_RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

func _RXCocoa_castOptionalOrThrow<T>(_ resultType: T.Type, _ object: AnyObject) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }

    guard let returnValue = object as? T else {
        throw _RXCocoa_RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

func _RXCocoa_castOrFatalError<T>(_ value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        _RXCocoa_rxFatalError(message)
    }
    
    return result
}

func _RXCocoa_castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        _RXCocoa_rxFatalError("Failure converting from \(String(describing: value)) to \(T.self)")
    }
    
    return result
}

// MARK: Error messages

let _RXCocoa_dataSourceNotSet = "DataSource not set"
let _RXCocoa_delegateNotSet = "Delegate not set"

// MARK: Shared with RxSwift

func _RXCocoa_rxFatalError(_ lastMessage: String) -> Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

