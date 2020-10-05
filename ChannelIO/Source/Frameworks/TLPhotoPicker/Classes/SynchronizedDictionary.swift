//
//  SynchronizedDictionary.swift
//  TLPhotoPicker
//
//  Created by wade.hawk on 30/03/2019.
//

import Foundation

class TL_SynchronizedDictionary<K:Hashable,V> {
    private var dictionary: [K:V] = [:]
    private let accessQueue = DispatchQueue(label: "SynchronizedDictionaryAccess",
                                            attributes: .concurrent)
    
    deinit {
        //print("deinit SynchronizedDictionary")
    }
    
    func removeAll() {
        self.accessQueue.async(flags:.barrier) {
            self.dictionary.removeAll()
        }
    }
    
    func removeValue(forKey: K) {
        self.accessQueue.async(flags:.barrier) {
            self.dictionary.removeValue(forKey: forKey)
        }
    }
    
    func forEach(_ closure: ((K,V) -> Void)) {
        self.accessQueue.sync {
            self.dictionary.forEach{ arg in
                let (key, value) = arg
                closure(key,value)
            }
        }
    }
    
    subscript(key: K) -> V? {
        set {
            self.accessQueue.async(flags:.barrier) {
                self.dictionary[key] = newValue
            }
        }
        get {
            var element: V?
            self.accessQueue.sync {
                element = self.dictionary[key]
            }
            return element
        }
    }
}
