//
//  RxWKNavigationDelegateProxy.swift
//  RxCocoa
//
//  Created by Giuseppe Lanza on 14/02/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(macOS)

//import RxSwift
import WebKit

@available(iOS 8.0, OSX 10.10, OSXApplicationExtension 10.10, *)
class _RXCocoa_RxWKNavigationDelegateProxy
    : _RXCocoa_DelegateProxy<WKWebView, WKNavigationDelegate>
    , _RXCocoa_DelegateProxyType
, WKNavigationDelegate {

    /// Typed parent object.
    weak private(set) var webView: WKWebView?

    /// - parameter webView: Parent object for delegate proxy.
    init(webView: ParentObject) {
        self.webView = webView
        super.init(parentObject: webView, delegateProxy: _RXCocoa_RxWKNavigationDelegateProxy.self)
    }

    // Register known implementations
    static func registerKnownImplementations() {
        self.register { _RXCocoa_RxWKNavigationDelegateProxy(webView: $0) }
    }
    
    static func currentDelegate(for object: WKWebView) -> WKNavigationDelegate? {
        object.navigationDelegate
    }
    
    static func setCurrentDelegate(_ delegate: WKNavigationDelegate?, to object: WKWebView) {
        object.navigationDelegate = delegate
    }
}

#endif
