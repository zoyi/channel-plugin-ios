//
//  Event.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a sequence event.
///
/// Sequence grammar: 
/// **next\* (error | completed)**
 enum _RXSwift_Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}

extension _RXSwift_Event: CustomDebugStringConvertible {
    /// Description of event.
     var debugDescription: String {
        switch self {
        case .next(let value):
            return "next(\(value))"
        case .error(let error):
            return "error(\(error))"
        case .completed:
            return "completed"
        }
    }
}

extension _RXSwift_Event {
    /// Is `completed` or `error` event.
     var isStopEvent: Bool {
        switch self {
        case .next: return false
        case .error, .completed: return true
        }
    }

    /// If `next` event, returns element value.
     var element: Element? {
        if case .next(let value) = self {
            return value
        }
        return nil
    }

    /// If `error` event, returns error.
     var error: Swift.Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }

    /// If `completed` event, returns `true`.
     var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}

extension _RXSwift_Event {
    /// Maps sequence elements using transform. If error happens during the transform, `.error`
    /// will be returned as value.
     func map<Result>(_ transform: (Element) throws -> Result) -> _RXSwift_Event<Result> {
        do {
            switch self {
            case let .next(element):
                return .next(try transform(element))
            case let .error(error):
                return .error(error)
            case .completed:
                return .completed
            }
        }
        catch let e {
            return .error(e)
        }
    }
}

/// A type that can be converted to `Event<Element>`.
 protocol _RXSwift_EventConvertible {
    /// Type of element in event
    associatedtype Element

    @available(*, deprecated, renamed: "Element")
    typealias ElementType = Element

    /// Event representation of this instance
    var event: _RXSwift_Event<Element> { get }
}

extension _RXSwift_Event: _RXSwift_EventConvertible {
    /// Event representation of this instance
     var event: _RXSwift_Event<Element> {
        return self
    }
}
