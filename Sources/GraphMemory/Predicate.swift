//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/24.
//

import Foundation
import Records

/// Graph object predicate
public protocol ObjectPredicate {
    /// Evaluates the object with the predicate and returns evaluation result.
    ///
    func evaluate(_ object: Object) -> Bool
}

// FIXME: This is scaffolding class, a bit complex
/// Predicate that compares multiple parameters and their values for equality.
///
public struct AttributeValuePredicate: ObjectPredicate {
    let key: String
    let value: Value
    
    public init(key: String, value: Value) {
        self.key = key
        self.value = value
    }
    
    public func evaluate(_ object: Object) -> Bool{
        return object[key] == value
    }
}
