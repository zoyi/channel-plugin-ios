//
//  UISearchBar+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

extension _RXSwift_Reactive where Base: UISearchBar {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: _RXCocoa_DelegateProxy<UISearchBar, UISearchBarDelegate> {
        return _RXCocoa_RxSearchBarDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `text` property.
    var text: _RXCocoa_ControlProperty<String?> {
        return value
    }
    
    /// Reactive wrapper for `text` property.
    var value: _RXCocoa_ControlProperty<String?> {
        let source: _RXSwift_Observable<String?> = _RXSwift_Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> _RXSwift_Observable<String?> in
            let text = searchBar?.text

            let textDidChange = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? _RXSwift_Observable.empty())
            let didEndEditing = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidEndEditing(_:))) ?? _RXSwift_Observable.empty())
            
            return _RXSwift_Observable.merge(textDidChange, didEndEditing)
                    .map { _ in searchBar?.text ?? "" }
                    .startWith(text)
        }

        let bindingObserver = _RXCocoa_Binder(self.base) { (searchBar, text: String?) in
            searchBar.text = text
        }
        
        return _RXCocoa_ControlProperty(values: source, valueSink: bindingObserver)
    }
    
    /// Reactive wrapper for `selectedScopeButtonIndex` property.
    var selectedScopeButtonIndex: _RXCocoa_ControlProperty<Int> {
        let source: _RXSwift_Observable<Int> = _RXSwift_Observable.deferred { [weak source = self.base as UISearchBar] () -> _RXSwift_Observable<Int> in
            let index = source?.selectedScopeButtonIndex ?? 0
            
            return (source?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:selectedScopeButtonIndexDidChange:))) ?? _RXSwift_Observable.empty())
                .map { a in
                    return try _RXCocoa_castOrThrow(Int.self, a[1])
                }
                .startWith(index)
        }
        
        let bindingObserver = _RXCocoa_Binder(self.base) { (searchBar, index: Int) in
            searchBar.selectedScopeButtonIndex = index
        }
        
        return _RXCocoa_ControlProperty(values: source, valueSink: bindingObserver)
    }
    
#if os(iOS)
    /// Reactive wrapper for delegate method `searchBarCancelButtonClicked`.
    var cancelButtonClicked: _RXCocoa_ControlEvent<Void> {
        let source: _RXSwift_Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:)))
            .map { _ in
                return ()
            }
        return _RXCocoa_ControlEvent(events: source)
    }

	/// Reactive wrapper for delegate method `searchBarBookmarkButtonClicked`.
	var bookmarkButtonClicked: _RXCocoa_ControlEvent<Void> {
		let source: _RXSwift_Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarBookmarkButtonClicked(_:)))
			.map { _ in
				return ()
			}
		return _RXCocoa_ControlEvent(events: source)
	}

	/// Reactive wrapper for delegate method `searchBarResultsListButtonClicked`.
	var resultsListButtonClicked: _RXCocoa_ControlEvent<Void> {
		let source: _RXSwift_Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarResultsListButtonClicked(_:)))
			.map { _ in
				return ()
		}
		return _RXCocoa_ControlEvent(events: source)
	}
#endif
	
    /// Reactive wrapper for delegate method `searchBarSearchButtonClicked`.
    var searchButtonClicked: _RXCocoa_ControlEvent<Void> {
        let source: _RXSwift_Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarSearchButtonClicked(_:)))
            .map { _ in
                return ()
        }
        return _RXCocoa_ControlEvent(events: source)
    }
	
	/// Reactive wrapper for delegate method `searchBarTextDidBeginEditing`.
	var textDidBeginEditing: _RXCocoa_ControlEvent<Void> {
		let source: _RXSwift_Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidBeginEditing(_:)))
			.map { _ in
				return ()
		}
		return _RXCocoa_ControlEvent(events: source)
	}
	
	/// Reactive wrapper for delegate method `searchBarTextDidEndEditing`.
	var textDidEndEditing: _RXCocoa_ControlEvent<Void> {
		let source: _RXSwift_Observable<Void> = self.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBarTextDidEndEditing(_:)))
			.map { _ in
				return ()
		}
		return _RXCocoa_ControlEvent(events: source)
	}
  
    /// Installs delegate as forwarding delegate on `delegate`.
    /// Delegate won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter delegate: Delegate object.
    /// - returns: Disposable object that can be used to unbind the delegate.
    func setDelegate(_ delegate: UISearchBarDelegate)
        -> _RXSwift_Disposable {
        return _RXCocoa_RxSearchBarDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

#endif
