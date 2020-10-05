//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
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

#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif


class ConstraintMakerExtendable: ConstraintMakerRelatable {
    
    var left: ConstraintMakerExtendable {
        self.description.attributes += .left
        return self
    }
    
    var top: ConstraintMakerExtendable {
        self.description.attributes += .top
        return self
    }
    
    var bottom: ConstraintMakerExtendable {
        self.description.attributes += .bottom
        return self
    }
    
    var right: ConstraintMakerExtendable {
        self.description.attributes += .right
        return self
    }
    
    var leading: ConstraintMakerExtendable {
        self.description.attributes += .leading
        return self
    }
    
    var trailing: ConstraintMakerExtendable {
        self.description.attributes += .trailing
        return self
    }
    
    var width: ConstraintMakerExtendable {
        self.description.attributes += .width
        return self
    }
    
    var height: ConstraintMakerExtendable {
        self.description.attributes += .height
        return self
    }
    
    var centerX: ConstraintMakerExtendable {
        self.description.attributes += .centerX
        return self
    }
    
    var centerY: ConstraintMakerExtendable {
        self.description.attributes += .centerY
        return self
    }
    
    @available(*, deprecated, renamed:"lastBaseline")
    var baseline: ConstraintMakerExtendable {
        self.description.attributes += .lastBaseline
        return self
    }
    
    var lastBaseline: ConstraintMakerExtendable {
        self.description.attributes += .lastBaseline
        return self
    }
    
    @available(iOS 8.0, OSX 10.11, *)
    var firstBaseline: ConstraintMakerExtendable {
        self.description.attributes += .firstBaseline
        return self
    }
    
    @available(iOS 8.0, *)
    var leftMargin: ConstraintMakerExtendable {
        self.description.attributes += .leftMargin
        return self
    }
    
    @available(iOS 8.0, *)
    var rightMargin: ConstraintMakerExtendable {
        self.description.attributes += .rightMargin
        return self
    }
    
    @available(iOS 8.0, *)
    var topMargin: ConstraintMakerExtendable {
        self.description.attributes += .topMargin
        return self
    }
    
    @available(iOS 8.0, *)
    var bottomMargin: ConstraintMakerExtendable {
        self.description.attributes += .bottomMargin
        return self
    }
    
    @available(iOS 8.0, *)
    var leadingMargin: ConstraintMakerExtendable {
        self.description.attributes += .leadingMargin
        return self
    }
    
    @available(iOS 8.0, *)
    var trailingMargin: ConstraintMakerExtendable {
        self.description.attributes += .trailingMargin
        return self
    }
    
    @available(iOS 8.0, *)
    var centerXWithinMargins: ConstraintMakerExtendable {
        self.description.attributes += .centerXWithinMargins
        return self
    }
    
    @available(iOS 8.0, *)
    var centerYWithinMargins: ConstraintMakerExtendable {
        self.description.attributes += .centerYWithinMargins
        return self
    }
    
    var edges: ConstraintMakerExtendable {
        self.description.attributes += .edges
        return self
    }
    var horizontalEdges: ConstraintMakerExtendable {
        self.description.attributes += .horizontalEdges
        return self
    }
    var verticalEdges: ConstraintMakerExtendable {
        self.description.attributes += .verticalEdges
        return self
    }
    var directionalEdges: ConstraintMakerExtendable {
        self.description.attributes += .directionalEdges
        return self
    }
    var directionalHorizontalEdges: ConstraintMakerExtendable {
        self.description.attributes += .directionalHorizontalEdges
        return self
    }
    var directionalVerticalEdges: ConstraintMakerExtendable {
        self.description.attributes += .directionalVerticalEdges
        return self
    }
    var size: ConstraintMakerExtendable {
        self.description.attributes += .size
        return self
    }
    
    @available(iOS 8.0, *)
    var margins: ConstraintMakerExtendable {
        self.description.attributes += .margins
        return self
    }
    
    @available(iOS 8.0, *)
    var directionalMargins: ConstraintMakerExtendable {
      self.description.attributes += .directionalMargins
      return self
    }

    @available(iOS 8.0, *)
    var centerWithinMargins: ConstraintMakerExtendable {
        self.description.attributes += .centerWithinMargins
        return self
    }
    
}
