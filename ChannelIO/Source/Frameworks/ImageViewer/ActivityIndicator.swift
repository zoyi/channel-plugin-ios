//  Copyright (c) 2015 Petr Zvoníček <zvonicek@gmail.com>
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
//  THE SOFTWARE

//
//  ActivityIndicator.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 01.05.17.
//

import UIKit

/// Cusotm Activity Indicator can be used by implementing this protocol
protocol ActivityIndicatorView {
    /// View of the activity indicator
    var view: UIView { get }

    /// Show activity indicator
    func show()

    /// Hide activity indicator
    func hide()
}

/// Factory protocol to create new ActivityIndicatorViews. Meant to be implemented when creating custom activity indicator.
protocol ActivityIndicatorFactory {
    func create() -> ActivityIndicatorView
}

/// Default ActivityIndicatorView implementation for UIActivityIndicatorView
extension UIActivityIndicatorView: ActivityIndicatorView {
    public var view: UIView {
        return self
    }

    public func show() {
        startAnimating()
    }

    public func hide() {
        stopAnimating()
    }
}

/// Default activity indicator factory creating UIActivityIndicatorView instances
@objcMembers
class DefaultActivityIndicator: ActivityIndicatorFactory {
    /// activity indicator style
    open var style: UIActivityIndicatorViewStyle
    
    /// activity indicator color
    open var color: UIColor?

    /// Create a new ActivityIndicator for UIActivityIndicatorView
    ///
    /// - style: activity indicator style
    /// - color: activity indicator color
  public init(style: UIActivityIndicatorViewStyle = .gray, color: UIColor? = nil) {
        self.style = style
        self.color = color
    }

    /// create ActivityIndicatorView instance
    open func create() -> ActivityIndicatorView {
        #if swift(>=4.2)
        let activityIndicator = UIActivityIndicatorView(style: style)
        #else
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
        #endif
        activityIndicator.color = color
        activityIndicator.hidesWhenStopped = true

        return activityIndicator
    }
}
