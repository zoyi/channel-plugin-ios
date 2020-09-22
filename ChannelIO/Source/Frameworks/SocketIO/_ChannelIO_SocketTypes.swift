//
//  SocketTypes.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 4/8/15.
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

/// A marking protocol that says a type can be represented in a socket.io packet.
///
/// Example:
///
/// ```swift
/// struct CustomData : SocketData {
///    let name: String
///    let age: Int
///
///    func socketRepresentation() -> SocketData {
///        return ["name": name, "age": age]
///    }
/// }
///
/// socket.emit("myEvent", CustomData(name: "Erik", age: 24))
/// ```
protocol SocketIO_SocketData {
    // MARK: Methods

    /// A representation of self that can sent over socket.io.
    func socketRepresentation() throws -> SocketIO_SocketData
}

extension SocketIO_SocketData {
    /// Default implementation. Only works for native Swift types and a few Foundation types.
    func socketRepresentation() -> SocketIO_SocketData {
        return self
    }
}

extension Array : SocketIO_SocketData { }
extension Bool : SocketIO_SocketData { }
extension Dictionary : SocketIO_SocketData { }
extension Double : SocketIO_SocketData { }
extension Int : SocketIO_SocketData { }
extension NSArray : SocketIO_SocketData { }
extension Data : SocketIO_SocketData { }
extension NSData : SocketIO_SocketData { }
extension NSDictionary : SocketIO_SocketData { }
extension NSString : SocketIO_SocketData { }
extension NSNull : SocketIO_SocketData { }
extension String : SocketIO_SocketData { }

/// A typealias for an ack callback.
typealias SocketIO_AckCallback = ([Any]) -> ()

/// A typealias for a normal callback.
typealias SocketIO_NormalCallback = ([Any], SocketIO_SocketAckEmitter) -> ()

/// A typealias for a queued POST
typealias SocketIO_Post = (msg: String, completion: (() -> ())?)

typealias SocketIO_JSON = [String: Any]
typealias SocketIO_Probe = (msg: String, type: SocketIO_SocketEnginePacketType, data: [Data], completion: (() -> ())?)
typealias SocketIO_ProbeWaitQueue = [SocketIO_Probe]

enum SocketIO_Either<E, V> {
    case left(E)
    case right(V)
}
