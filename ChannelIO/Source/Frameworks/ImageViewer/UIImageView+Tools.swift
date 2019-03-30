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
//  UIImageView+Tools.swift
//  Pods
//
//  Created by Aleš Kocur on 20/04/16.
//
//

import UIKit

extension UIImageView {

    func aspectToFitFrame() -> CGRect {

        guard let image = image else {
            assertionFailure("No image found!")
            return CGRect.zero
        }

        let imageRatio: CGFloat = image.size.width / image.size.height
        let viewRatio: CGFloat = frame.size.width / frame.size.height

        if imageRatio < viewRatio {
            let scale: CGFloat = frame.size.height / image.size.height
            let width: CGFloat = scale * image.size.width
            let topLeftX: CGFloat = (frame.size.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: frame.size.height)
        } else {
            let scale: CGFloat = frame.size.width / image.size.width
            let height: CGFloat = scale * image.size.height
            let topLeftY: CGFloat = (frame.size.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: frame.size.width, height: height)
        }
    }
}
