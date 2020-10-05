//
//  CombineLatest+Collection.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

     - seealso: [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    static func combineLatest<Collection: Swift.Collection>(_ collection: Collection, resultSelector: @escaping ([Collection.Element.Element]) throws -> Element) -> _RXSwift_Observable<Element>
        where Collection.Element: _RXSwift_ObservableType {
        return CombineLatestCollectionType(sources: collection, resultSelector: resultSelector)
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever any of the observable sequences produces an element.

     - seealso: [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    static func combineLatest<Collection: Swift.Collection>(_ collection: Collection) -> _RXSwift_Observable<[Element]>
        where Collection.Element: _RXSwift_ObservableType, Collection.Element.Element == Element {
        return CombineLatestCollectionType(sources: collection, resultSelector: { $0 })
    }
}

final private class CombineLatestCollectionTypeSink<Collection: Swift.Collection, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer> where Collection.Element: _RXSwift_ObservableConvertibleType {
    typealias Result = Observer.Element 
    typealias Parent = CombineLatestCollectionType<Collection, Result>
    typealias SourceElement = Collection.Element.Element
    
    let _parent: Parent
    
    let _lock = _RXPlatform_RecursiveLock()

    // state
    var _numberOfValues = 0
    var _values: [SourceElement?]
    var _isDone: [Bool]
    var _numberOfDone = 0
    var _subscriptions: [_RXSwift_SingleAssignmentDisposable]
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        self._values = [SourceElement?](repeating: nil, count: parent._count)
        self._isDone = [Bool](repeating: false, count: parent._count)
        self._subscriptions = [_RXSwift_SingleAssignmentDisposable]()
        self._subscriptions.reserveCapacity(parent._count)
        
        for _ in 0 ..< parent._count {
            self._subscriptions.append(_RXSwift_SingleAssignmentDisposable())
        }
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<SourceElement>, atIndex: Int) {
        self._lock.lock(); defer { self._lock.unlock() } // {
            switch event {
            case .next(let element):
                if self._values[atIndex] == nil {
                   self._numberOfValues += 1
                }
                
                self._values[atIndex] = element
                
                if self._numberOfValues < self._parent._count {
                    let numberOfOthersThatAreDone = self._numberOfDone - (self._isDone[atIndex] ? 1 : 0)
                    if numberOfOthersThatAreDone == self._parent._count - 1 {
                        self.forwardOn(.completed)
                        self.dispose()
                    }
                    return
                }
                
                do {
                    let result = try self._parent._resultSelector(self._values.map { $0! })
                    self.forwardOn(.next(result))
                }
                catch let error {
                    self.forwardOn(.error(error))
                    self.dispose()
                }
                
            case .error(let error):
                self.forwardOn(.error(error))
                self.dispose()
            case .completed:
                if self._isDone[atIndex] {
                    return
                }
                
                self._isDone[atIndex] = true
                self._numberOfDone += 1
                
                if self._numberOfDone == self._parent._count {
                    self.forwardOn(.completed)
                    self.dispose()
                }
                else {
                    self._subscriptions[atIndex].dispose()
                }
            }
        // }
    }
    
    func run() -> _RXSwift_Disposable {
        var j = 0
        for i in self._parent._sources {
            let index = j
            let source = i.asObservable()
            let disposable = source.subscribe(_RXSwift_AnyObserver { event in
                self.on(event, atIndex: index)
            })

            self._subscriptions[j].setDisposable(disposable)
            
            j += 1
        }

        if self._parent._sources.isEmpty {
            do {
                let result = try self._parent._resultSelector([])
                self.forwardOn(.next(result))
                self.forwardOn(.completed)
                self.dispose()
            }
            catch let error {
                self.forwardOn(.error(error))
                self.dispose()
            }
        }
        
        return _RXSwift_Disposables.create(_subscriptions)
    }
}

final private class CombineLatestCollectionType<Collection: Swift.Collection, Result>: _RXSwift_Producer<Result> where Collection.Element: _RXSwift_ObservableConvertibleType {
    typealias ResultSelector = ([Collection.Element.Element]) throws -> Result
    
    let _sources: Collection
    let _resultSelector: ResultSelector
    let _count: Int

    init(sources: Collection, resultSelector: @escaping ResultSelector) {
        self._sources = sources
        self._resultSelector = resultSelector
        self._count = self._sources.count
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Result {
        let sink = CombineLatestCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
