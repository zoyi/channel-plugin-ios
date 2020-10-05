//
//  Zip+Collection.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    static func zip<Collection: Swift.Collection>(_ collection: Collection, resultSelector: @escaping ([Collection.Element.Element]) throws -> Element) -> _RXSwift_Observable<Element>
        where Collection.Element: _RXSwift_ObservableType {
        return ZipCollectionType(sources: collection, resultSelector: resultSelector)
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever all of the observable sequences have produced an element at a corresponding index.

     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    static func zip<Collection: Swift.Collection>(_ collection: Collection) -> _RXSwift_Observable<[Element]>
        where Collection.Element: _RXSwift_ObservableType, Collection.Element.Element == Element {
        return ZipCollectionType(sources: collection, resultSelector: { $0 })
    }
    
}

final private class ZipCollectionTypeSink<Collection: Swift.Collection, Observer: _RXSwift_ObserverType>
    : _RXSwift_Sink<Observer> where Collection.Element: _RXSwift_ObservableConvertibleType {
    typealias Result = Observer.Element
    typealias Parent = ZipCollectionType<Collection, Result>
    typealias SourceElement = Collection.Element.Element
    
    private let _parent: Parent
    
    private let _lock = _RXPlatform_RecursiveLock()
    
    // state
    private var _numberOfValues = 0
    private var _values: [_RXSwift_Queue<SourceElement>]
    private var _isDone: [Bool]
    private var _numberOfDone = 0
    private var _subscriptions: [_RXSwift_SingleAssignmentDisposable]
    
    init(parent: Parent, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._parent = parent
        self._values = [_RXSwift_Queue<SourceElement>](repeating: _RXSwift_Queue(capacity: 4), count: parent.count)
        self._isDone = [Bool](repeating: false, count: parent.count)
        self._subscriptions = [_RXSwift_SingleAssignmentDisposable]()
        self._subscriptions.reserveCapacity(parent.count)
        
        for _ in 0 ..< parent.count {
            self._subscriptions.append(_RXSwift_SingleAssignmentDisposable())
        }
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<SourceElement>, atIndex: Int) {
        self._lock.lock(); defer { self._lock.unlock() } // {
            switch event {
            case .next(let element):
                self._values[atIndex].enqueue(element)
                
                if self._values[atIndex].count == 1 {
                    self._numberOfValues += 1
                }
                
                if self._numberOfValues < self._parent.count {
                    if self._numberOfDone == self._parent.count - 1 {
                        self.forwardOn(.completed)
                        self.dispose()
                    }
                    return
                }
                
                do {
                    var arguments = [SourceElement]()
                    arguments.reserveCapacity(self._parent.count)
                    
                    // recalculate number of values
                    self._numberOfValues = 0
                    
                    for i in 0 ..< self._values.count {
                        arguments.append(self._values[i].dequeue()!)
                        if !self._values[i].isEmpty {
                            self._numberOfValues += 1
                        }
                    }
                    
                    let result = try self._parent.resultSelector(arguments)
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
                
                if self._numberOfDone == self._parent.count {
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
        for i in self._parent.sources {
            let index = j
            let source = i.asObservable()

            let disposable = source.subscribe(_RXSwift_AnyObserver { event in
                self.on(event, atIndex: index)
                })
            self._subscriptions[j].setDisposable(disposable)
            j += 1
        }

        if self._parent.sources.isEmpty {
            self.forwardOn(.completed)
        }
        
        return _RXSwift_Disposables.create(_subscriptions)
    }
}

final private class ZipCollectionType<Collection: Swift.Collection, Result>: _RXSwift_Producer<Result> where Collection.Element: _RXSwift_ObservableConvertibleType {
    typealias ResultSelector = ([Collection.Element.Element]) throws -> Result
    
    let sources: Collection
    let resultSelector: ResultSelector
    let count: Int
    
    init(sources: Collection, resultSelector: @escaping ResultSelector) {
        self.sources = sources
        self.resultSelector = resultSelector
        self.count = self.sources.count
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Result {
        let sink = ZipCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
