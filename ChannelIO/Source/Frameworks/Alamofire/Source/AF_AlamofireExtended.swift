//
//  AlamofireExtended.swift
//
//  Copyright (c) 2019 Alamofire Software Foundation (http://alamofire.org/)
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

/// Type that acts as a generic extension point for all `AlamofireExtended` types.
struct AF_AlamofireExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `af` extension points for Alamofire extended types.
protocol AF_AlamofireExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static Alamofire extension point.
    static var af: AF_AlamofireExtension<ExtendedType>.Type { get set }
    /// Instance Alamofire extension point.
    var af: AF_AlamofireExtension<ExtendedType> { get set }
}

extension AF_AlamofireExtended {
    /// Static Alamofire extension point.
    static var af: AF_AlamofireExtension<Self>.Type {
        get { AF_AlamofireExtension<Self>.self }
        set {}
    }

    /// Instance Alamofire extension point.
    var af: AF_AlamofireExtension<Self> {
        get { AF_AlamofireExtension(self) }
        set {}
    }
}
