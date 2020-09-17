//
//  HTTPMethod.swift
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
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
//

/// Type representing HTTP methods. Raw `String` value is stored and compared case-sensitively, so
/// `HTTPMethod.get != HTTPMethod(rawValue: "get")`.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
struct AF_HTTPMethod: RawRepresentable, Equatable, Hashable {
    /// `CONNECT` method.
    static let connect = AF_HTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
    static let delete = AF_HTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    static let get = AF_HTTPMethod(rawValue: "GET")
    /// `HEAD` method.
    static let head = AF_HTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
    static let options = AF_HTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
    static let patch = AF_HTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    static let post = AF_HTTPMethod(rawValue: "POST")
    /// `PUT` method.
    static let put = AF_HTTPMethod(rawValue: "PUT")
    /// `TRACE` method.
    static let trace = AF_HTTPMethod(rawValue: "TRACE")

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
