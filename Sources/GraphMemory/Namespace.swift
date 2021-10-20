//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//

import Foundation

/// A dictionary for naming objects. It can be passed as reference.
///
class Namespace<K, V> where K: Hashable {
    typealias Key = K
    typealias Value = V
    typealias Index = Dictionary<Key, Value>.Index
    typealias Element = Dictionary<Key, Value>.Element

    var names: [Key:Value]
    
    public subscript(key: Key) -> Value? {
        get {
            names[key]
        }
        set(value) {
            names[key] = value
        }
    }
    
    init() {
        names = [:]
    }
}

extension Namespace: Collection {
    var startIndex: Index { names.startIndex }
    var endIndex: Index { names.endIndex }
    func index(after i: Index) -> Index {
        return names.index(after: i)
    }
    public subscript(index: Index) -> Element {
        get { names[index] }
    }
}
