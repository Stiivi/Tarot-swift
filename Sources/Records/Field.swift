//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//

import Foundation

public final class Field: Equatable {
    /// Field name
    public var name: String
    
    /// Type of the value
    ///
    public var type: ValueType?
    
    /// Flag whether the values are unique. Default is `false`.
    ///
    public var isUnique: Bool = false
    
    /// Flag whether the values are optional . If values are optional
    /// they can be `nil`. Default is `false`.
    ///
    public var isRequired: Bool = false

    /// Flag whether the values can be empty. See `Value.isEmpty` for more
    /// information how emptiness is being checked. Default is `false`
    ///
    public var notEmpty: Bool = false

    public required init(_ name: String, type: ValueType?=nil,
                         isUnique: Bool=false, isRequired: Bool=false) {
        self.name = name
        self.type = type
        self.isUnique = isUnique
        self.isRequired = isRequired
    }
        
    public static func ==(lhs: Field, rhs: Field) -> Bool {
        return lhs.name == rhs.name
                && lhs.type == rhs.type
                && lhs.isUnique == rhs.isUnique
                && lhs.isRequired == rhs.isRequired
            }
}

extension Field: ExpressibleByStringLiteral {
    /// Create a field of unknown type
    ///
    public convenience init(stringLiteral: String) {
        self.init(stringLiteral, type: nil)
    }
}

extension Field: CustomStringConvertible {
    public var description: String { "\(name)" }
}
