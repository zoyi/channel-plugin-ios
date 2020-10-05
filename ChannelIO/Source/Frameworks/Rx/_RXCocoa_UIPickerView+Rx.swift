//
//  UIPickerView+Rx.swift
//  RxCocoa
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
    
//    import RxSwift
    import UIKit

    extension _RXSwift_Reactive where Base: UIPickerView {

        /// Reactive wrapper for `delegate`.
        /// For more information take a look at `DelegateProxyType` protocol documentation.
        var delegate: _RXCocoa_DelegateProxy<UIPickerView, UIPickerViewDelegate> {
            return _RXCocoa_RxPickerViewDelegateProxy.proxy(for: base)
        }
        
        /// Installs delegate as forwarding delegate on `delegate`.
        /// Delegate won't be retained.
        ///
        /// It enables using normal delegate mechanism with reactive delegate mechanism.
        ///
        /// - parameter delegate: Delegate object.
        /// - returns: Disposable object that can be used to unbind the delegate.
        func setDelegate(_ delegate: UIPickerViewDelegate)
            -> _RXSwift_Disposable {
                return _RXCocoa_RxPickerViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
        }
        
        /**
         Reactive wrapper for `dataSource`.
         
         For more information take a look at `DelegateProxyType` protocol documentation.
         */
        var dataSource: _RXCocoa_DelegateProxy<UIPickerView, UIPickerViewDataSource> {
            return _RXCocoa_RxPickerViewDataSourceProxy.proxy(for: base)
        }
        
        /**
         Reactive wrapper for `delegate` message `pickerView:didSelectRow:inComponent:`.
         */
        var itemSelected: _RXCocoa_ControlEvent<(row: Int, component: Int)> {
            let source = delegate
                .methodInvoked(#selector(UIPickerViewDelegate.pickerView(_:didSelectRow:inComponent:)))
                .map {
                    return (row: try _RXCocoa_castOrThrow(Int.self, $0[1]), component: try _RXCocoa_castOrThrow(Int.self, $0[2]))
                }
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /**
         Reactive wrapper for `delegate` message `pickerView:didSelectRow:inComponent:`.
         
         It can be only used when one of the `rx.itemTitles, rx.itemAttributedTitles, items(_ source: O)` methods is used to bind observable sequence,
         or any other data source conforming to a `ViewDataSourceType` protocol.
         
         ```
         pickerView.rx.modelSelected(MyModel.self)
         .map { ...
         ```
         - parameter modelType: Type of a Model which bound to the dataSource
         */
        func modelSelected<T>(_ modelType: T.Type) -> _RXCocoa_ControlEvent<[T]> {
            let source = itemSelected.flatMap { [weak view = self.base as UIPickerView] _, component -> _RXSwift_Observable<[T]> in
                guard let view = view else {
                    return _RXSwift_Observable.empty()
                }

                let model: [T] = try (0 ..< view.numberOfComponents).map { component in
                    let row = view.selectedRow(inComponent: component)
                    return try view.rx.model(at: IndexPath(row: row, section: component))
                }

                return _RXSwift_Observable.just(model)
            }
            
            return _RXCocoa_ControlEvent(events: source)
        }
        
        /**
         Binds sequences of elements to picker view rows.
         
         - parameter source: Observable sequence of items.
         - parameter titleForRow: Transform between sequence elements and row titles.
         - returns: Disposable object that can be used to unbind.
         
         Example:
         
            let items = Observable.just([
                    "First Item",
                    "Second Item",
                    "Third Item"
                ])
         
            items
                .bind(to: pickerView.rx.itemTitles) { (row, element) in
                    return element.title
                }
                .disposed(by: disposeBag)
         
         */
        
        func itemTitles<Sequence: Swift.Sequence, Source: _RXSwift_ObservableType>
            (_ source: Source)
            -> (_ titleForRow: @escaping (Int, Sequence.Element) -> String?)
            -> _RXSwift_Disposable where Source.Element == Sequence {
                return { titleForRow in
                    let adapter = _RXCocoa_RxStringPickerViewAdapter<Sequence>(titleForRow: titleForRow)
                    return self.items(adapter: adapter)(source)
                }
        }
        
        /**
         Binds sequences of elements to picker view rows.
         
         - parameter source: Observable sequence of items.
         - parameter attributedTitleForRow: Transform between sequence elements and row attributed titles.
         - returns: Disposable object that can be used to unbind.
         
         Example:
         
         let items = Observable.just([
                "First Item",
                "Second Item",
                "Third Item"
            ])
         
         items
            .bind(to: pickerView.rx.itemAttributedTitles) { (row, element) in
                return NSAttributedString(string: element.title)
            }
            .disposed(by: disposeBag)
        
         */

        func itemAttributedTitles<Sequence: Swift.Sequence, Source: _RXSwift_ObservableType>
            (_ source: Source)
            -> (_ attributedTitleForRow: @escaping (Int, Sequence.Element) -> NSAttributedString?)
            -> _RXSwift_Disposable where Source.Element == Sequence {
                return { attributedTitleForRow in
                    let adapter = _RXCocoa_RxAttributedStringPickerViewAdapter<Sequence>(attributedTitleForRow: attributedTitleForRow)
                    return self.items(adapter: adapter)(source)
                }
        }
        
        /**
         Binds sequences of elements to picker view rows.
         
         - parameter source: Observable sequence of items.
         - parameter viewForRow: Transform between sequence elements and row views.
         - returns: Disposable object that can be used to unbind.
         
         Example:
         
         let items = Observable.just([
                "First Item",
                "Second Item",
                "Third Item"
            ])
         
         items
            .bind(to: pickerView.rx.items) { (row, element, view) in
                guard let myView = view as? MyView else {
                    let view = MyView()
                    view.configure(with: element)
                    return view
                }
                myView.configure(with: element)
                return myView
            }
            .disposed(by: disposeBag)
         
         */

        func items<Sequence: Swift.Sequence, Source: _RXSwift_ObservableType>
            (_ source: Source)
            -> (_ viewForRow: @escaping (Int, Sequence.Element, UIView?) -> UIView)
            -> _RXSwift_Disposable where Source.Element == Sequence {
                return { viewForRow in
                    let adapter = _RXCocoa_RxPickerViewAdapter<Sequence>(viewForRow: viewForRow)
                    return self.items(adapter: adapter)(source)
                }
        }
        
        /**
         Binds sequences of elements to picker view rows using a custom reactive adapter used to perform the transformation.
         This method will retain the adapter for as long as the subscription isn't disposed (result `Disposable`
         being disposed).
         In case `source` observable sequence terminates successfully, the adapter will present latest element
         until the subscription isn't disposed.
         
         - parameter adapter: Adapter used to transform elements to picker components.
         - parameter source: Observable sequence of items.
         - returns: Disposable object that can be used to unbind.
         */
        func items<Source: _RXSwift_ObservableType,
                          Adapter: _RXCocoa_RxPickerViewDataSourceType & UIPickerViewDataSource & UIPickerViewDelegate>(adapter: Adapter)
            -> (_ source: Source)
            -> _RXSwift_Disposable where Source.Element == Adapter.Element {
                return { source in
                    let delegateSubscription = self.setDelegate(adapter)
                    let dataSourceSubscription = source.subscribeProxyDataSource(ofObject: self.base, dataSource: adapter, retainDataSource: true, binding: { [weak pickerView = self.base] (_: _RXCocoa_RxPickerViewDataSourceProxy, event) in
                        guard let pickerView = pickerView else { return }
                        adapter.pickerView(pickerView, observedEvent: event)
                    })
                    return _RXSwift_Disposables.create(delegateSubscription, dataSourceSubscription)
                }
        }
        
        /**
         Synchronous helper method for retrieving a model at indexPath through a reactive data source.
         */
        func model<T>(at indexPath: IndexPath) throws -> T {
            let dataSource: _RXCocoa_SectionedViewDataSourceType = _RXCocoa_castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.itemTitles, rx.itemAttributedTitles, items(_ source: O)` methods was used.")
            
            return _RXCocoa_castOrFatalError(try dataSource.model(at: indexPath))
        }
    }

#endif
