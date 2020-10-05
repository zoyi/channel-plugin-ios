//
//  Concat.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension _RXSwift_ObservableType {

    /**
     Concatenates the second observable sequence to `self` upon successful termination of `self`.

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - parameter second: Second observable sequence.
     - returns: An observable sequence that contains the elements of `self`, followed by those of the second sequence.
     */
    func concat<Source: _RXSwift_ObservableConvertibleType>(_ second: Source) -> _RXSwift_Observable<Element> where Source.Element == Element {
        return _RXSwift_Observable.concat([self.asObservable(), second.asObservable()])
    }
}

extension _RXSwift_ObservableType {
    /**
     Concatenates all observable sequences in the given sequence, as long as the previous observable sequence terminated successfully.

     This operator has tail recursive optimizations that will prevent stack overflow.

     Optimizations will be performed in cases equivalent to following:

     [1, [2, [3, .....].concat()].concat].concat()

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    static func concat<Sequence: Swift.Sequence>(_ sequence: Sequence) -> _RXSwift_Observable<Element>
        where Sequence.Element == _RXSwift_Observable<Element> {
            return Concat(sources: sequence, count: nil)
    }

    /**
     Concatenates all observable sequences in the given collection, as long as the previous observable sequence terminated successfully.

     This operator has tail recursive optimizations that will prevent stack overflow.

     Optimizations will be performed in cases equivalent to following:

     [1, [2, [3, .....].concat()].concat].concat()

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    static func concat<Collection: Swift.Collection>(_ collection: Collection) -> _RXSwift_Observable<Element>
        where Collection.Element == _RXSwift_Observable<Element> {
            return Concat(sources: collection, count: Int64(collection.count))
    }

    /**
     Concatenates all observable sequences in the given collection, as long as the previous observable sequence terminated successfully.

     This operator has tail recursive optimizations that will prevent stack overflow.

     Optimizations will be performed in cases equivalent to following:

     [1, [2, [3, .....].concat()].concat].concat()

     - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

     - returns: An observable sequence that contains the elements of each given sequence, in sequential order.
     */
    static func concat(_ sources: _RXSwift_Observable<Element> ...) -> _RXSwift_Observable<Element> {
        return Concat(sources: sources, count: Int64(sources.count))
    }
}

final private class ConcatSink<Sequence: Swift.Sequence, Observer: _RXSwift_ObserverType>
    : _RXSwift_TailRecursiveSink<Sequence, Observer>
    , _RXSwift_ObserverType where Sequence.Element: _RXSwift_ObservableConvertibleType, Sequence.Element.Element == Observer.Element {
    typealias Element = Observer.Element 
    
    override init(observer: Observer, cancel: _RXSwift_Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: _RXSwift_Event<Element>){
        switch event {
        case .next:
            self.forwardOn(event)
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.schedule(.moveNext)
        }
    }

    override func subscribeToNext(_ source: _RXSwift_Observable<Element>) -> _RXSwift_Disposable {
        return source.subscribe(self)
    }
    
    override func extract(_ observable: _RXSwift_Observable<Element>) -> SequenceGenerator? {
        if let source = observable as? Concat<Sequence> {
            return (source._sources.makeIterator(), source._count)
        }
        else {
            return nil
        }
    }
}

final private class Concat<Sequence: Swift.Sequence>: _RXSwift_Producer<Sequence.Element.Element> where Sequence.Element: _RXSwift_ObservableConvertibleType {
    typealias Element = Sequence.Element.Element
    
    fileprivate let _sources: Sequence
    fileprivate let _count: _RXSwift_IntMax?

    init(sources: Sequence, count: _RXSwift_IntMax?) {
        self._sources = sources
        self._count = count
    }
    
    override func run<Observer: _RXSwift_ObserverType>(_ observer: Observer, cancel: _RXSwift_Cancelable) -> (sink: _RXSwift_Disposable, subscription: _RXSwift_Disposable) where Observer.Element == Element {
        let sink = ConcatSink<Sequence, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run((self._sources.makeIterator(), self._count))
        return (sink: sink, subscription: subscription)
    }
}

