//
//  UICollectionView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

//import RxSwift
import UIKit

// Items

extension _RXSwift_Reactive where Base: UICollectionView {

    /**
    Binds sequences of elements to collection view items.
    
    - parameter source: Observable sequence of items.
    - parameter cellFactory: Transform between sequence elements and view cells.
    - returns: Disposable object that can be used to unbind.
     
     Example
    
         let items = Observable.just([
             1,
             2,
             3
         ])

         items
         .bind(to: collectionView.rx.items) { (collectionView, row, element) in
            let indexPath = IndexPath(row: row, section: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NumberCell
             cell.value?.text = "\(element) @ \(row)"
             return cell
         }
         .disposed(by: disposeBag)
    */
    func items<Sequence: Swift.Sequence, Source: _RXSwift_ObservableType>
        (_ source: Source)
        -> (_ cellFactory: @escaping (UICollectionView, Int, Sequence.Element) -> UICollectionViewCell)
        -> _RXSwift_Disposable where Source.Element == Sequence {
        return { cellFactory in
            let dataSource = _RXCocoa_RxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence>(cellFactory: cellFactory)
            return self.items(dataSource: dataSource)(source)
        }
        
    }
    
    /**
    Binds sequences of elements to collection view items.
    
    - parameter cellIdentifier: Identifier used to dequeue cells.
    - parameter source: Observable sequence of items.
    - parameter configureCell: Transform between sequence elements and view cells.
    - parameter cellType: Type of collection view cell.
    - returns: Disposable object that can be used to unbind.
     
     Example

         let items = Observable.just([
             1,
             2,
             3
         ])

         items
             .bind(to: collectionView.rx.items(cellIdentifier: "Cell", cellType: NumberCell.self)) { (row, element, cell) in
                cell.value?.text = "\(element) @ \(row)"
             }
             .disposed(by: disposeBag)
    */
    func items<Sequence: Swift.Sequence, Cell: UICollectionViewCell, Source: _RXSwift_ObservableType>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (_ source: Source)
        -> (_ configureCell: @escaping (Int, Sequence.Element, Cell) -> Void)
        -> _RXSwift_Disposable where Source.Element == Sequence {
        return { source in
            return { configureCell in
                let dataSource = _RXCocoa_RxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence> { cv, i, item in
                    let indexPath = IndexPath(item: i, section: 0)
                    let cell = cv.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! Cell
                    configureCell(i, item, cell)
                    return cell
                }
                    
                return self.items(dataSource: dataSource)(source)
            }
        }
    }

    
    /**
    Binds sequences of elements to collection view items using a custom reactive data used to perform the transformation.
    
    - parameter dataSource: Data source used to transform elements to view cells.
    - parameter source: Observable sequence of items.
    - returns: Disposable object that can be used to unbind.
     
     Example
     
         let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Double>>()

         let items = Observable.just([
             SectionModel(model: "First section", items: [
                 1.0,
                 2.0,
                 3.0
             ]),
             SectionModel(model: "Second section", items: [
                 1.0,
                 2.0,
                 3.0
             ]),
             SectionModel(model: "Third section", items: [
                 1.0,
                 2.0,
                 3.0
             ])
         ])

         dataSource.configureCell = { (dataSource, cv, indexPath, element) in
             let cell = cv.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NumberCell
             cell.value?.text = "\(element) @ row \(indexPath.row)"
             return cell
         }

         items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    */
    func items<
            DataSource: _RXCocoa_RxCollectionViewDataSourceType & UICollectionViewDataSource,
            Source: _RXSwift_ObservableType>
        (dataSource: DataSource)
        -> (_ source: Source)
        -> _RXSwift_Disposable where DataSource.Element == Source.Element
          {
        return { source in
            // This is called for sideeffects only, and to make sure delegate proxy is in place when
            // data source is being bound.
            // This is needed because theoretically the data source subscription itself might
            // call `self.rx.delegate`. If that happens, it might cause weird side effects since
            // setting data source will set delegate, and UICollectionView might get into a weird state.
            // Therefore it's better to set delegate proxy first, just to be sure.
            _ = self.delegate
            // Strong reference is needed because data source is in use until result subscription is disposed
            return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak collectionView = self.base] (_: _RXCocoa_RxCollectionViewDataSourceProxy, event) -> Void in
                guard let collectionView = collectionView else {
                    return
                }
                dataSource.collectionView(collectionView, observedEvent: event)
            }
        }
    }
}

extension _RXSwift_Reactive where Base: UICollectionView {
    typealias DisplayCollectionViewCellEvent = (cell: UICollectionViewCell, at: IndexPath)
    typealias DisplayCollectionViewSupplementaryViewEvent = (supplementaryView: UICollectionReusableView, elementKind: String, at: IndexPath)

    /// Reactive wrapper for `dataSource`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var dataSource: _RXCocoa_DelegateProxy<UICollectionView, UICollectionViewDataSource> {
        return _RXCocoa_RxCollectionViewDataSourceProxy.proxy(for: base)
    }
    
    /// Installs data source as forwarding delegate on `rx.dataSource`.
    /// Data source won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter dataSource: Data source object.
    /// - returns: Disposable object that can be used to unbind the data source.
    func setDataSource(_ dataSource: UICollectionViewDataSource)
        -> _RXSwift_Disposable {
        return _RXCocoa_RxCollectionViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
   
    /// Reactive wrapper for `delegate` message `collectionView(_:didSelectItemAtIndexPath:)`.
    var itemSelected: _RXCocoa_ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didSelectItemAt:)))
            .map { a in
                return try _RXCocoa_castOrThrow(IndexPath.self, a[1])
            }
        
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView(_:didDeselectItemAtIndexPath:)`.
    var itemDeselected: _RXCocoa_ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didDeselectItemAt:)))
            .map { a in
                return try _RXCocoa_castOrThrow(IndexPath.self, a[1])
        }

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView(_:didHighlightItemAt:)`.
    var itemHighlighted: _RXCocoa_ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didHighlightItemAt:)))
            .map { a in
                return try _RXCocoa_castOrThrow(IndexPath.self, a[1])
            }
        
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView(_:didUnhighlightItemAt:)`.
    var itemUnhighlighted: _RXCocoa_ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didUnhighlightItemAt:)))
            .map { a in
                return try _RXCocoa_castOrThrow(IndexPath.self, a[1])
            }
        
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView:willDisplay:forItemAt:`.
    var willDisplayCell: _RXCocoa_ControlEvent<DisplayCollectionViewCellEvent> {
        let source: _RXSwift_Observable<DisplayCollectionViewCellEvent> = self.delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:willDisplay:forItemAt:)))
            .map { a in
                return (try _RXCocoa_castOrThrow(UICollectionViewCell.self, a[1]), try _RXCocoa_castOrThrow(IndexPath.self, a[2]))
            }
        
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView(_:willDisplaySupplementaryView:forElementKind:at:)`.
    var willDisplaySupplementaryView: _RXCocoa_ControlEvent<DisplayCollectionViewSupplementaryViewEvent> {
        let source: _RXSwift_Observable<DisplayCollectionViewSupplementaryViewEvent> = self.delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:willDisplaySupplementaryView:forElementKind:at:)))
            .map { a in
                return (try _RXCocoa_castOrThrow(UICollectionReusableView.self, a[1]),
                        try _RXCocoa_castOrThrow(String.self, a[2]),
                        try _RXCocoa_castOrThrow(IndexPath.self, a[3]))
            }

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView:didEndDisplaying:forItemAt:`.
    var didEndDisplayingCell: _RXCocoa_ControlEvent<DisplayCollectionViewCellEvent> {
        let source: _RXSwift_Observable<DisplayCollectionViewCellEvent> = self.delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplaying:forItemAt:)))
            .map { a in
                return (try _RXCocoa_castOrThrow(UICollectionViewCell.self, a[1]), try _RXCocoa_castOrThrow(IndexPath.self, a[2]))
            }

        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)`.
    var didEndDisplayingSupplementaryView: _RXCocoa_ControlEvent<DisplayCollectionViewSupplementaryViewEvent> {
        let source: _RXSwift_Observable<DisplayCollectionViewSupplementaryViewEvent> = self.delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didEndDisplayingSupplementaryView:forElementOfKind:at:)))
            .map { a in
                return (try _RXCocoa_castOrThrow(UICollectionReusableView.self, a[1]),
                        try _RXCocoa_castOrThrow(String.self, a[2]),
                        try _RXCocoa_castOrThrow(IndexPath.self, a[3]))
            }

        return _RXCocoa_ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionView(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionView.rx.modelSelected(MyModel.self)
    ///        .map { ...
    /// ```
    func modelSelected<T>(_ modelType: T.Type) -> _RXCocoa_ControlEvent<T> {
        let source: _RXSwift_Observable<T> = itemSelected.flatMap { [weak view = self.base as UICollectionView] indexPath -> _RXSwift_Observable<T> in
            guard let view = view else {
                return _RXSwift_Observable.empty()
            }

            return _RXSwift_Observable.just(try view.rx.model(at: indexPath))
        }
        
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `collectionView(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionView.rx.modelDeselected(MyModel.self)
    ///        .map { ...
    /// ```
    func modelDeselected<T>(_ modelType: T.Type) -> _RXCocoa_ControlEvent<T> {
        let source: _RXSwift_Observable<T> = itemDeselected.flatMap { [weak view = self.base as UICollectionView] indexPath -> _RXSwift_Observable<T> in
            guard let view = view else {
                return _RXSwift_Observable.empty()
            }

            return _RXSwift_Observable.just(try view.rx.model(at: indexPath))
        }

        return _RXCocoa_ControlEvent(events: source)
    }
    
    /// Synchronous helper method for retrieving a model at indexPath through a reactive data source
    func model<T>(at indexPath: IndexPath) throws -> T {
        let dataSource: _RXCocoa_SectionedViewDataSourceType = _RXCocoa_castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.itemsWith*` methods was used.")
        
        let element = try dataSource.model(at: indexPath)

        return try _RXCocoa_castOrThrow(T.self, element)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
extension _RXSwift_Reactive where Base: UICollectionView {

    /// Reactive wrapper for `prefetchDataSource`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var prefetchDataSource: _RXCocoa_DelegateProxy<UICollectionView, UICollectionViewDataSourcePrefetching> {
        return _RXCocoa_RxCollectionViewDataSourcePrefetchingProxy.proxy(for: base)
    }

    /**
     Installs prefetch data source as forwarding delegate on `rx.prefetchDataSource`.
     Prefetch data source won't be retained.

     It enables using normal delegate mechanism with reactive delegate mechanism.

     - parameter prefetchDataSource: Prefetch data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    func setPrefetchDataSource(_ prefetchDataSource: UICollectionViewDataSourcePrefetching)
        -> _RXSwift_Disposable {
            return _RXCocoa_RxCollectionViewDataSourcePrefetchingProxy.installForwardDelegate(prefetchDataSource, retainDelegate: false, onProxyForObject: self.base)
    }

    /// Reactive wrapper for `prefetchDataSource` message `collectionView(_:prefetchItemsAt:)`.
    var prefetchItems: _RXCocoa_ControlEvent<[IndexPath]> {
        let source = _RXCocoa_RxCollectionViewDataSourcePrefetchingProxy.proxy(for: base).prefetchItemsPublishSubject
        return _RXCocoa_ControlEvent(events: source)
    }

    /// Reactive wrapper for `prefetchDataSource` message `collectionView(_:cancelPrefetchingForItemsAt:)`.
    var cancelPrefetchingForItems: _RXCocoa_ControlEvent<[IndexPath]> {
        let source = prefetchDataSource.methodInvoked(#selector(UICollectionViewDataSourcePrefetching.collectionView(_:cancelPrefetchingForItemsAt:)))
            .map { a in
                return try _RXCocoa_castOrThrow(Array<IndexPath>.self, a[1])
        }

        return _RXCocoa_ControlEvent(events: source)
    }

}
#endif

#if os(tvOS)

extension _RXSwift_Reactive where Base: UICollectionView {
    
    /// Reactive wrapper for `delegate` message `collectionView(_:didUpdateFocusInContext:withAnimationCoordinator:)`.
    var didUpdateFocusInContextWithAnimationCoordinator: ControlEvent<(context: UICollectionViewFocusUpdateContext, animationCoordinator: UIFocusAnimationCoordinator)> {

        let source = delegate.methodInvoked(#selector(UICollectionViewDelegate.collectionView(_:didUpdateFocusIn:with:)))
            .map { a -> (context: UICollectionViewFocusUpdateContext, animationCoordinator: UIFocusAnimationCoordinator) in
                let context = try castOrThrow(UICollectionViewFocusUpdateContext.self, a[1])
                let animationCoordinator = try castOrThrow(UIFocusAnimationCoordinator.self, a[2])
                return (context: context, animationCoordinator: animationCoordinator)
            }

        return _RXCocoa_ControlEvent(events: source)
    }
}
#endif
