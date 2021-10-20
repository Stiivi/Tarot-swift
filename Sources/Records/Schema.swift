//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/19.
//

import Foundation

/// Schema of a record, or usually of a collection of records. Defines
/// expectations about record fields.
///
/// Schema allows field names not to be unique. We want to allow the source of
/// the the schema to come from unclean sources. It is up to the user how to
/// deal with a situation with fields of the same name. This opens
/// possibilities for source data structure diagnostics, for example.
///
public class Schema {
    public typealias FieldKey = Int
    public var fields: [Field]
    
    /// Create an empty schema
    public init() {
        self.fields = []
    }
    public init(_ fields: [Field]) {
        self.fields = fields
    }
    
    /// Create a schema with fields of given names where the value type of
    /// all fields is `type`.
    ///
    public init(_ fieldNames: [String], type: ValueType?=nil) {
        self.fields = fieldNames.map { Field($0, type: type) }
    }
    
    /// Returns a list of names of schema fields.
    ///
    public var fieldNames: [String] {
        return self.fields.map { $0.name }
    }
    
    /// Returns a list of keys for fields.
    ///
    public var fieldKeys: [FieldKey] {
        return Array(fields.indices)
    }
    
    /// Test whether the schema has a field with given name.
    ///
    /// - Returns: `true` if the schema contains a field with given name.
    ///
    public func hasField(_ name: String) -> Bool {
        return fieldNames.contains(name)
    }
    
    public func firstField(_ name: String) -> Field? {
        return fields.first {
            $0.name == name
        }
    }

    /// Returst first field key for field with given name.
    ///
    public func firstFieldKey(name: String) -> Int? {
        return fields.firstIndex {
            $0.name == name
        }
    }
    
    public func contains(_ name: String) -> Bool {
        return fieldNames.contains(name)
    }
    
    /// Checks whether the receiver schema is convertible to the `other` schema.
    /// Receiver is convertible if the fields are subset of
    /// the other's and when the types of those fields are also convertible.
    /// Order of the fields does not matter.
    ///
    /// See `ValueType.isConvertible()` for more information on conversibility
    /// of types.
    ///
    public func isConvertible(to other: Schema) -> Bool {
        guard Set(fieldNames).isSubset(of: Set(other.fieldNames)) else {
            return false
        }
        
        for field in fields {
            // It must exist, as we checked it above
            let otherField = other.firstField(field.name)!
            if let type = field.type {
                if let otherType = otherField.type {
                    if !type.isConvertible(to: otherType) {
                        return false
                    }
                }
            }
            else {
                // type is nil
                if otherField.type != nil {
                    return false
                }
            }
        }
        return true
    }
    
    /// Returns difference between two schemas
    public func difference(with other: Schema) -> SchemaDifference {
        let names = Set(fieldNames)
        let otherNames = Set(other.fieldNames)
        
        let missing = otherNames.subtracting(names)
        let extra = names.subtracting(otherNames)

        let diff = SchemaDifference(
            missingFields: Array(missing),
            extraFields: Array(extra)
        )
        return diff
    }
    
    /// Returns a new schema with renamed fields
    ///
    public func renamed(_ renameMap:[String:String]) -> Schema {
        let newFields: [Field] = fields.map { field in
            let newName = renameMap[field.name] ?? field.name
            let newField = Field(newName, type: field.type,
                                 isUnique: field.isUnique,
                                 isRequired: field.isRequired)
            return newField
        }
        return Schema(newFields)
    }
}

/// Difference report between two schemas.
///
public struct SchemaDifference {
    /// List of fields that are missing in a schema.
    public let missingFields: [String]
    /// List of fields that are extra in the schema.
    public let extraFields: [String]
}

extension Schema: Equatable {
    public static func ==(lhs: Schema, rhs: Schema) -> Bool {
        return lhs.fields == rhs.fields
    }
}

extension Schema: CustomStringConvertible {
    public var description: String {
        let names = fieldNames.joined(separator: ", ")
        return "(\(names))"
    }
}

