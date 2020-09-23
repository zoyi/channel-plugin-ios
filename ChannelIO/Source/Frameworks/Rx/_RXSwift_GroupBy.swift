//
//  GroupBy.swift
//  RxSwift
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /*
     Groups the elements of an observable sequence according to a specified key selector function.

     - seealso: [groupBy operator on reactivex.io](http://reactivex.io/documentation/operators/groupby.html)

     - parameter keySelector: A function to extract the key for each element.
     - returns: A sequence of observable groups, each of which corresponds to a unique key value, containing all elements that share that same key value.
     */
    public func groupBy<Key: Hashable>(keySelector: @escaping (Element) throws -> Key)
        -> _RXSwift_Observable<GroupedObservable<Key, Element>> {
        return GroupBy(source: self.asObservable(), selector: keySelector)
    }
}

final private class GroupedObservableImpl<Element>: _RXSwift_Observable<Element> {
    private var _subject: _RXSwift_PublishSubject<Element>
    private var _refCount: _RXSwift_RefCountDisposable
    
    init(subject: _RXSwift_PublishSubject<Element>, refCount: _RXSwift_RefCountDisposable) {
        self._subject = subject
        self._refCount = refCount
    }

    override public func subscribe<Observer: _RXSwift_ObserverType>(_ observer: Observer) -> _RXSwift_Disposable where Observer.Element == Element {
        let release = self._refCount.retain()
        let subscription = self._subject.subscribe(observer)
        return _RXSwift_Disposables.create(release, subscription)
    }
}


final private class GroupBySink<Key: Hashable, Element, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer>
    , _RXSwift_ObserverType where Observer.Element == GroupedObservable<Key, Element> {
    typealias ResultType = Observer.Element 
    typealias Parent = GroupBy<Key, Element>

    private let _parent: Parent
    private let _subscription = _RXSwift_SingleAssignmentDisposable()
    private var _refCountDisposable: _RXSwift_RefCountDisposable!
    private var _groupedSubjectTable: [Key: _RXSwift_PublishSubject<Element>]
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        self._groupedSubjectTable = [Key: _RXSwift_PublishSubject<Element>]()
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> _RXSwift_Disposable {
        self._refCountDisposable = _RXSwift_RefCountDisposable(disposable: self._subscription)
        
        self._subscription.setDisposable(self._parent._source.subscribe(self))
        
        return self._refCountDisposable
    }
    
    private func onGroupEvent(key: Key, value: Element) {
        if let writer = self._groupedSubjectTable[key] {
            writer.on(.next(value))
        } else {
            let writer = _RXSwift_PublishSubject<Element>()
            self._groupedSubjectTable[key] = writer
            
            let group = GroupedObservable(
                key: key,
                source: GroupedObservableImpl(subject: writer, refCount: _refCountDisposable)
            )
            
            self.forwardOn(.next(group))
            writer.on(.next(value))
        }
    }

    final func on(_ event: _RXSwift_Event<Element>) {
        switch event {
        case let .next(value):
            do {
                let groupKey = try self._parent._selector(value)
                self.onGroupEvent(key: groupKey, value: value)
            }
            catch let e {
                self.error(e)
                return
            }
        case let .error(e):
            self.error(e)
        case .completed:
            self.forwardOnGroups(event: .completed)
            self.forwardOn(.completed)
            self._subscription.dispose()
            self.dispose()
        }
    }

    final func error(_ error: Swift.Error) {
        self.forwardOnGroups(event: .error(error))
        self.forwardOn(.error(error))
        self._subscription.dispose()
        self.dispose()
    }
    
    final func forwardOnGroups(event: _RXSwift_Event<Element>) {
        for writer in self._groupedSubjectTable.values {
            writer.on(event)
        }
    }
}

final private class GroupBy<Key: Hashable, Element>: _RXSwift_Producer<GroupedObservable<Key,Element>> {
    typealias KeySelector = (Element) throws -> Key

    fileprivate let _source: _RXSwift_Observable<Element>
    fileprivate let _selector: KeySelector
    
    init(source: _RXSwift_Observable<Element>, selector: @escaping KeySelector) {
        self._source = source
        self._selector = selector
    }

    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == GroupedObservable<Key,Element> {
        let sink = GroupBySink(parent: self, observer: observer, cancel: cancel)
        return (sink: sink, subscription: sink.run())
    }
}
