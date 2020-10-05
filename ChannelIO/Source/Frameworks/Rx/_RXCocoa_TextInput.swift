//
//  TextInput.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

//import RxSwift

#if os(iOS) || os(tvOS)
    import UIKit

    /// Represents text input with reactive extensions.
    struct _RXCocoa_TextInput<Base: UITextInput> {
        /// Base text input to extend.
        let base: Base

        /// Reactive wrapper for `text` property.
        let text: _RXCocoa_ControlProperty<String?>

        /// Initializes new text input.
        ///
        /// - parameter base: Base object.
        /// - parameter text: Textual control property.
        init(base: Base, text: _RXCocoa_ControlProperty<String?>) {
            self.base = base
            self.text = text
        }
    }

    extension _RXSwift_Reactive where Base: UITextField {
        /// Reactive text input.
        var textInput: _RXCocoa_TextInput<Base> {
            return _RXCocoa_TextInput(base: base, text: self.text)
        }
    }

    extension _RXSwift_Reactive where Base: UITextView {
        /// Reactive text input.
        var textInput: _RXCocoa_TextInput<Base> {
            return _RXCocoa_TextInput(base: base, text: self.text)
        }
    }

#endif

#if os(macOS)
    import Cocoa

    /// Represents text input with reactive extensions.
    struct _RXSwift_TextInput<Base: NSTextInputClient> {
        /// Base text input to extend.
        let base: Base

        /// Reactive wrapper for `text` property.
        let text: ControlProperty<String?>

        /// Initializes new text input.
        ///
        /// - parameter base: Base object.
        /// - parameter text: Textual control property.
        init(base: Base, text: ControlProperty<String?>) {
            self.base = base
            self.text = text
        }
    }

    extension _RXSwift_Reactive where Base: NSTextField, Base: NSTextInputClient {
        /// Reactive text input.
        var textInput: TextInput<Base> {
            return TextInput(base: self.base, text: self.text)
        }
    }

#endif


