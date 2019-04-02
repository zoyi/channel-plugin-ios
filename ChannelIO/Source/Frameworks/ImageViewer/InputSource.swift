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
//  InputSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import UIKit

/// A protocol that can be adapted by different Input Source providers
@objc
protocol InputSource: class {
    /**
     Load image from the source to image view.
     - parameter imageView: Image view to load the image into.
     - parameter callback: Callback called after image was set to the image view.
     - parameter image: Image that was set to the image view.
     */
    func load(to imageView: UIImageView, with callback: @escaping (_ image: UIImage?) -> Void)
    
    /**
     Cancel image load on the image view
     - parameter imageView: Image view that is loading the image
    */
    @objc optional func cancelLoad(on imageView: UIImageView)
}

/// Input Source to load plain UIImage
class ImageSource: NSObject, InputSource {
    var image: UIImage!

    /// Initializes a new Image Source with UIImage
    /// - parameter image: Image to be loaded
    public init(image: UIImage) {
        self.image = image
    }

    /// Initializes a new Image Source with an image name from the main bundle
    /// - parameter imageString: name of the file in the application's main bundle
    public init?(imageString: String) {
        if let image = UIImage(named: imageString) {
            self.image = image
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.image = image
        callback(image)
    }
}
