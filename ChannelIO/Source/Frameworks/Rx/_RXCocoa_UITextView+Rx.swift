//
//  UITextView+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 7/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
//import RxSwift

extension _RXSwift_Reactive where Base: UITextView {
    /// Reactive wrapper for `text` property
    var text: _RXCocoa_ControlProperty<String?> {
        return value
    }
    
    /// Reactive wrapper for `text` property.
    var value: _RXCocoa_ControlProperty<String?> {
        let source: _RXSwift_Observable<String?> = _RXSwift_Observable.deferred { [weak textView = self.base] in
            let text = textView?.text
            
            let textChanged = textView?.textStorage
                // This project uses text storage notifications because
                // that's the only way to catch autocorrect changes
                // in all cases. Other suggestions are welcome.
                .rx.didProcessEditingRangeChangeInLength
                // This observe on is here because text storage
                // will emit event while process is not completely done,
                // so rebinding a value will cause an exception to be thrown.
                .observeOn(_RXSwift_MainScheduler.asyncInstance)
                .map { _ in
                    return textView?.textStorage.string
                }
                ?? _RXSwift_Observable.empty()
            
            return textChanged
                .startWith(text)
        }

        let bindingObserver = _RXCocoa_Binder(self.base) { (textView, text: String?) in
            // This check is important because setting text value always clears control state
            // including marked text selection which is imporant for proper input 
            // when IME input method is used.
            if textView.text != text {
                textView.text = text
            }
        }
        
        return _RXCocoa_ControlProperty(values: source, valueSink: bindingObserver)
    }
    
    
    /// Reactive wrapper for `attributedText` property.
    var attributedText: _RXCocoa_ControlProperty<NSAttributedString?> {
        let source: _RXSwift_Observable<NSAttributedString?> = _RXSwift_Observable.deferred { [weak textView = self.base] in
            let attributedText = textView?.attributedText
            
            let textChanged: _RXSwift_Observable<NSAttributedString?> = textView?.textStorage
                // This project uses text storage notifications because
                // that's the only way to catch autocorrect changes
                // in all cases. Other suggestions are welcome.
                .rx.didProcessEditingRangeChangeInLength
                // This observe on is here because attributedText storage
                // will emit event while process is not completely done,
                // so rebinding a value will cause an exception to be thrown.
                .observeOn(_RXSwift_MainScheduler.asyncInstance)
                .map { _ in
                    return textView?.attributedText
                }
                ?? _RXSwift_Observable.empty()
            
            return textChanged
                .startWith(attributedText)
        }
        
        let bindingObserver = _RXCocoa_Binder(self.base) { (textView, attributedText: NSAttributedString?) in
            // This check is important because setting text value always clears control state
            // including marked text selection which is imporant for proper input
            // when IME input method is used.
            if textView.attributedText != attributedText {
                textView.attributedText = attributedText
            }
        }
        
        return _RXCocoa_ControlProperty(values: source, valueSink: bindingObserver)
    }

    /// Reactive wrapper for `delegate` message.
    var didBeginEditing: _RXCocoa_ControlEvent<()> {
       return _RXCocoa_ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidBeginEditing(_:)))
            .map { _ in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    var didEndEditing: _RXCocoa_ControlEvent<()> {
        return _RXCocoa_ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidEndEditing(_:)))
            .map { _ in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    var didChange: _RXCocoa_ControlEvent<()> {
        return _RXCocoa_ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidChange(_:)))
            .map { _ in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    var didChangeSelection: _RXCocoa_ControlEvent<()> {
        return _RXCocoa_ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextViewDelegate.textViewDidChangeSelection(_:)))
            .map { _ in
                return ()
            })
    }

}

#endif
