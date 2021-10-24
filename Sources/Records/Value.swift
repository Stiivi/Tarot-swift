//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2020/12/14.
//

import Foundation

/// ValueType specifies a data type of a value that is used in interfaces.
///
public enum ValueType: String, Equatable, Codable {
    case bool
    case int
    case double
    case string
    // TODO: case date
    // TODO: case float
    
    /// Returns `true` if the value of this type is convertible to
    /// another type using `xxxValue()` conversion.
    /// Conversion might not be precise, just possible.
    ///
    public func isConvertible(to other: ValueType) -> Bool{
        switch (self, other) {
        // Bool to string, not to int or double
        case (.bool,   .string): return true
        case (.bool,   .bool):   return true
        case (.bool,   .int):    return false
        case (.bool,   .double): return false

        // Int to all except bool
        case (.int,    .string): return true
        case (.int,    .bool):   return false
        case (.int,    .int):    return true
        case (.int,    .double): return true

        // Double to all except bool
        case (.double, .string): return true
        case (.double, .bool):   return false
        case (.double, .int):    return true
        case (.double, .double): return true

        // String to all
        case (.string, .string): return true
        case (.string, .bool):   return true
        case (.string, .int):    return true
        case (.string, .double): return true
        }
        
    }
}

/// Multy-type value representation. The type can represent one of the following
/// values:
///
/// - `bool` – a boolean value
/// - `int` – an integer value
/// - `double` – a double precision floating point number
/// - `string` – a string representing a valid identifier
///
public enum Value: Equatable, Hashable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
       
    public var valueType: ValueType {
        switch self {
        case .string: return .string
        case .bool: return .bool
        case .int: return .int
        case .double: return .double
        }
    }
    
    // Note: When changing the following conversion methods,
    // check ValueType.isConvertible method for maintaining consistency
    //
    
    /// Get a boolean value. String is converted to boolean when it contains
    /// values `true` or `false`. Int and double can not be converted to
    /// booleans.
    ///
    public func boolValue() -> Bool? {
        switch self {
        case .string(let value): return Bool(value)
        case .bool(let value): return value
        case .int(_): return nil
        case .double(_): return nil
        }
    }
    
    /// Get an integer value. All types can be attempted to be converted to an
    /// integer except boolean.
    ///
    public func intValue() -> Int? {
        switch self {
        case .string(let value): return Int(value)
        case .bool(_): return nil
        case .int(let value): return value
        case .double(let value): return Int(value)
        }
    }

    /// Get a double value. All types can be attempted to be converted to a
    /// double value except boolean.
    ///
    public func doubleValue() -> Double? {
        switch self {
        case .string(let value): return Double(value)
        case .bool(_): return nil
        case .int(let value): return Double(value)
        case .double(let value): return value
        }
    }
    
    /// Get a string value. Any type can be converted to a string.
    /// 
    public func stringValue() -> String? {
        switch self {
        case .string(let value): return String(value)
        case .bool(let value): return String(value)
        case .int(let value): return String(value)
        case .double(let value): return String(value)
        }
    }
    
    /// `true` if the value is considered empty empty.
    /// String value is considered empty if the lenght of
    /// a string is zero, numeric value is considered empty if the value is
    /// equal to zero. Boolean value is not considered empty.

    public var isEmpty: Bool {
        return stringValue() == "" || intValue() == 0 || doubleValue() == 0.0
    }
    
    /// Converts value to a value of another type, if possible. Caller is
    /// advised to call ``ValueType.isConertible()`` to prevent potential
    /// convention errors.
    public func convert(to otherType:ValueType) -> Value? {
        switch (otherType) {
        case .int: return self.intValue().map { .int($0) } ?? nil
        case .string: return self.stringValue().map { .string($0) } ?? nil
        case .bool: return self.boolValue().map { .bool($0) } ?? nil
        case .double: return self.doubleValue().map { .double($0) } ?? nil
        }
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        return stringValue() ?? "(unknown value)"
    }
}

extension Value: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self = .string(stringLiteral)
    }
}

extension Value: ExpressibleByBooleanLiteral {
    public init(booleanLiteral: Bool) {
        self = .bool(booleanLiteral)
    }
    
}

extension Value: ExpressibleByIntegerLiteral {
    public init(integerLiteral: Int) {
        self = .int(integerLiteral)
    }
}

extension Value: ExpressibleByFloatLiteral {
    public init(floatLiteral: Float) {
        self = .double(Double(floatLiteral))
    }
}
