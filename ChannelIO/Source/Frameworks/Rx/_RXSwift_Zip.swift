//
//  Zip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol _RXSwift_ZipSinkProtocol : class
{
    func next(_ index: Int)
    func fail(_ error: Swift.Error)
    func done(_ index: Int)
}

class _RXSwift_ZipSink<Observer: _RXSwift_ObserverType> : _RXSwift_Sink<Observer>, _RXSwift_ZipSinkProtocol {
    typealias Element = Observer.Element
    
    let _arity: Int

    let _lock = _RXPlatform_RecursiveLock()

    // state
    private var _isDone: [Bool]
    
    init(arity: Int, observer: Observer, cancel: _RXSwift_Cancelable) {
        self._isDone = [Bool](repeating: false, count: arity)
        self._arity = arity
        
        super.init(observer: observer, cancel: cancel)
    }

    func getResult() throws -> Element {
        _RXSwift_rxAbstractMethod()
    }
    
    func hasElements(_ index: Int) -> Bool {
        _RXSwift_rxAbstractMethod()
    }
    
    func next(_ index: Int) {
        var hasValueAll = true
        
        for i in 0 ..< self._arity {
            if !self.hasElements(i) {
                hasValueAll = false
                break
            }
        }
        
        if hasValueAll {
            do {
                let result = try self.getResult()
                self.forwardOn(.next(result))
            }
            catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        }
    }
    
    func fail(_ error: Swift.Error) {
        self.forwardOn(.error(error))
        self.dispose()
    }
    
    func done(_ index: Int) {
        self._isDone[index] = true
        
        var allDone = true
        
        for done in self._isDone where !done {
            allDone = false
            break
        }
        
        if allDone {
            self.forwardOn(.completed)
            self.dispose()
        }
    }
}

final class _RXSwift_ZipObserver<Element>
    : _RXSwift_ObserverType
    , _RXSwift_LockOwnerType
    , _RXSwift_SynchronizedOnType {
    typealias ValueSetter = (Element) -> Void

    private var _parent: _RXSwift_ZipSinkProtocol?
    
    let _lock: _RXPlatform_RecursiveLock
    
    // state
    private let _index: Int
    private let _this: _RXSwift_Disposable
    private let _setNextValue: ValueSetter
    
    init(lock: _RXPlatform_RecursiveLock, parent: _RXSwift_ZipSinkProtocol, index: Int, setNextValue: @escaping ValueSetter, this: _RXSwift_Disposable) {
        self._lock = lock
        self._parent = parent
        self._index = index
        self._this = this
        self._setNextValue = setNextValue
    }
    
    func on(_ event: _RXSwift_Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: _RXSwift_Event<Element>) {
        if self._parent != nil {
            switch event {
            case .next:
                break
            case .error:
                self._this.dispose()
            case .completed:
                self._this.dispose()
            }
        }
        
        if let parent = self._parent {
            switch event {
            case .next(let value):
                self._setNextValue(value)
                parent.next(self._index)
            case .error(let error):
                parent.fail(error)
            case .completed:
                parent.done(self._index)
            }
        }
    }
}
