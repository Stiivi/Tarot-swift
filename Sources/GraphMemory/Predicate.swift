//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/24.
//

import Foundation
import Records

/*
 
 # Design Notes
 
 - Filter:
    property -> predicate
 
 Property owner:
    - Node
    - Link
    - Link Origin
    - Link Target
 
 */

/// Graph object predicate
public protocol ObjectPredicate {
    /// Evaluates the object with the predicate and returns evaluation result.
    ///
    func matches(_ object: Object) -> Bool
}

public struct CompoundPredicate {
    enum Aggregation {
        case and
        case or
    }
    
}


/// Predicate that matches objects with given trait
///
public struct TraitPredicate: ObjectPredicate {
    public let traitName: String
    
    public init(traitName: String) {
        self.traitName = traitName
    }
    
    public func matches(_ object: Object) -> Bool {
        guard let node = object as? Node else {
            return false
        }
        
        guard let trait = node.trait else {
            return false
        }
        
        return trait.name == traitName
    }
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
    
    public func matches(_ object: Object) -> Bool{
        return object[key] == value
    }
}

public protocol PropertyPredicate {
    func matches(_ value: Value) -> Bool
}
// MARK: Number Predicates

public struct NumberPredicate: PropertyPredicate {
    public enum Test {
        case lessThan
        case lessOrEqualThan
        case greaterThan
        case greaterOrEqualThan
        case equalTo
        case notEqualTo
    }
    
    let test: Test
    let match: Double
    
    public init(_ match: Double, test: Test = .equalTo) {
        self.match = match
        self.test = test
    }
    
    public func matches(_ value: Value) -> Bool {
        guard let number = value.doubleValue() else {
            return false
        }
        switch test {
        case .lessThan: return number < match
        case .lessOrEqualThan: return number <= match
        case .greaterThan: return number > match
        case .greaterOrEqualThan: return number >= match
        case .equalTo: return number == match
        case .notEqualTo: return number != match
        }
    }
}


// MARK: Text Predicates

public struct TextPredicate: PropertyPredicate {
    public enum Test {
        case startsWith
        case doesNotStartWith
        case endsWith
        case doesNotEndWith
        case contains
        case doesNotContain
        case equalTo
        case notEqualTo
    }
    
    let test: Test
    let match: String

    public init(_ match: String, test: Test = .contains) {
        self.match = match
        self.test = test
    }
    
    public func matches(_ value: Value) -> Bool{
        guard let string: String = value.stringValue() else {
            return false
        }
        
        switch test {
        case .startsWith: return string.hasPrefix(match)
        case .doesNotStartWith: return !string.hasPrefix(match)
        case .endsWith: return string.hasSuffix(match)
        case .doesNotEndWith: return !string.hasSuffix(match)
        case .contains: return string.contains(match)
        case .doesNotContain: return !string.contains(match)
        case .equalTo: return string == match
        case .notEqualTo: return string != match

        }
    }
}

// MARK: Value Predicates

public struct ValuePredicate: PropertyPredicate {
    public enum Test {
        case empty
        case notEmpty
    }
    
    let test: Test
    let match: String
    
    public init(_ match: String, test: Test = .notEmpty) {
        self.match = match
        self.test = test
    }
    
    public func matches(_ value: Value) -> Bool{
        switch test {
        case .empty: return value.isEmpty
        case .notEmpty: return !value.isEmpty
        }
    }
}

